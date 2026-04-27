{
  "$comment": "MCP servers for __PROJECT_NAME__. Uncomment the blocks you want to use. After editing, run 'claude mcp list' to verify.",
  "mcpServers": {
    "$_filesystem": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "."]
    },
    "$_github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": { "GITHUB_PERSONAL_ACCESS_TOKEN": "${GITHUB_TOKEN}" }
    },
    "$_postgres": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-postgres", "${DATABASE_URL_READONLY}"]
    },
    "$_playwright": {
      "command": "npx",
      "args": ["-y", "@playwright/mcp@latest"]
    },
    "$_figma": {
      "command": "npx",
      "args": ["-y", "figma-developer-mcp", "--stdio"],
      "env": { "FIGMA_API_KEY": "${FIGMA_API_KEY}" }
    }
  }
}
