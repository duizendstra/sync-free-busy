---
title: "PBI: Define and Implement Safe File Write Protocol"
date: 2025-06-28T06:54:05Z
lastmod: 2025-06-28T06:54:05Z
draft: false
type: "pbi"
description: "Define and implement a new, robust, two-stage protocol for writing files from shell scripts to prevent all shell interpretation errors."
tags: ["process", "standards", "bugfix", "factory", "shell"]
params:
  pbi_id: "PBI-SFB-DOCS-011"
  status: "To Do"
  priority: "Critical"
---
## 1. PBI Goal & Justification
**Goal:** To eliminate the entire class of bash errors caused by the shell misinterpreting content within `cat <<EOF` blocks.
**Justification:** The project has been repeatedly slowed by frustrating and difficult-to-debug shell errors. The current file-writing method is fragile. A new, robust protocol is our highest priority for improving workflow efficiency and stability.

## 2. Acceptance Criteria
- **AC1:** A new protocol is documented, requiring a two-stage process:
    1. Use a quoted here-document (`cat <<'EOF'`) to write all static file content, using placeholders for dynamic data.
    2. Use a separate command (e.g., `sed`) to replace the placeholders with the dynamic data.
- **AC2:** This PBI document itself serves as the official guide for this new protocol.
- **AC3:** All AI personas are updated to use this new protocol exclusively for all future file creation and modification tasks.
