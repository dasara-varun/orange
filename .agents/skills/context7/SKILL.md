---
name: context7
description: Retrieve live, up-to-date, version-specific documentation, API references, and verified code examples for libraries, frameworks, SDKs, and developer tools using Context7. Eliminates LLM hallucinations and outdated code patterns. Activate this skill whenever working with Flutter packages (flutter_map, latlong2, provider), Serverpod backend modules, PostgreSQL drivers, payment gateways (Razorpay, PhonePe), or delivery logistics APIs (Rapido, Shadowfax), or when the user mentions "context7", "ctx7", "docs", or "documentation".
---

# Context7 — Live Documentation & MCP Integration

Context7 connects AI coding agents to up-to-date, verified developer documentation directly within their context window.

## When to Use

- Looking up syntax, classes, or API changes for third-party packages.
- Verifying constructor parameters, breaking changes, or version migration guides.
- Implementing integrations for payment gateways, mapping libraries, or database drivers.
- Debugging unexpected runtime errors from external dependencies.

## Workflow

### 1. Resolve Library ID
Before querying documentation, resolve the official library ID format (`/org/project`):
```bash
npx ctx7@latest library "<Library Name>" "<Query>"
```
Examples:
- `npx ctx7@latest library "flutter_map" "TileLayer options"`
- `npx ctx7@latest library "Serverpod" "Endpoint streaming and auth"`
- `npx ctx7@latest library "Razorpay" "Webhook verification node/dart"`

### 2. Query Documentation
Retrieve targeted documentation snippets, method signatures, and configuration examples:
```bash
npx ctx7@latest docs "<libraryId>" "<Concept or Method>"
```
Examples:
- `npx ctx7@latest docs "/fleaflet/flutter_map" "TileLayer subdomains userAgentPackageName"`
- `npx ctx7@latest docs "/serverpod/serverpod" "sessions and database queries"`

### 3. Apply Verified Code
Integrate the exact syntax confirmed by the fetched documentation into the project, preserving architectural invariants and design tokens.

## Quota & Authentication
If rate limit warnings appear:
```bash
npx ctx7 login
```
Or set the environment variable:
```powershell
$env:CONTEXT7_API_KEY = "your_key_here"
```
