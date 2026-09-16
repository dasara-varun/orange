// Cloudflare Pages Function: /api/verify-payment
export async function onRequestGet(context) {
  const { request } = context;
  const url = new URL(request.url);
  const orderId = url.searchParams.get("order_id");
  return handleVerification(context, orderId);
}

export async function onRequestPost(context) {
  try {
    const { request } = context;
    const body = await request.json();
    return handleVerification(context, body?.order_id);
  } catch (err) {
    return new Response(JSON.stringify({ error: err.message }), {
      status: 400,
      headers: { "Content-Type": "application/json" }
    });
  }
}

async function handleVerification(context, orderId) {
  try {
    const { env } = context;
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

    if (!orderId) {
      return new Response(JSON.stringify({ error: "Missing order_id" }), { status: 400 });
    }

    const cfRes = await fetch(`${baseUrl}/orders/${orderId}`, {
      method: "GET",
      headers: {
        "Content-Type": "application/json",
        "x-api-version": apiVersion,
        "x-client-id": appId,
        "x-client-secret": secretKey
      }
    });

    const data = await cfRes.json();
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
