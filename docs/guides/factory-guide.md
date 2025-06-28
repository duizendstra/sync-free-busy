---
title: "Guide: The Automation Factory"
date: DATE_PLACEHOLDER
lastmod: DATE_PLACEHOLDER
draft: false
type: "guide"
description: "A developer's guide to understanding, using, and extending the project's automation framework."
tags: ["guide", "factory", "automation", "taskfile", "onboarding"]
---
# Guide: The Automation Factory

## 1. Philosophy: The "Menu / Workflow / Action" Pattern

The automation factory is designed to be powerful yet simple to use. It follows a strict architectural pattern that separates the user-facing menu from the implementation logic. This makes the framework easy to understand for new developers while keeping it organized and maintainable.

The pattern has three layers:

1.  **The Menu (`Taskfile.yml`):** This is the single, public entry point for all developers. It's a clean, high-level list of available commands. It contains no logic itself; it only delegates to the next layer.
2.  **The Workflow (`factory/tasks/*.yml`):** These files define the high-level workflow for a specific command. They might contain simple shell commands or delegate complex logic to a script.
3.  **The Action (`factory/scripts/*.sh`):** These are the shell scripts that perform the actual work. They contain the complex logic, safety checks, and user interactions.

## 2. How to Use the Factory

To see a list of all available commands, simply run `task` with no arguments from the project root:

```bash
task```

To execute a command, use `task <command>`. For example:

```bash
task test```

Many commands can also be run non-interactively by passing arguments after a `--`. For example:

```bash
task task-start -- docs PBI-123 my-new-feature
```

## 3. How to Add a New Command

Adding a new command requires following the "Menu / Workflow / Action" pattern. Let's say we want to add a new command called `hello`.

**Step 1: Create the Action Script (The "Action")**
Create a new script in `factory/scripts/hello.sh` that performs the desired action.

```bash
#!/bin/bash
# factory/scripts/hello.sh
set -e
echo "Hello, World!"
```
Make sure to make it executable: `chmod +x factory/scripts/hello.sh`

**Step 2: Create the Workflow Task (The "Workflow")**
Create a new YAML file in `factory/tasks/_hello.yml`. This file will call your script.

```yaml
# factory/tasks/_hello.yml
version: '3'
tasks:
  hello:
    desc: "A new hello world command."
    silent: true
    cmds:
      - ./factory/scripts/hello.sh {{.CLI_ARGS}}
```

**Step 3: Add to the Menu (The "Menu")**
Finally, add your new task to the main `Taskfile.yml`. First, include the new task file, then add the facade task.

```yaml
# Taskfile.yml

# ... other includes
includes:
  _hello: ./factory/tasks/_hello.yml
# ...

tasks:
  # ... other tasks
  hello:
    desc: "ACTION: Prints a hello world message."
    cmds:
      - task: _hello:hello
        vars: { CLI_ARGS: '{{.CLI_ARGS}}' }
  # ...
