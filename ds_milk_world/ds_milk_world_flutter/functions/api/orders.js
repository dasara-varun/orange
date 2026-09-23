// Cloudflare Pages Function: /api/orders
// Handles order creation (POST) and order listing / lookup (GET) using ORDERS_KV

export async function onRequestGet(context) {
  try {
    const { request, env } = context;
    const url = new URL(request.url);
    const orderId = url.searchParams.get("order_id") || url.searchParams.get("orderNumber");
    const statusFilter = url.searchParams.get("status");

    const kv = env.ORDERS_KV;
    if (!kv) {
      return new Response(JSON.stringify({ error: "ORDERS_KV binding not configured" }), {
        status: 500,
        headers: { "Content-Type": "application/json", "Access-Control-Allow-Origin": "*" }
      });
    }

    // 1. Single order lookup
    if (orderId) {
      const raw = await kv.get(`order:${orderId}`);
      if (!raw) {
        return new Response(JSON.stringify({ error: "Order not found" }), {
          status: 404,
          headers: { "Content-Type": "application/json", "Access-Control-Allow-Origin": "*" }
        });
      }
      return new Response(raw, {
        status: 200,
        headers: { "Content-Type": "application/json", "Access-Control-Allow-Origin": "*" }
      });
    }

    // 2. List recent orders
    const indexRaw = await kv.get("order_ids");
    const orderIds = indexRaw ? JSON.parse(indexRaw) : [];

    if (!Array.isArray(orderIds) || orderIds.length === 0) {
      return new Response(JSON.stringify([]), {
        status: 200,
        headers: { "Content-Type": "application/json", "Access-Control-Allow-Origin": "*" }
      });
    }

    // Fetch up to 100 most recent orders in parallel
    const slice = orderIds.slice(0, 100);
    const orderPromises = slice.map(async (id) => {
      try {
        const raw = await kv.get(`order:${id}`);
        return raw ? JSON.parse(raw) : null;
      } catch (_) {
        return null;
      }
    });

    const results = (await Promise.all(orderPromises)).filter(Boolean);

    // Apply optional status filtering
    let filtered = results;
    if (statusFilter && statusFilter.trim().length > 0) {
      const s = statusFilter.trim().toLowerCase();
      filtered = results.filter((o) => {
        const os = (o.status || "").toLowerCase();
        if (s === "new") return os === "shop_acceptance_pending" || os === "paid";
        if (s === "delivered") return os === "delivered" || os === "completed";
        return os === s;
      });
    }

    return new Response(JSON.stringify(filtered), {
      status: 200,
      headers: { "Content-Type": "application/json", "Access-Control-Allow-Origin": "*" }
    });
  } catch (err) {
    return new Response(JSON.stringify({ error: err.message }), {
      status: 500,
      headers: { "Content-Type": "application/json", "Access-Control-Allow-Origin": "*" }
    });
  }
}

export async function onRequestPost(context) {
  try {
    const { request, env } = context;
    const body = await request.json();

    const kv = env.ORDERS_KV;
    if (!kv) {
      return new Response(JSON.stringify({ error: "ORDERS_KV binding not configured on server." }), {
        status: 500,
        headers: { "Content-Type": "application/json", "Access-Control-Allow-Origin": "*" }
      });
    }

    if (!body || !body.orderNumber) {
      return new Response(JSON.stringify({ error: "Invalid order data: missing orderNumber" }), {
        status: 400,
        headers: { "Content-Type": "application/json", "Access-Control-Allow-Origin": "*" }
      });
    }

    const orderNumber = body.orderNumber;
    const nowIso = new Date().toISOString();

    // Recompute money fields server-side so a tampered client payload cannot
    // alter subtotal / delivery fee / total (integer paise everywhere).
    const items = Array.isArray(body.items) ? body.items : [];
    const normalizedItems = items.map((it) => {
      const unitPricePaise = Number(it.unitPricePaise) || 0;
      const quantity = Number(it.quantity) || 0;
      return {
        ...it,
        unitPricePaise,
        quantity,
        subtotalPaise: unitPricePaise * quantity
      };
    });
    const subtotalPaise = normalizedItems.reduce((sum, it) => sum + it.subtotalPaise, 0);
    const deliveryFeePaise = Number(body.deliveryFeePaise) || 0;
    const totalPaise = subtotalPaise + deliveryFeePaise;

    const orderRecord = {
      ...body,
      createdAt: body.createdAt || nowIso,
      updatedAt: nowIso,
      // New orders always start awaiting_payment; client-supplied status and
      // timeline are ignored to prevent forged "paid"/"delivered" events.
      status: "awaiting_payment",
      subtotalPaise,
      deliveryFeePaise,
      totalPaise,
      items: normalizedItems,
      timeline: [
        {
          eventType: "order_created",
          actor: "customer",
          timestamp: nowIso,
          details: "Order placed by customer"
        }
      ]
    };

    // Save order record in KV
    await kv.put(`order:${orderNumber}`, JSON.stringify(orderRecord));

    // Update order index (prepend newest)
    const indexRaw = await kv.get("order_ids");
    let orderIds = indexRaw ? JSON.parse(indexRaw) : [];
    if (!Array.isArray(orderIds)) orderIds = [];

    // Remove if already exists, then prepend
    orderIds = [orderNumber, ...orderIds.filter((id) => id !== orderNumber)].slice(0, 200);
    await kv.put("order_ids", JSON.stringify(orderIds));

    return new Response(JSON.stringify(orderRecord), {
      status: 201,
      headers: { "Content-Type": "application/json", "Access-Control-Allow-Origin": "*" }
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
      "Access-Control-Allow-Methods": "GET, POST, OPTIONS",
      "Access-Control-Allow-Headers": "Content-Type"
    }
  });
}
