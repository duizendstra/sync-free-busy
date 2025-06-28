---
title: "PBI: Add 'factory' Branch Type to 'task-start'"
date: 2025-06-28T06:51:30Z
lastmod: 2025-06-28T06:51:30Z
draft: false
type: "pbi"
description: "The 'task-start' script is missing 'factory' as an option in its interactive branch type selector. This must be added to align the tool with our established development workflow."
tags: ["factory", "automation", "workflow", "bugfix", "tooling"]
params:
  pbi_id: "PBI-SFB-FACTORY-008"
  status: "To Do"
  priority: "High"
---
## 1. PBI Goal & Justification
**Goal:** To fix the  script so that it includes "factory" as a valid, selectable branch type, aligning the tool with our established workflow.
**Justification:** The tool's current omission of the "factory" type creates friction in the development process, forcing developers to use an incorrect branch type and breaking our naming conventions. This is a high-priority bug fix for a core workflow tool.

## 2. Acceptance Criteria
- **AC1:** The  command within the                                         
 [38;5;212m┌────────────────────────────────────┐[0m 
 [38;5;212m│[0m                                    [38;5;212m│[0m 
 [38;5;212m│[0m  ⚠️ You have uncommitted changes.  [38;5;212m│[0m 
 [38;5;212m│[0m                                    [38;5;212m│[0m 
 [38;5;212m└────────────────────────────────────┘[0m 
                                        
Aborted by user. Please commit or stash your changes. script is updated to include "factory" in its list of options.
