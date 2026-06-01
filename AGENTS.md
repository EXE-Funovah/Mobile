# Mascoteach Mobile Agent Guide

Flutter app for students and teachers. Keep agent work focused and cheap.

## Priorities

1. Correctness.
2. Small, maintainable changes.
3. Concise communication and low token usage.

## Workflow

- Inspect relevant code and tests before editing. Do not guess schemas or architecture.
- Prefer targeted searches and bounded reads. Skip generated output such as `build/` and `.dart_tool/`.
- Make the smallest runnable diff. Avoid unrelated refactors.
- Preserve existing Riverpod, GoRouter, and Dio patterns unless a change is justified.
- Add or update tests when behavior changes.
- On Windows, use PowerShell syntax.

## Verification

After Dart changes, run:

```powershell
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
```

Report blocked checks honestly if Flutter or Dart is unavailable.

## Safety

- Ask before package installs, upgrades, new MCP servers, network-heavy commands, or destructive Git/workspace actions.
- Never expose secrets in files, logs, or chat.
- Verify changing facts such as APIs, versions, schemas, and deprecations with Context7 or official docs. Cite the URL.

## Claude Code

Claude-specific onboarding, MCP configuration, and lazy skills live in `CLAUDE.md`, `.mcp.json`, and `.claude/`.
