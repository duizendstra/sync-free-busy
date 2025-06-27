---
title: "PBI: Implement Dependency Installation Task"
date: 2025-06-27T12:15:00Z
lastmod: 2025-06-27T12:15:00Z
draft: false
type: "pbi"
description: "Create a 'deps-update' task in the factory that automatically installs npm dependencies for all products."
tags: ["factory", "automation", "taskfile", "dependencies", "npm"]
params:
  pbi_id: "PBI-SFB-FACTORY-005"
  status: "To Do"
  priority: "High"
---
## 1. PBI Goal & Justification
**Goal:** To create a single, reproducible command for installing all necessary npm dependencies for all products within the project.
**Justification:** The current process requires developers to manually run \`npm install\` in multiple directories. This is error-prone and not automated. A factory task is needed to make dependency management robust and consistent.

## 2. Acceptance Criteria
- **AC1:** The \`deps-update\` task in \`factory/tasks/_update.yml\` is implemented.
- **AC2:** When \`task deps-update\` is run, it automatically finds all subdirectories within \`products/\` that contain a \`package.json\` file.
- **AC3:** The task runs \`npm install\` within each of these product directories.
- **AC4:** The task provides clear output to the user about which product's dependencies are being installed.
