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

    if (computedSignature !== signature) {
      return new Response("Invalid signature", { status: 400 });
    }

    // Process event payload
    const payload = JSON.parse(rawBody);
    console.log("Cashfree Webhook Verified:", payload.type, payload.data?.order?.order_id);

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
