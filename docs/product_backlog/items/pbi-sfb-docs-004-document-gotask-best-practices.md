---
title: "PBI: Document Go-Task YAML Parsing Best Practices"
date: 2025-06-27T11:02:44Z
lastmod: 2025-06-27T11:02:44Z
draft: false
type: "pbi"
description: "Create a formal 'Lessons Learned' document detailing the YAML parsing issues encountered with 'go-task' and establish a best practice to prevent them."
tags: ["documentation", "lessons-learned", "factory", "taskfile", "yaml", "best-practice"]
params:
  pbi_id: "PBI-SFB-DOCS-004"
  status: "To Do"
  priority: "High"
---
## 1. PBI Goal & Justification
**Goal:** To capture the critical, non-obvious knowledge gained from debugging 
----------------------------------------------------------------------------
          ✨ THEA Command Menu (Cognitively-Refined) ✨
----------------------------------------------------------------------------
Run `task <command>` to execute an action. e.g., `task test`

[1m--- 💻 Local Development (Inner Loop) ---[0m
    Tasks for the core cycle of coding and local iteration.

  [32mtask-start[0m   - ACTION:   Initiate a new task (e.g., `git checkout -b new-feature`).
  [32mcontext[0m      - VIEW:     Generate context for a specific goal (commit, pr, verify, export-*).
  [32mrun[0m          - ACTION:   Execute the application locally on your machine.
  [32mcommit[0m       - ACTION:   Save all local changes into a new commit (e.g., `git commit`).
  [32mtask-finish[0m  - ACTION:   Finalize a task (e.g., create a pull request).

[1m--- 📦 Build & Release Pipeline (Outer Loop) ---[0m
    Tasks for building, testing, and deploying the application.

  [32mbuild[0m        - ACTION:   Compile source code and create a build artifact.
  [32mtest[0m         - ACTION:   Run the application's full suite of automated tests.
  [32manalyze[0m      - ACTION:   Inspect code for quality, style, and vulnerabilities.
  [32mrelease[0m      - ACTION:   Create and publish a new versioned release artifact.
  [32mdeploy[0m       - ACTION:   Deploys the application to the cloud.

[1m--- ☁️ Infrastructure & Utilities ---[0m
    Tasks for managing cloud resources and local housekeeping.

  [32mprovision[0m    - GUIDE:    Shows setup checklist for cloud infrastructure.
  [32mverify[0m       - VIEW:     Check that provisioned infrastructure is healthy.
  [31mdestroy[0m      - ACTION:   Shows checklist for tearing down all infrastructure.
  [32mdeps-update[0m  - ACTION:   Update third-party dependencies to their latest versions.
  [32mclean[0m        - ACTION:   Remove all local temporary files and build artifacts. YAML parsing errors and to establish a clear, robust standard for writing task commands.
**Justification:** We have repeatedly encountered  errors caused by the YAML parser's handling of colons () in simple  commands. This knowledge is currently tribal. Documenting it will save significant future debugging time and provide a clear rule for both human developers and AI assistants when generating  code.

## 2. Acceptance Criteria
- **AC1:** A new document is created at .
- **AC2:** The document clearly describes the problem: how a colon in an  statement can cause a 
----------------------------------------------------------------------------
          ✨ THEA Command Menu (Cognitively-Refined) ✨
----------------------------------------------------------------------------
Run `task <command>` to execute an action. e.g., `task test`

[1m--- 💻 Local Development (Inner Loop) ---[0m
    Tasks for the core cycle of coding and local iteration.

  [32mtask-start[0m   - ACTION:   Initiate a new task (e.g., `git checkout -b new-feature`).
  [32mcontext[0m      - VIEW:     Generate context for a specific goal (commit, pr, verify, export-*).
  [32mrun[0m          - ACTION:   Execute the application locally on your machine.
  [32mcommit[0m       - ACTION:   Save all local changes into a new commit (e.g., `git commit`).
  [32mtask-finish[0m  - ACTION:   Finalize a task (e.g., create a pull request).

[1m--- 📦 Build & Release Pipeline (Outer Loop) ---[0m
    Tasks for building, testing, and deploying the application.

  [32mbuild[0m        - ACTION:   Compile source code and create a build artifact.
  [32mtest[0m         - ACTION:   Run the application's full suite of automated tests.
  [32manalyze[0m      - ACTION:   Inspect code for quality, style, and vulnerabilities.
  [32mrelease[0m      - ACTION:   Create and publish a new versioned release artifact.
  [32mdeploy[0m       - ACTION:   Deploys the application to the cloud.

[1m--- ☁️ Infrastructure & Utilities ---[0m
    Tasks for managing cloud resources and local housekeeping.

  [32mprovision[0m    - GUIDE:    Shows setup checklist for cloud infrastructure.
  [32mverify[0m       - VIEW:     Check that provisioned infrastructure is healthy.
  [31mdestroy[0m      - ACTION:   Shows checklist for tearing down all infrastructure.
  [32mdeps-update[0m  - ACTION:   Update third-party dependencies to their latest versions.
  [32mclean[0m        - ACTION:   Remove all local temporary files and build artifacts. parsing failure, especially in included files.
- **AC3:** The document explains why the  key, while technically correct, was not a sufficiently robust solution in our context.
- **AC4:** The document establishes the **official THEA/SyncFreeBusy standard**: For simple  commands, avoid colons entirely (e.g., use "INFO - " instead of "INFO:"). For complex commands that require colons, wrap the entire command string in single quotes to ensure it is treated as a literal.
- **AC5:** The document explicitly states that this standard must be incorporated into any future AI system prompts () that generate  code.
