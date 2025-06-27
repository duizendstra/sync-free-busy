---
title: "PBI: Refactor and Stub Out Factory Tasks for Apps Script"
date: 2025-06-27T10:34:30Z
lastmod: 2025-06-27T10:34:30Z
draft: false
type: "pbi"
description: "Refactor the entire factory automation layer by removing external scripts and stubbing out all task files (*.yml) to be specific to the SyncFreeBusy project."
tags: ["maintenance", "refactor", "cleanup", "technical-debt", "factory", "taskfile"]
params:
  pbi_id: "PBI-SFB-MAINT-001"
  status: "To Do"
  priority: "High"
---
## 1. PBI Goal & Justification
**Goal:** To create a clean, functional, and minimal factory skeleton by adapting the existing automation framework to the specific needs of the Apps Script-based SyncFreeBusy project.
**Justification:** The current factory is configured for a Go project, making it unusable. Instead of deleting the valuable task structure, we will refactor it, removing external script dependencies and converting irrelevant tasks into informational stubs. This provides a clean and complete foundation for implementing our project-specific automation.

## 2. Acceptance Criteria
- **AC1:** The `thea/` directory and all non-PBI `docs/` subdirectories are removed from the repository.
- **AC2:** The `factory/scripts/` directory is removed entirely, in favor of placing simple logic directly within the `*.yml` task files.
- **AC3:** All task files in `factory/tasks/` are modified to either be informational stubs (for irrelevant tasks like `build`, `run`) or are prepared for direct implementation (for relevant tasks like `deploy`, `analyze`).
- **AC4:** The root `README.md` is simplified to focus on the SyncFreeBusy project and its specific structure.
