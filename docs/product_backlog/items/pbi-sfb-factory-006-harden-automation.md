---
title: "PBI: Harden and Enhance the Automation Factory"
date: 2025-06-28T05:36:34Z
lastmod: 2025-06-28T05:36:34Z
draft: false
type: "pbi"
description: "Perform a full, end-to-end test of every command in the automation factory, fixing bugs, improving robustness, and adding new capabilities like parameterized execution."
tags: ["factory", "automation", "testing", "hardening", "bugfix", "enhancement"]
params:
  pbi_id: "PBI-SFB-FACTORY-006"
  status: "To Do"
  priority: "High"
---
## 1. PBI Goal & Justification
**Goal:** To transition the automation factory from a functional prototype into a production-grade, robust, and more flexible tool for all developers.
**Justification:** Real-world usage has revealed several bugs and limitations in our core workflow scripts (e.g., `task-start`, `task-finish`, `context`). A dedicated effort is required to fix these issues and add requested features to ensure a stable and efficient developer experience.

## 2. Acceptance Criteria

- **AC1 (Fix `context` task):** The `factory/scripts/context.sh` script is fixed. The menu options that point to non-existent `export_*.sh` scripts (`Export: Code Only`, `Export: Documentation Only`, `Export: Automation Only`) are removed to prevent errors.

- **AC2 (Enhance `task-start`):** The `task-start` command is enhanced to support both interactive (current) and non-interactive, parameterized execution. For example, `task task-start -- docs SFB-010 my-feature` should work without prompts.

- **AC3 (Harden `task-start`):** The `factory/scripts/start_task.sh` script is made more robust. It must correctly detect **untracked files** in the working directory and prompt the user to stash them, preventing the `git checkout` command from failing.

- **AC4 (Harden `task-finish`):** The `factory/scripts/task_finish.sh` script is made more robust. It must correctly use `git push --force-with-lease` to automatically handle cases where a local branch has been rebased and has diverged from its remote counterpart.

- **AC5 (Verify All Commands):** Every other command in the `Taskfile.yml` menu is tested end-to-end to ensure it functions as described in the help text. Any discovered bugs are fixed.
