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
                  await notifyCustomer(env, order, orderId, cfData);
                }
              }
            }
          }
        } catch (e) {
          console.error("Webhook order re-verify failed:", e.message);
        }
      }
    }

    // Refund status updates — email the customer only when the refund
    // actually succeeds (never treat PENDING as completed).
    if (eventType === "REFUND_STATUS_WEBHOOK" && orderId) {
      const refund = payload.data?.refund;
      const refundStatus = (refund?.refund_status || "").toUpperCase();
      if (refundStatus === "SUCCESS") {
        try {
          const kv = env.ORDERS_KV;
          if (kv) {
            const raw = await kv.get(`order:${orderId}`);
            if (raw) {
              const order = JSON.parse(raw);
              order.status = "refunded";
              order.updatedAt = new Date().toISOString();
              order.refundDetails = {
                ...(order.refundDetails || {}),
                refundId: refund.refund_id,
                cfRefundId: refund.cf_refund_id,
                amount: refund.refund_amount,
                status: "SUCCESS",
                arn: refund.refund_arn || null,
                timestamp: new Date().toISOString()
              };
              const timeline = order.timeline || [];
              timeline.push({
                eventType: "payment_refunded",
                actor: "system",
                timestamp: new Date().toISOString(),
                details: `Refund of ₹${Number(refund.refund_amount || 0).toFixed(2)} credited (ARN: ${refund.refund_arn || "n/a"})`
              });
              order.timeline = timeline;
              await kv.put(`order:${orderId}`, JSON.stringify(order));
              if (isCustomerEmail(order.customerEmail)) {
                await sendCustomerMail(env, {
                  to: order.customerEmail,
                  name: order.customerName,
                  subject: `Refund completed for Order #${orderId}`,
                  html: refundHtml(order, orderId, refund, true)
                });
              }
            }
          }
        } catch (e) {
          console.error("Refund webhook handling failed:", e.message);
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

function isCustomerEmail(email) {
  const e = String(email || "").trim();
  return e.includes("@") && !e.endsWith("@dsmilkworld.isroot.in");
}

function esc(v) {
  return String(v ?? "")
    .replace(/&/g, "&amp;").replace(/</g, "&lt;")
    .replace(/>/g, "&gt;").replace(/"/g, "&quot;");
}

async function sendCustomerMail(env, { to, name, subject, html }) {
  if (!isCustomerEmail(to)) return;
  try {
    await fetch("https://api.mailchannels.net/tx/v1/send", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        personalizations: [{ to: [{ email: to, name: name || "Customer" }] }],
        from: { email: "orders@dsmilkworld.isroot.in", name: "DS Milk World" },
        subject,
        content: [{ type: "text/html", value: html }]
      })
    });
  } catch (_) {}
}

function notifyCustomer(env, order, orderId, cfData) {
  const amount = cfData?.order_amount != null ? Number(cfData.order_amount).toFixed(2)
    : ((order.totalPaise || 0) / 100).toFixed(2);
  return sendCustomerMail(env, {
    to: order.customerEmail,
    name: order.customerName,
    subject: `Payment confirmed for Order #${orderId}`,
    html: `<!DOCTYPE html><html><body style="font-family:sans-serif;background:#FFF9F0;color:#1E1B19;padding:24px;">
      <div style="max-width:560px;margin:auto;background:#fff;border:1px solid #E8DEC8;border-radius:12px;padding:24px;">
        <h2 style="color:#3A241B;margin-top:0;">Payment confirmed</h2>
        <p>Hi ${esc(order.customerName || "Customer")},</p>
        <p>We received your payment of <strong>₹${esc(amount)}</strong> for order <strong>#${esc(orderId)}</strong>.</p>
        <p>Your order is now with the counter for review and preparation.</p>
        <p style="color:#786F66;font-size:12px;">DS Milk World • Kanuru Center, Vijayawada</p>
      </div></body></html>`
  });
}

function refundHtml(order, orderId, refund, completed) {
  const amount = Number(refund?.refund_amount || 0).toFixed(2);
  const title = completed ? "Refund completed" : "Refund initiated";
  const body = completed
    ? `Your refund of <strong>₹${esc(amount)}</strong> for order <strong>#${esc(orderId)}</strong> has been credited to your original payment method.${refund?.refund_arn ? `<br>ARN: <code>${esc(refund.refund_arn)}</code>` : ""}`
    : `Your refund of <strong>₹${esc(amount)}</strong> for order <strong>#${esc(orderId)}</strong> has been initiated and will credit to your original payment method as per bank timelines.`;
  return `<!DOCTYPE html><html><body style="font-family:sans-serif;background:#FFF9F0;color:#1E1B19;padding:24px;">
    <div style="max-width:560px;margin:auto;background:#fff;border:1px solid #E8DEC8;border-radius:12px;padding:24px;">
      <h2 style="color:#3A241B;margin-top:0;">${title}</h2>
      <p>Hi ${esc(order?.customerName || "Customer")},</p>
      <p>${body}</p>
      <p style="color:#786F66;font-size:12px;">DS Milk World • Kanuru Center, Vijayawada</p>
    </div></body></html>`;
}
