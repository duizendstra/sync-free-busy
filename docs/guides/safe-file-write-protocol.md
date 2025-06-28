---
title: "Playbook: The Safe Command Protocol"
date: DATE_PLACEHOLDER
lastmod: DATE_PLACEHOLDER
draft: false
type: "playbook"
description: "The official, mandatory protocol for safely generating and presenting shell commands to prevent all interpretation errors."
tags: ["playbook", "protocol", "standards", "factory", "shell", "best-practice", "llm-interaction"]
---
# Playbook: The Safe Command Protocol

This playbook defines the mandatory, two-part protocol for generating and presenting shell commands to ensure they are safe, efficient, and error-free. It covers both the *content* of the command and its *presentation*.

## Part 1: The File-Write Protocol (The "Content")

### 1.1. The Problem: The Fragility of Unquoted Here-Documents

Our previous standard for writing files used the `cat <<EOF` syntax. This method is inherently fragile because an unquoted delimiter (`EOF`) instructs the shell to perform expansion on the block's content, leading to frequent errors.

### 1.2. The Solution: A Two-Stage "Write then Modify" Protocol

All file-writing operations **MUST** follow this robust, two-stage protocol:

1.  **Write Static Content:** Use a **quoted** here-document delimiter (`cat <<'EOF'`) to write all static file content, using placeholders for dynamic data.
2.  **Inject Dynamic Data:** Use a separate, targeted command like `sed` to replace the placeholders with their actual dynamic values.
3.  **Combine for Efficiency:** These two stages **MUST** be combined into a single, atomic command line using a subshell and the `&&` operator.

## Part 2: The Command Presentation Protocol (The "Presentation")

### 2.1. The Problem: Unintended Markdown Rendering

An LLM may "helpfully" format its response using markdown (e.g., making text bold). When the response is a shell command, this formatting corrupts the command and makes it unusable.

### 2.2. The Solution: The Fenced Code Block Mandate

To solve this, all AI-generated shell commands **MUST** be presented using a strict, two-part structure:

1.  **The Explanation:** All explanatory text, rationale, and conversational dialogue **MUST** be outside the command block.
2.  **The Command Block:** The shell command(s) to be executed **MUST** be enclosed in a markdown fenced code block (```bash). This block must contain only the literal, copy-paste-safe command(s).

### 2.3. Correct Example of AI Output

**<Persona>** "This is the explanation of what the command does and why."

```bash
(cat <<'EOF' > file.md
...
