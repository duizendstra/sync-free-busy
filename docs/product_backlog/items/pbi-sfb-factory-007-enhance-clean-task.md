---
title: "PBI: Enhance 'task clean' for Post-Merge Synchronization"
date: $(date -u +"%Y-%m-%dT%H:%M:%SZ")
lastmod: $(date -u +"%Y-%m-%dT%H:%M:%SZ")
draft: false
type: "pbi"
description: "Enhance the 'task clean' command to become the standard post-PR-merge cleanup task, automating the switch to main, pulling changes, and deleting the merged branch."
tags: ["factory", "automation", "workflow", "efficiency", "cleanup"]
params:
  pbi_id: "PBI-SFB-FACTORY-007"
  status: "Done"
  priority: "High"
---
## 1. PBI Goal & Justification
**Goal:** To make the development workflow more efficient by enhancing the `task clean` command to automate the manual steps required after a pull request is merged.
**Justification:** The current post-merge process (switching to main, pulling, deleting the old branch) is manual, repetitive, and error-prone. Automating this into a single, memorable command will reduce friction and save developer time.

## 2. Acceptance Criteria
- **AC1:** The `factory/scripts/clean.sh` script is updated to first switch to the `main` branch.
- **AC2:** The script then performs a `git pull` to synchronize with the remote `main` branch.
- **AC3:** The script then proceeds with its original cleanup tasks, including the deletion of locally merged branches.
- **AC4:** The user-facing descriptions and messages for the `task clean` command are updated to reflect its new, expanded role as a post-merge synchronization task.
