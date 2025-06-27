---
title: "PBI: Stub Out Irrelevant Factory Tasks"
date: 2025-06-27T10:51:32Z
lastmod: 2025-06-27T10:51:32Z
draft: false
type: "pbi"
description: "Convert all factory tasks that are not applicable to an Apps Script project into informational stubs."
tags: ["factory", "automation", "taskfile", "maintenance"]
params:
  pbi_id: "PBI-SFB-FACTORY-002"
  status: "To Do"
  priority: "Low"
---
## 1. PBI Goal & Justification
**Goal:** To complete the visual menu of the factory by providing clear, informational messages for tasks that do not apply to this project.
**Justification:** This prevents user confusion and clarifies the scope of the factory's capabilities for an Apps Script project. It's a small but important part of creating a clean user experience.

## 2. Acceptance Criteria
- **AC1:** The `build` task is updated to print an informational message (e.g., "Not applicable for Apps Script").
- **AC2:** The `run` task is updated to print an informational message.
- **AC3:** The `provision`, `verify`, and `destroy` tasks are updated to print informational messages, perhaps linking to the Google Cloud Console.
