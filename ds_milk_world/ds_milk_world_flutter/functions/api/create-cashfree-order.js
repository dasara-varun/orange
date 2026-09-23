// Cloudflare Pages Function: /api/create-cashfree-order
export async function onRequestPost(context) {
  try {
    const { request, env } = context;
    const body = await request.json();

    const appId = (env.CASHFREE_APP_ID || "").trim();
    const secretKey = (env.CASHFREE_SECRET_KEY || "").trim();
    const apiVersion = (env.CASHFREE_API_VERSION || "2025-01-01").trim();
    const baseUrl = (env.CASHFREE_BASE_URL || "https://api.cashfree.com/pg").trim();

    if (!appId || !secretKey) {
      return new Response(JSON.stringify({ error: "Cashfree credentials are not configured on server." }), {
        status: 500,
        headers: { "Content-Type": "application/json" }
      });
    }

    const orderId = body.order_id || ("DSMW-" + Date.now());

    // Amount is server-authoritative: prefer the stored order total in KV so a
    // tampered client cannot pay a lower order_amount. Fall back to the body.
    let amount = Number(body.order_amount) || 1.00;
    const kv = env.ORDERS_KV;
    if (kv) {
      try {
        const storedRaw = await kv.get(`order:${orderId}`);
        if (storedRaw) {
          const storedOrder = JSON.parse(storedRaw);
          const storedTotalPaise = Number(storedOrder.totalPaise) || 0;
          if (storedTotalPaise > 0) {
            amount = storedTotalPaise / 100;
          }
        }
      } catch (_) {}
    }

    // Sanitize 10-digit Indian mobile number
    let rawPhone = String(body.customer_phone || "").replace(/\D/g, "");
    if (rawPhone.length === 12 && rawPhone.startsWith("91")) {
      rawPhone = rawPhone.slice(2);
    }
    const phone = rawPhone.length === 10 ? rawPhone : "9848012345";

    const name = (body.customer_name || "Customer").trim();
    const customerEmail = (body.customer_email || "").trim();
    const validEmail = (customerEmail && customerEmail.includes("@")) ? customerEmail : "customer@dsmilkworld.isroot.in";

    const publicBase = (env.PUBLIC_BASE_URL || "https://ds-milk-world.pages.dev").replace(/\/+$/, "");

    const payload = {
      order_id: orderId,
      order_amount: amount,
      order_currency: "INR",
      customer_details: {
        customer_id: "CUST_" + phone,
        customer_name: name.length > 0 ? name : "Customer",
        customer_email: validEmail,
        customer_phone: phone
      },
      order_meta: {
        return_url: publicBase + "/?order_id=" + orderId,
        notify_url: publicBase + "/api/payment-webhook"
      },
      order_note: "DS Milk World Order #" + orderId
    };

    const cfRes = await fetch(`${baseUrl}/orders`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "x-api-version": apiVersion,
        "x-client-id": appId,
        "x-client-secret": secretKey
      },
      body: JSON.stringify(payload)
    });

    let data = await cfRes.json();

    // If order already exists in Cashfree, fetch existing order session for retry
    if (cfRes.status === 409 || data?.code === "order_already_exists") {
      const getRes = await fetch(`${baseUrl}/orders/${orderId}`, {
        method: "GET",
        headers: {
          "Content-Type": "application/json",
          "x-api-version": apiVersion,
          "x-client-id": appId,
          "x-client-secret": secretKey
        }
      });
      if (getRes.status === 200) {
        data = await getRes.json();
      }
    }

    // Persist payment session in ORDERS_KV if available
    if (kv && data?.payment_session_id) {
      try {
        const raw = await kv.get(`order:${orderId}`);
        if (raw) {
          const order = JSON.parse(raw);
          order.paymentSessionId = data.payment_session_id;
          order.cfOrderId = data.cf_order_id;
          order.customerName = name;
          order.customerEmail = validEmail;
          order.customerPhone = phone;
          await kv.put(`order:${orderId}`, JSON.stringify(order));
        }
      } catch (_) {}
    }

    return new Response(JSON.stringify(data), {
      status: cfRes.status >= 200 && cfRes.status < 300 ? cfRes.status : (data?.payment_session_id ? 200 : cfRes.status),
      headers: {
        "Content-Type": "application/json",
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Headers": "Content-Type"
      }
    });
  } catch (err) {
    return new Response(JSON.stringify({ error: err.message }), {
      status: 500,
      headers: { "Content-Type": "application/json" }
    });
  }
}

export async function onRequestOptions() {
  return new Response(null, {
    headers: {
      "Access-Control-Allow-Origin": "*",
      "Access-Control-Allow-Methods": "POST, OPTIONS",
      "Access-Control-Allow-Headers": "Content-Type"
    }
  });
}
