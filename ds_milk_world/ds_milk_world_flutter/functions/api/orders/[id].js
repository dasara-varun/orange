// Cloudflare Pages Function: /api/orders/[id]
// Handles single order get (GET) and status transitions (PATCH) for Outlet & Storefront

export async function onRequestGet(context) {
  try {
    const { params, env } = context;
    const orderId = params.id;

    const kv = env.ORDERS_KV;
    if (!kv) {
      return new Response(JSON.stringify({ error: "ORDERS_KV binding missing" }), {
        status: 500,
        headers: { "Content-Type": "application/json", "Access-Control-Allow-Origin": "*" }
      });
    }

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
  } catch (err) {
    return new Response(JSON.stringify({ error: err.message }), {
      status: 500,
      headers: { "Content-Type": "application/json", "Access-Control-Allow-Origin": "*" }
    });
  }
}

export async function onRequestPatch(context) {
  try {
    const { params, request, env } = context;
    const orderId = params.id;
    const body = await request.json();

    const kv = env.ORDERS_KV;
    if (!kv) {
      return new Response(JSON.stringify({ error: "ORDERS_KV binding missing" }), {
        status: 500,
        headers: { "Content-Type": "application/json", "Access-Control-Allow-Origin": "*" }
      });
    }

    const raw = await kv.get(`order:${orderId}`);
    if (!raw) {
      return new Response(JSON.stringify({ error: "Order not found" }), {
        status: 404,
        headers: { "Content-Type": "application/json", "Access-Control-Allow-Origin": "*" }
      });
    }

    const order = JSON.parse(raw);
    const nowIso = new Date().toISOString();
    order.updatedAt = nowIso;

    const timeline = order.timeline || [];

    // Supported actions:
    // 1. "accept" -> sets prepTimeMinutes, status: prep_in_progress
    // 2. "mark_ready" -> packing checklist verified, status: ready_for_pickup
    // 3. "assign_delivery" -> provider, riderName, riderPhone, trackingUrl, status: out_for_delivery
    // 4. "complete" -> status: completed / delivered, generates invoiceId
    // 5. "reject" -> status: rejected, rejectionReason
    // 6. "refund" -> status: refunded, refundDetails
    // 7. Generic field updates

    if (body.action === "accept") {
      order.status = "prep_in_progress";
      order.prepTimeMinutes = body.prepTimeMinutes || 20;
      timeline.push({
        eventType: "shop_accepted",
        actor: "staff",
        timestamp: nowIso,
        details: `Shop accepted order. Kitchen preparation time: ${order.prepTimeMinutes} mins`
      });
    } else if (body.action === "mark_ready") {
      order.status = "ready_for_pickup";
      order.packingChecklistConfirmed = true;
      timeline.push({
        eventType: "ready_for_pickup",
        actor: "staff",
        timestamp: nowIso,
        details: "Order packed, chilled and verified ready for delivery pickup"
      });
    } else if (body.action === "assign_delivery") {
      order.status = "out_for_delivery";
      order.deliveryProvider = body.deliveryProvider || "Rapido";
      order.riderName = body.riderName || "Rapido Captain";
      order.riderPhone = body.riderPhone || "+91 98480 12345";
      order.trackingUrl = body.trackingUrl || null;
      order.deliveryOtp = body.deliveryOtp || Math.floor(1000 + Math.random() * 9000).toString();
      timeline.push({
        eventType: "out_for_delivery",
        actor: "rider",
        timestamp: nowIso,
        details: `Dispatched with ${order.deliveryProvider} (${order.riderName}, Phone: ${order.riderPhone})`
      });
    } else if (body.action === "complete") {
      order.status = "completed";
      const year = new Date().getFullYear();
      const randSuffix = Math.floor(1000 + Math.random() * 9000);
      order.invoiceId = order.invoiceId || `INV-DSMW-${year}-${randSuffix}`;
      order.invoiceStatus = "generated";
      order.invoicePdfUrl = `/api/orders/${orderId}/invoice`;
      timeline.push({
        eventType: "order_delivered",
        actor: "rider",
        timestamp: nowIso,
        details: "Order successfully delivered to customer doorstep"
      });
      timeline.push({
        eventType: "invoice_generated",
        actor: "system",
        timestamp: nowIso,
        details: `Tax invoice ${order.invoiceId} generated and dispatched to ${order.customerEmail || "customer email"}`
      });
    } else if (body.action === "reject") {
      order.status = "rejected";
      order.rejectionReason = body.rejectionReason || "Counter closed / kitchen at capacity";
      timeline.push({
        eventType: "shop_rejected",
        actor: "staff",
        timestamp: nowIso,
        details: `Order rejected: ${order.rejectionReason}`
      });
    } else if (body.action === "refund") {
      order.status = "refunded";
      order.refundDetails = body.refundDetails || {
        note: body.reason || "Refund processed by shop",
        timestamp: nowIso
      };
      timeline.push({
        eventType: "payment_refunded",
        actor: "staff",
        timestamp: nowIso,
        details: `Refund processed: ${order.refundDetails.note || "amount confirmed via payment gateway"}`
      });
    } else {
      // Direct property merge
      if (body.status) order.status = body.status;
      if (body.prepTimeMinutes) order.prepTimeMinutes = body.prepTimeMinutes;
      if (body.rejectionReason) order.rejectionReason = body.rejectionReason;
      if (body.refundDetails) {
        order.refundDetails = body.refundDetails;
        order.status = "refunded";
      }
      if (body.timelineEvent) {
        timeline.push(body.timelineEvent);
      }
    }

    order.timeline = timeline;

    await kv.put(`order:${orderId}`, JSON.stringify(order));

    return new Response(JSON.stringify(order), {
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

export async function onRequestOptions() {
  return new Response(null, {
    headers: {
      "Access-Control-Allow-Origin": "*",
      "Access-Control-Allow-Methods": "GET, PATCH, OPTIONS",
      "Access-Control-Allow-Headers": "Content-Type"
    }
  });
}
