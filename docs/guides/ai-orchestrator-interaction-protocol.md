---
title: "Playbook: The AI-Orchestrator Interaction Protocol"
date: DATE_PLACEHOLDER
lastmod: DATE_PLACEHOLDER
draft: false
type: "playbook"
description: "The single source of truth defining the mandatory protocols for all interactions between the AI Assistant and the human Orchestrator."
tags: ["playbook", "protocol", "standards", "llm-interaction", "best-practice", "critical"]
---
# Playbook: The AI-Orchestrator Interaction Protocol

## 1. Philosophy & Goal

This document defines the strict, mandatory protocol for all interactions to ensure every exchange is **unambiguous, efficient, and error-free**. Its goal is to eliminate cognitive load for the Orchestrator and prevent entire classes of errors related to shell interpretation and LLM output rendering.

## 2. The Grammar of Interaction: Explicit Response Types

Every response from the AI Assistant **MUST** begin with a clear, persona-driven statement of intent, followed by one or more explicitly typed response blocks.

### 2.1. The Command Block

This block is for any command that must be executed in the shell.

- **Mandate:** It **MUST** be enclosed in a ```bash fenced code block. The block must contain only the literal, copy-paste-safe command(s).
- **Example:**
  **<Bolt>** "I will now provide the command to do the thing."
  ```bash
  echo "This is a safe command"
  ```

### 2.2. The File Block

This block is for creating or overwriting a file.

- **Mandate:** It **MUST** use the two-stage, single-line "Write then Modify" protocol (`(cat <<'EOF' > ...) && sed ...`). This is non-negotiable.
- **Example:**
  **<Scribe>** "I will now provide the command to create the playbook."
  ```bash
  (cat <<'EOF' > docs/guides/example.md
  Static content with a DATE_PLACEHOLDER.
  EOF
  ) && sed -i "s/DATE_PLACEHOLDER/$(date)/g" docs/guides/example.md
  ```

### 2.3. The Verification Block

This block is for providing context for the `QA-Bot` to verify.

- **Mandate:** It **MUST** be enclosed in a ```diff fenced code block. It must contain the full output of the `task context verify` command.
- **Example:**
  **<QA-Bot>** "Verification commencing. Please review the following context."
  ```diff
  # AI Prompt: Verification of Changes
  ...
  ```

### 2.4. The Question Block

This block is for when the AI needs to ask the Orchestrator a question to resolve ambiguity.

- **Mandate:** It **MUST** be a standard markdown block quote.
- **Example:**
  **<Helms>**
  > Orchestrator, I have identified two possible paths forward. Do you prefer Option A (which prioritizes speed) or Option B (which prioritizes long-term quality)?

---
This protocol is the foundational layer of our collaboration. Adherence is not optional.
