// Cloudflare Pages Function: /api/send-invoice
// Generates and emails a branded GST Tax Invoice directly to customer_email

function escapeHtml(value) {
  return String(value ?? "")
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;")
    .replace(/'/g, "&#39;");
}

export async function onRequestPost(context) {
  try {
    const { request, env } = context;
    const body = await request.json();

    const orderId = body.order_id || body.orderNumber;
    let order = body.order;

    // Fetch order from KV if not fully passed
    if (!order && orderId && env.ORDERS_KV) {
      const raw = await env.ORDERS_KV.get(`order:${orderId}`);
      if (raw) order = JSON.parse(raw);
    }

    if (!order) {
      return new Response(JSON.stringify({ error: "Order details not found for invoicing" }), {
        status: 404,
        headers: { "Content-Type": "application/json", "Access-Control-Allow-Origin": "*" }
      });
    }

    const customerEmail = (order.customerEmail || body.customer_email || "").trim();
    if (!customerEmail || !customerEmail.includes("@")) {
      return new Response(JSON.stringify({ error: "Valid customer_email is required for tax invoice dispatch" }), {
        status: 400,
        headers: { "Content-Type": "application/json", "Access-Control-Allow-Origin": "*" }
      });
    }

    const customerName = order.customerName || "Valued Customer";
    const subtotalPaise = order.subtotalPaise || 0;
    const deliveryFeePaise = order.deliveryFeePaise || 0;
    const totalPaise = order.totalPaise || (subtotalPaise + deliveryFeePaise);
    const invoiceId = order.invoiceId || `INV-DSMW-${new Date().getFullYear()}-${orderId}`;

    const items = order.items || [];
    const itemsHtml = items.map((item) => {
      const unitRupees = ((item.unitPricePaise || 0) / 100).toFixed(2);
      const subtotalRupees = ((item.subtotalPaise || 0) / 100).toFixed(2);
      return `
        <tr style="border-bottom: 1px solid #E8DEC8;">
          <td style="padding: 10px 8px; color: #3A241B; font-weight: 600;">${escapeHtml(item.nameSnapshot || item.name || "Product")}</td>
          <td style="padding: 10px 8px; text-align: center; color: #3A241B;">${escapeHtml(item.quantity || 1)}</td>
          <td style="padding: 10px 8px; text-align: right; color: #3A241B;">₹${unitRupees}</td>
          <td style="padding: 10px 8px; text-align: right; color: #3A241B; font-weight: 700;">₹${subtotalRupees}</td>
        </tr>
      `;
    }).join("");

    const subtotalRupees = (subtotalPaise / 100).toFixed(2);
    const deliveryRupees = (deliveryFeePaise / 100).toFixed(2);
    const totalRupees = (totalPaise / 100).toFixed(2);
    const gstRupees = ((subtotalPaise * 0.05) / 100).toFixed(2);

    const emailSubject = `DS Milk World Tax Invoice #${escapeHtml(invoiceId)} for Order #${escapeHtml(orderId)}`;
    const invoiceHtml = `
      <!DOCTYPE html>
      <html>
      <head>
        <meta charset="utf-8">
        <title>${escapeHtml(emailSubject)}</title>
      </head>
      <body style="margin: 0; padding: 24px; font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; background-color: #FFF9F0; color: #1E1B19;">
        <div style="max-width: 600px; margin: 0 auto; background: #FFFFFF; border: 1px solid #E8DEC8; border-radius: 12px; overflow: hidden; box-shadow: 0 4px 14px rgba(58, 36, 27, 0.08);">
          <!-- Header -->
          <div style="background-color: #3A241B; padding: 24px; color: #FFF9F0; text-align: center;">
            <h1 style="margin: 0; font-size: 24px; font-weight: 800; letter-spacing: 1px;">DS MILK WORLD</h1>
            <p style="margin: 4px 0 0 0; font-size: 13px; color: #E8A23A;">Pure Dairy & Refreshing Kitchen • Kanuru Center</p>
            <p style="margin: 2px 0 0 0; font-size: 11px; color: #E8DEC8;">Bandar Road, Near Kanuru Center, Vijayawada, AP 520007 | FSSAI: 10123005000492</p>
          </div>

          <!-- Invoice Title -->
          <div style="padding: 20px 24px 12px 24px; border-bottom: 2px solid #FFF1D6;">
            <table style="width: 100%;">
              <tr>
                <td>
                  <h2 style="margin: 0; color: #3A241B; font-size: 18px;">TAX INVOICE</h2>
                  <p style="margin: 2px 0 0 0; font-size: 12px; color: #786F66;">Invoice ID: <strong>${escapeHtml(invoiceId)}</strong></p>
                  <p style="margin: 2px 0 0 0; font-size: 12px; color: #786F66;">Order ID: <strong>#${escapeHtml(orderId)}</strong></p>
                </td>
                <td style="text-align: right; vertical-align: top;">
                  <span style="display: inline-block; background: #E8F5E9; color: #2E7D32; font-weight: 700; font-size: 12px; padding: 4px 10px; border-radius: 6px;">PAID ONLINE</span>
                  <p style="margin: 4px 0 0 0; font-size: 11px; color: #786F66;">${new Date().toLocaleDateString('en-IN', { timeZone: 'Asia/Kolkata' })}</p>
                </td>
              </tr>
            </table>
          </div>

          <!-- Customer Info -->
          <div style="padding: 16px 24px; background: #FFFDF9; border-bottom: 1px solid #E8DEC8;">
            <p style="margin: 0 0 4px 0; font-size: 11px; text-transform: uppercase; font-weight: 700; color: #786F66;">Billed To:</p>
            <p style="margin: 0; font-size: 14px; font-weight: 700; color: #3A241B;">${escapeHtml(customerName)}</p>
            <p style="margin: 2px 0; font-size: 12px; color: #3A241B;">Phone: ${escapeHtml(order.customerPhone || "N/A")}</p>
            <p style="margin: 2px 0; font-size: 12px; color: #3A241B;">Email: ${escapeHtml(customerEmail)}</p>
            <p style="margin: 2px 0; font-size: 12px; color: #786F66;">Delivery: ${escapeHtml(order.deliveryAddress || "Direct Delivery, Vijayawada")}</p>
          </div>

          <!-- Items Table -->
          <div style="padding: 16px 24px;">
            <table style="width: 100%; border-collapse: collapse; font-size: 13px;">
              <thead>
                <tr style="background-color: #FFF1D6; border-bottom: 2px solid #E8DEC8;">
                  <th style="padding: 8px; text-align: left; color: #3A241B;">Item</th>
                  <th style="padding: 8px; text-align: center; color: #3A241B;">Qty</th>
                  <th style="padding: 8px; text-align: right; color: #3A241B;">Price</th>
                  <th style="padding: 8px; text-align: right; color: #3A241B;">Total</th>
                </tr>
              </thead>
              <tbody>
                ${itemsHtml}
              </tbody>
            </table>

            <!-- Summary Table -->
            <table style="width: 100%; margin-top: 16px; border-collapse: collapse; font-size: 13px;">
              <tr>
                <td style="padding: 4px 8px; color: #786F66;">Items Subtotal:</td>
                <td style="padding: 4px 8px; text-align: right; font-weight: 600; color: #3A241B;">₹${subtotalRupees}</td>
              </tr>
              <tr>
                <td style="padding: 4px 8px; color: #786F66;">Rapido Cold-Chain Delivery:</td>
                <td style="padding: 4px 8px; text-align: right; font-weight: 600; color: #3A241B;">₹${deliveryRupees}</td>
              </tr>
              <tr>
                <td style="padding: 4px 8px; color: #786F66;">GST Included (5% Food & Beverage):</td>
                <td style="padding: 4px 8px; text-align: right; color: #786F66;">(₹${gstRupees})</td>
              </tr>
              <tr style="border-top: 2px solid #3A241B; border-bottom: 2px solid #3A241B;">
                <td style="padding: 10px 8px; font-size: 16px; font-weight: 800; color: #3A241B;">Total Paid:</td>
                <td style="padding: 10px 8px; text-align: right; font-size: 18px; font-weight: 800; color: #3A241B;">₹${totalRupees}</td>
              </tr>
            </table>
          </div>

          <!-- Footer -->
          <div style="background-color: #FFF1D6; padding: 16px 24px; text-align: center; font-size: 11px; color: #786F66;">
            <p style="margin: 0 0 4px 0; font-weight: 700; color: #3A241B;">Thank you for ordering with DS Milk World!</p>
            <p style="margin: 0;">Direct counter queries or support: +91 98480 12345 • Kanuru Center, Vijayawada</p>
            <p style="margin: 4px 0 0 0; color: #A0988E;">This is a computer-generated tax invoice for your records.</p>
          </div>
        </div>
      </body>
      </html>
    `;

    // Attempt delivery via Mailchannels (native free transactional email on Cloudflare Workers)
    let emailSent = false;
    let emailError = null;

    try {
      const sendRes = await fetch("https://api.mailchannels.net/tx/v1/send", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          personalizations: [
            {
              to: [{ email: customerEmail, name: customerName }]
            }
          ],
          from: {
            email: "invoices@dsmilkworld.isroot.in",
            name: "DS Milk World Invoices"
          },
          subject: emailSubject,
          content: [
            {
              type: "text/html",
              value: invoiceHtml
            }
          ]
        })
      });
      if (sendRes.status >= 200 && sendRes.status < 300) {
        emailSent = true;
      } else {
        emailError = await sendRes.text();
      }
    } catch (e) {
      emailError = e.message;
    }

    return new Response(JSON.stringify({
      success: true,
      invoiceId: invoiceId,
      customerEmail: customerEmail,
      emailDispatched: emailSent,
      errorNotice: emailError,
      invoiceHtml: invoiceHtml
    }), {
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
      "Access-Control-Allow-Methods": "POST, OPTIONS",
      "Access-Control-Allow-Headers": "Content-Type"
    }
  });
}
