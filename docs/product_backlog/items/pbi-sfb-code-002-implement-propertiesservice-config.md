---
title: "PBI: Implement User-Friendly Configuration via PropertiesService"
date: $(date -u +"%Y-%m-%dT%H:%M:%SZ")
lastmod: $(date -u +"%Y-%m-%dT%H:%M:%SZ")
draft: false
type: "pbi"
description: "Replace the hardcoded CONFIG object with a system that uses Apps Script's PropertiesService, allowing users to configure the script without editing code."
tags: ["refactor", "configuration", "syncfreebusy", "ux"]
params:
  pbi_id: "PBI-SFB-CODE-002"
  status: "To Do"
  priority: "Medium"
---
## 1. PBI Goal & Justification
**Goal:** To decouple configuration from the source code, providing a more user-friendly and robust way for users to set up the SyncFreeBusy products.
**Justification:** Requiring users to edit the source code to set calendar IDs is error-prone and a poor user experience. `PropertiesService` is the standard Apps Script way to handle user-level configuration.

## 2. Acceptance Criteria
- **AC1:** The hardcoded `CONFIG` object is removed from both products.
- **AC2:** New utility functions are created to set and get configuration values from `PropertiesService`.
- **AC3:** The main `runSync` function is updated to read its configuration from `PropertiesService`.
- **AC4:** The product `README.md` files (from PBI-SFB-DOCS-001) are updated to explain how to use the new configuration method.
