// Cloudflare Pages Function: /api/refund-payment
// Initiates authoritative merchant refunds via Cashfree PG without leaving the outlet console

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
        headers: { "Content-Type": "application/json", "Access-Control-Allow-Origin": "*" }
      });
    }

    const orderId = body.order_id;
    if (!orderId) {
      return new Response(JSON.stringify({ error: "Missing order_id for refund" }), {
        status: 400,
        headers: { "Content-Type": "application/json", "Access-Control-Allow-Origin": "*" }
      });
    }

    const amount = Number(body.refund_amount);
    if (!amount || amount <= 0) {
      return new Response(JSON.stringify({ error: "Invalid refund_amount" }), {
        status: 400,
        headers: { "Content-Type": "application/json", "Access-Control-Allow-Origin": "*" }
      });
    }

    const refundId = body.refund_id || ("RFD-" + orderId + "-" + Date.now().toString().slice(-4));
    const refundNote = body.refund_note || "Shop-initiated cancellation / refund";
    const refundSpeed = body.refund_speed || "STANDARD";

    const payload = {
      refund_id: refundId,
      refund_amount: amount,
      refund_note: refundNote,
      refund_speed: refundSpeed
    };

    // 1. Call Cashfree PG Refund endpoint
    const cfRes = await fetch(`${baseUrl}/orders/${orderId}/refunds`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "x-api-version": apiVersion,
        "x-client-id": appId,
        "x-client-secret": secretKey
      },
      body: JSON.stringify(payload)
    });

    const refundData = await cfRes.json();

    // 2. If refund successful or accepted, persist in ORDERS_KV
    if (cfRes.status >= 200 && cfRes.status < 300) {
      const kv = env.ORDERS_KV;
      if (kv) {
        try {
          const raw = await kv.get(`order:${orderId}`);
          if (raw) {
            const order = JSON.parse(raw);
            order.status = "refunded";
            order.updatedAt = new Date().toISOString();
            order.refundDetails = {
              refundId: refundData.refund_id || refundId,
              cfRefundId: refundData.cf_refund_id,
              amount: refundData.refund_amount || amount,
              status: refundData.refund_status || "PROCESSED",
              arn: refundData.refund_arn || null,
              note: refundNote,
              timestamp: new Date().toISOString()
            };

            const timeline = order.timeline || [];
            timeline.push({
              eventType: "payment_refunded",
              actor: "staff",
              timestamp: new Date().toISOString(),
              details: `Cashfree refund of ₹${amount.toFixed(2)} processed (${order.refundDetails.status}). Refund ID: ${order.refundDetails.refundId}`
            });
            order.timeline = timeline;

            await kv.put(`order:${orderId}`, JSON.stringify(order));
          }
        } catch (_) {}
      }
    }

    return new Response(JSON.stringify(refundData), {
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
      headers: { "Content-Type": "application/json", "Access-Control-Allow-Origin": "*" }
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
