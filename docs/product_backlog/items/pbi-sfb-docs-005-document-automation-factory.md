---
title: "PBI: Create Developer Documentation for the Automation Factory"
date: $(date -u +"%Y-%m-%dT%H:%M:%SZ")
lastmod: $(date -u +"%Y-%m-%dT%H:%M:%SZ")
draft: false
type: "pbi"
description: "Create a comprehensive guide for developers explaining the philosophy, structure, and usage of the project's automation factory."
tags: ["documentation", "factory", "onboarding", "automation", "guide"]
params:
  pbi_id: "PBI-SFB-DOCS-005"
  status: "Done"
  priority: "Medium"
---
## 1. PBI Goal & Justification
**Goal:** To demystify the automation framework for current and future developers, making it easy to use, maintain, and extend.
**Justification:** The factory, while powerful, is a custom framework. Without clear documentation, it remains a "black box" that is difficult to modify or debug. This guide is a critical piece of contributor onboarding and long-term project maintainability.

## 2. Acceptance Criteria
- **AC1:** A new document is created at `docs/guides/factory-guide.md`.
- **AC2:** The guide clearly explains the "Menu / Workflow / Action" architectural pattern (`Taskfile.yml` -> `factory/tasks/*.yml` -> `factory/scripts/*.sh`).
- **AC3:** The guide provides a step-by-step tutorial on how to add a new command to the factory, following the established pattern.
- **AC4:** The guide explains the role of key tools used in the factory (e.g., `go-task`, `gum`).
- **AC5:** The root `README.md` is updated with a link to this new guide for developers who want to understand the automation framework.
