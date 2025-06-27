---
title: "PBI: Refactor Product Code into a Shared Library"
date: $(date -u +"%Y-%m-%dT%H:%M:%SZ")
lastmod: $(date -u +"%Y-%m-%dT%H:%M:%SZ")
draft: false
type: "pbi"
description: "Refactor the monolithic Code.gs files in both products into a modular structure with a shared library for core logic and error handling."
tags: ["refactor", "architecture", "syncfreebusy", "code-quality"]
params:
  pbi_id: "PBI-SFB-CODE-001"
  status: "To Do"
  priority: "High"
---
## 1. PBI Goal & Justification
**Goal:** To improve the maintainability, readability, and robustness of the SyncFreeBusy codebase by eliminating code duplication and introducing a clean, modular architecture.
**Justification:** The current `Code.gs` files are monolithic, contain duplicated logic, and have minimal error handling. This makes them difficult to maintain and extend.

## 2. Acceptance Criteria
- **AC1:** Each product (`direct-link`, `availability-hub`) contains a `core/` directory.
- **AC2:** Shared logic (e.g., fetching events, creating blocking events, calculating time windows) is extracted into functions within the `core/` library.
- **AC3:** A structured error handling utility is created and used throughout the library.
- **AC4:** The main `Code.gs` file in each product is simplified to be an orchestrator that calls the library functions.
- **AC5:** The refactored code maintains all original functionality.
