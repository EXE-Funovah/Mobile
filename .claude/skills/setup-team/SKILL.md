---
name: setup-team
description: Check the Windows Claude Code and Flutter developer setup for this repository. Use when onboarding a teammate or diagnosing missing project tools.
disable-model-invocation: true
allowed-tools: Bash(pwsh -NoProfile -File scripts/setup-claude.ps1*)
---

# Team setup

1. Run:

   ```powershell
   pwsh -NoProfile -File scripts/setup-claude.ps1
   ```

2. Report missing prerequisites and the exact next steps printed by the script.
3. Explain that `.mcp.json` already shares Context7 and Dart MCP. Ask the user to approve the project MCP servers when Claude Code prompts.
4. Do not install software or add MCP servers unless the user explicitly approves the specific action.

## Optional MCP integrations

Offer only integrations relevant to the project. Add them with local scope so personal credentials and preferences are not committed.

- Sentry:

  ```powershell
  claude mcp add --transport http --scope local sentry https://mcp.sentry.dev/mcp
  ```

- Firebase:

  ```powershell
  claude mcp add --transport stdio --scope local firebase -- npx -y firebase-tools@latest mcp --only auth,firestore,storage
  ```

- Playwright for Flutter Web:

  ```powershell
  claude mcp add --transport stdio --scope local playwright -- npx -y @playwright/mcp@latest
  ```

- GitHub: ask the user to create a fine-grained PAT, then add the remote GitHub MCP with the PAT passed as an authorization header. Never write the PAT into a tracked file or chat output.

