// Cloudflare Pages Function: /api/payment-webhook
export async function onRequestPost(context) {
  try {
    const { request, env } = context;
    const secretKey = (env.CASHFREE_SECRET_KEY || "").trim();
    if (!secretKey) {
      return new Response("Webhook secret not configured on server", { status: 500 });
    }

    const timestamp = request.headers.get("x-webhook-timestamp") || "";
    const signature = request.headers.get("x-webhook-signature") || "";

    const rawBody = await request.text();
    const signedPayload = timestamp + rawBody;

    // Verify HMAC-SHA256
    const enc = new TextEncoder();
    const key = await crypto.subtle.importKey(
      "raw",
      enc.encode(secretKey),
      { name: "HMAC", hash: "SHA-256" },
      false,
      ["sign"]
    );
    const signatureBuffer = await crypto.subtle.sign("HMAC", key, enc.encode(signedPayload));
    const computedSignature = btoa(String.fromCharCode(...new Uint8Array(signatureBuffer)));

    // Constant-time comparison to avoid timing side channels on signature checks
    function timingSafeEqual(a, b) {
      if (a.length !== b.length) return false;
      let diff = 0;
      for (let i = 0; i < a.length; i++) {
        diff |= a.charCodeAt(i) ^ b.charCodeAt(i);
      }
      return diff === 0;
    }

    if (!timingSafeEqual(computedSignature, signature)) {
      return new Response("Invalid signature", { status: 400 });
    }

    const payload = JSON.parse(rawBody);
    const eventType = payload.type || payload.event_type || "";
    const orderId = payload.data?.order?.order_id;
    console.log("Cashfree Webhook Verified:", eventType, orderId);

    // Only process payment-success events; re-fetch the order authoritatively
    // from Cashfree before trusting the state transition (webhook body is
    // HMAC-signed but we never mutate KV from payload fields alone).
    if (eventType === "PAYMENT_SUCCESS_WEBHOOK" && orderId) {
      const appId = (env.CASHFREE_APP_ID || "").trim();
      const apiVersion = (env.CASHFREE_API_VERSION || "2025-01-01").trim();
      const baseUrl = (env.CASHFREE_BASE_URL || "https://api.cashfree.com/pg").trim();

      if (appId && secretKey) {
        try {
          const cfRes = await fetch(`${baseUrl}/orders/${orderId}`, {
            method: "GET",
            headers: {
              "Content-Type": "application/json",
              "x-api-version": apiVersion,
              "x-client-id": appId,
              "x-client-secret": secretKey
            }
          });
          const cfData = await cfRes.json();

          if (cfData?.order_status === "PAID") {
            const kv = env.ORDERS_KV;
            if (kv) {
              const raw = await kv.get(`order:${orderId}`);
              if (raw) {
                const order = JSON.parse(raw);
                if (order.status === "awaiting_payment") {
                  const nowIso = new Date().toISOString();
                  order.status = "shop_acceptance_pending";
                  order.updatedAt = nowIso;
                  const timeline = order.timeline || [];
                  timeline.push({
                    eventType: "payment_successful",
                    actor: "cashfree",
                    timestamp: nowIso,
                    details: "Cashfree online payment confirmed (PAID, via webhook)"
                  });
                  timeline.push({
                    eventType: "shop_acceptance_pending",
                    actor: "system",
                    timestamp: nowIso,
                    details: "Queued for counter review and preparation"
                  });
                  order.timeline = timeline;
                  await kv.put(`order:${orderId}`, JSON.stringify(order));
                }
              }
            }
          }
        } catch (e) {
          console.error("Webhook order re-verify failed:", e.message);
        }
      }
    }

    return new Response(JSON.stringify({ received: true }), {
      status: 200,
      headers: { "Content-Type": "application/json" }
    });
  } catch (err) {
    return new Response(JSON.stringify({ error: err.message }), {
      status: 500,
      headers: { "Content-Type": "application/json" }
    });
  }
}
