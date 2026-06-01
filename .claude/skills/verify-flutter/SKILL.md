---
name: verify-flutter
description: Validate Flutter changes with formatting, static analysis, and tests. Use after editing Dart files or before claiming a Flutter task is complete.
disable-model-invocation: true
allowed-tools: Bash(dart format --output=none --set-exit-if-changed lib test) Bash(flutter analyze) Bash(flutter test)
---

# Verify Flutter

Run these commands from the repository root:

```powershell
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
```

Report the exact failing command and relevant output if any command fails. Do not claim verification passed when Flutter or Dart is missing.

