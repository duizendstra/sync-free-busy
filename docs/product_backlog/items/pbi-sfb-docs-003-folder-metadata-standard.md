---
title: "PBI: Document and Implement Folder-Level Metadata Standard"
date: 2025-06-27T10:40:30Z
lastmod: 2025-06-27T10:40:30Z
draft: false
type: "pbi"
description: "Formalize the rule that each significant directory must contain a metadata file (e.g., README.md) with frontmatter describing the folder's purpose. Update the style guide to reflect this."
tags: ["documentation", "standards", "style-guide", "metadata", "project-structure"]
params:
  pbi_id: "PBI-SFB-DOCS-003"
  status: "To Do"
  priority: "Medium"
---
## 1. PBI Goal & Justification
**Goal:** To formalize and document the standard that every significant directory in the project should contain a `README.md` with YAML frontmatter that describes the directory's purpose.
**Justification:** This standard makes the project self-documenting and easier to navigate for both humans and automated tools. It closes a gap in our current documentation standards, ensuring that the project's structure remains clear and maintainable as it grows.

## 2. Acceptance Criteria
- **AC1:** A new project style guide is created (or an existing one is updated) to include the "Folder-Level Metadata" rule.
- **AC2:** The rule specifies that the metadata file must be named `README.md`.
- **AC3:** The rule defines the minimum required frontmatter for these folder-level READMEs (e.g., a `title` and `summary`).
- **AC4:** As a proof-of-concept, a `README.md` with the specified frontmatter is added to at least two key directories (e.g., `products/` and `factory/`).
