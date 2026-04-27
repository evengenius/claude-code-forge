# MCP servers for __PROJECT_NAME__

Model Context Protocol servers extend Claude Code with project-specific capabilities.
This file documents the recommended set; edit `.mcp.json` to enable each.

## How to enable
Each server in `.mcp.json` is currently prefixed with `$_` (disabled). To enable:
1. Remove the `$_` prefix from the server's key.
2. Set the required env vars (see below) in your shell profile or `.env.local`.
3. Restart Claude Code or run `claude mcp list` to verify.

## Recommended servers

### filesystem (always-on, free)
Gives Claude scoped read/write access to the project directory through the official MCP server.
No env vars required.

### github (recommended for PR/issue work)
Lets Claude open/comment/review PRs without leaving the chat.
Requires: `GITHUB_TOKEN` (Personal Access Token with `repo` scope).

### postgres (recommended for DB-heavy projects)
Read-only schema introspection and safe queries against your DB.
Requires: `DATABASE_URL_READONLY` — use a DB user with `SELECT`-only grants.

### playwright (recommended for UI projects)
Lets Claude drive a real browser: take screenshots, run e2e flows, verify changes visually.
No env vars; the MCP boots its own Chromium.

### figma (optional, design-driven projects)
Lets Claude read frames, components, and design tokens from a Figma file.
Requires: `FIGMA_API_KEY`.

## Adding your own
Pattern is the same: `command` + `args` + optional `env`. Common candidates:
- `@modelcontextprotocol/server-slack` for team comms
- `@sentry/mcp-server` for error context
- `@cloudflare/mcp-server-cloudflare` for Workers/D1
- A custom stdio server for your private API

## Security note
MCP servers run with your full Claude Code permissions. Treat them like trusted dependencies:
read source before enabling, pin versions for production projects.
