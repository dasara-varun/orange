# Rule: Cashfree Payments Integration

All coding agents operating on payment gateway features, checkout, payouts, refunds, or webhook handlers must adhere to the **Cashfree Payments** protocol.

## 1. Skill Reference & Manifest
- Always refer to [`.agents/skills/cashfree/SKILL.md`](../skills/cashfree/SKILL.md) and the comprehensive skill tree in `.agents/skills/cashfree-skills/`.
- Match tasks to the appropriate skill (e.g., `pg/apis`, `pg/webhooks`, `pg/refunds`, `validation-and-testing`).

## 2. Security & Credentials
- **Zero Secrets in Code**: Never hardcode `CASHFREE_APP_ID` or `CASHFREE_SECRET_KEY`. Load them via environment variables or Serverpod's `config/passwords.yaml`.
- **Sandbox vs. Production**:
  - Sandbox: `https://sandbox.cashfree.com/pg`
  - Production: `https://api.cashfree.com/pg`
- **Webhook Verification**: Every webhook payload MUST be validated against the `x-webhook-signature` header using HMAC-SHA256 with the merchant secret before any database state transition.

## 3. Financial Invariants
- Cashfree orders expect amounts in Rupees with 2 decimal places (`order_amount: 150.00`).
- Internal platform models store currency in integer paise (`15000 paise = ₹150.00`).
- Perform the division strictly at the S2S boundary: `order_amount = (order.totalPaise / 100.0)`.

## 4. MCP Server Integration
- For live account queries (settlement balances, UTR lookup, transaction lifecycle), utilize the Cashfree MCP Server at `https://mcp.cashfree.com/mcp` configured in `mcp_config.json` and `.cursor/mcp.json`.

## 5. Go-Live Verification Gate
- Never declare a Cashfree integration "production-ready" without satisfying the checklist in `.agents/skills/cashfree-skills/pg/go-live/SKILL.md` (signature check, domain whitelisting, webhook URL setup, error boundaries).
