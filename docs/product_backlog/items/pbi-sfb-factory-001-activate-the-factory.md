---
title: "PBI: Activate the Factory for SyncFreeBusy"
date: 2025-06-28T08:22:10Z
lastmod: 2025-06-28T08:22:10Z
draft: false
type: "pbi"
description: "Adapt the 'deploy' and 'analyze' tasks in the factory to work with the JavaScript-based SyncFreeBusy products."
tags: ["factory", "automation", "taskfile", "deploy", "analyze", "clasp", "eslint"]
params:
  pbi_id: "PBI-SFB-FACTORY-001"
  status: "Done"
  priority: "High"
---
## 1. PBI Goal & Justification
**Goal:** To make the core development loop (linting and deploying) functional for the SyncFreeBusy project.
**Justification:** The factory's automation is currently configured for a Go project and is unusable. Adapting the `deploy` and `analyze` tasks is the highest priority for enabling an efficient development workflow.

## 2. Acceptance Criteria
- **AC1:** The `deploy` task in `factory/tasks/_deploy.yml` is updated to interactively prompt for a product (`direct-link` or `availability-hub`) and run `clasp push` in the corresponding directory.
- **AC2:** The `analyze` task in `factory/tasks/_analyze.yml` is updated to run `eslint` on the source code of a selected product.
- **AC3:** Basic `.eslintrc.json` configuration files are added to each product's directory.
- **AC4:** The root `Taskfile.yml` correctly proxies the commands to the factory.
