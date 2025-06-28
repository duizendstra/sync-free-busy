---
title: "PBI: Define AI Collaboration Protocol for Bash Commands"
date: 2025-06-28T05:37:27Z
lastmod: 2025-06-28T05:37:27Z
draft: false
type: "pbi"
description: "Create a formal guide that defines a clear, robust, and error-free protocol for how the AI assistant should provide shell commands to the human Orchestrator."
tags: ["documentation", "process", "ai-collaboration", "standards", "cli"]
params:
  pbi_id: "PBI-SFB-DOCS-010"
  status: "Done"
  priority: "Critical"
---
## 1. PBI Goal & Justification
**Goal:** To establish a strict, documented protocol for how the AI assistant generates and presents shell commands, in order to eliminate recurring errors and improve workflow efficiency.
**Justification:** The collaboration has been repeatedly slowed by incorrect bash commands provided by the AI (e.g., improperly escaped `date` commands). This protocol will serve as a core, machine-enforceable rule set for the AI, ensuring its command-line assistance is always reliable and clear.

## 2. Acceptance Criteria

- **AC1:** A new guide is created at `docs/guides/ai-bash-protocol.md`.
- **AC2:** The guide specifies that when creating or overwriting a file, the AI **MUST** use the `cat <<EOF > filename` pattern.
- **AC3:** The guide specifies that any dynamic shell commands within a `cat` block (like `Sat Jun 28 05:37:27 AM UTC 2025`) **MUST NOT** be escaped, so they are correctly executed by the user's shell.
- **AC4:** The guide specifies that immediately after providing a command to create a *new script*, the AI **MUST** also provide the corresponding `chmod +x path/to/script.sh` command.
- **AC5:** The guide specifies that the AI **MUST** provide a brief, clear explanation of what each command does and why it is being used in the current context.
