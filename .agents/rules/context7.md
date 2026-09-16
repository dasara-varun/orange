# Rule: Context7 Live Documentation & MCP

All coding agents operating in this workspace must use **Context7** (`github.com/upstash/context7`) whenever current library, framework, SDK, or API documentation is needed.

## When to Use Context7
1. **Always consult Context7** when working with third-party libraries or frameworks, including:
   - Flutter & Dart core packages (`flutter_map`, `latlong2`, `provider`, `http`)
   - Serverpod (`serverpod`, `serverpod_client`, `serverpod_service_client`)
   - PostgreSQL / SQL drivers
   - Payment Gateways (Razorpay, PhonePe, Cashfree)
   - Delivery Partner APIs (Rapido, Shadowfax)
2. **Never rely solely on stale training data**: LLM knowledge cutoffs lead to deprecated methods and syntax hallucination.
3. **Do not use for**: Pure internal business logic, self-contained algorithms, or editing existing bespoke codebase files.

## Invocation Protocol
- **Step 1: Resolve Library ID**:
  ```bash
  npx ctx7@latest library "<name>" "<query>"
  ```
  Example: `npx ctx7@latest library "flutter_map" "tile layer openstreetmap configuration"`
- **Step 2: Fetch Targeted Documentation**:
  ```bash
  npx ctx7@latest docs "<libraryId>" "<specific topic>"
  ```
  Example: `npx ctx7@latest docs "/fleaflet/flutter_map" "TileLayer urlTemplate subdomains"`
- **Prompting Shortcut**:
  Include the phrase **"use context7"** in your prompt or thoughts when fetching documentation.
- **Quota / Rate Limits**:
  If a command reports a quota warning, notify the user or run `npx ctx7 login` / set `CONTEXT7_API_KEY`.
