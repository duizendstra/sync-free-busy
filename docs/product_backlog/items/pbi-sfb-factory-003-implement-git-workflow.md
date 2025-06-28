---
title: "PBI: Implement Guided Git Workflow Tasks"
date: 2025-06-27T10:51:32Z
lastmod: 2025-06-28T08:22:10Z
draft: false
type: "pbi"
description: "Implement the 'task-start', 'commit', and 'task-finish' commands with interactive shell scripts to standardize the Git workflow."
tags: ["factory", "automation", "taskfile", "git-workflow", "scripts"]
params:
  pbi_id: "PBI-SFB-FACTORY-003"
  status: "Done"
  priority: "Medium"
---
## 1. PBI Goal & Justification
**Goal:** To streamline common Git operations and enforce a consistent branching and commit message strategy through guided, interactive scripts.
**Justification:** Manually creating branches, writing conventional commits, and creating PRs can be error-prone. Scripting this workflow reduces cognitive load and improves consistency.

## 2. Acceptance Criteria
- **AC1:** The `task-start` command is implemented with a script that prompts for a branch name and creates it.
- **AC2:** The `commit` command is implemented with a script that helps the user stage files and write a conventional commit message.
- **AC3:** The `task-finish` command is implemented with a script that pushes the branch and uses the 'gh' CLI to open a pull request.
