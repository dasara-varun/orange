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
    const amount = Number(body.order_amount) || 1.00;
    const phone = String(body.customer_phone || "9848012345").replace(/\D/g, "");
    const name = body.customer_name || "Customer";
    const email = body.customer_email || "orders@dsmilkworld.isroot.in";

    const payload = {
      order_id: orderId,
      order_amount: amount,
      order_currency: "INR",
      customer_details: {
        customer_id: "CUST_" + phone,
        customer_name: name,
        customer_email: email,
        customer_phone: phone.length === 10 ? phone : "9848012345"
      },
      order_meta: {
        return_url: "https://ds-milk-world.pages.dev/?order_id=" + orderId,
        notify_url: "https://ds-milk-world.pages.dev/api/payment-webhook"
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
        return new Response(JSON.stringify(data), {
          status: 200,
          headers: {
            "Content-Type": "application/json",
            "Access-Control-Allow-Origin": "*",
            "Access-Control-Allow-Headers": "Content-Type"
          }
        });
      }
    }

    return new Response(JSON.stringify(data), {
      status: cfRes.status,
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
