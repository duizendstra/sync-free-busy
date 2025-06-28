---
title: "Playbook: The AI-Orchestrator Interaction Protocol"
date: 2025-06-28T07:55:16Z
lastmod: 2025-06-28T07:55:16Z
draft: false
type: "playbook"
description: "The single source of truth defining the mandatory protocols for all interactions between the AI Assistant and the human Orchestrator."
tags: ["playbook", "protocol", "standards", "llm-interaction", "best-practice", "critical"]
---
# Playbook: The AI-Orchestrator Interaction Protocol

## 1. Philosophy & Goal

This document defines the strict, mandatory protocol for all interactions to ensure every exchange is **unambiguous, efficient, and error-free**. Its goal is to eliminate cognitive load for the Orchestrator and prevent entire classes of errors.

## 2. The AI's Prime Directives

These are the foundational rules that govern all AI Assistant behavior. They supersede all other protocols.

1.  **Maintain State Awareness:** The AI **MUST** always know the current Git branch. Before proposing any file modification or commit, it **MUST** verify it is not on the `main` branch. If it is on `main`, its only permitted suggestion is `task task-start`.
2.  **Default to Highest Efficiency:** When a command has multiple modes of execution (e.g., interactive and parameterized), the AI **MUST** default to proposing the most efficient, non-interactive version.
3.  **Adhere to the Grammar:** All responses **MUST** strictly follow the interaction grammar defined below.

## 3. The Grammar of Interaction: Explicit Response Types

Every response from the AI Assistant **MUST** begin with a clear, persona-driven statement of intent, followed by one or more explicitly typed response blocks.

### 3.1. The Command Block

- **Mandate:** For any command to be executed in the shell. It **MUST** be enclosed in a ```bash fenced code block and contain only the literal, copy-paste-safe command(s).

### 3.2. The File Block

- **Mandate:** For creating or overwriting a file. It **MUST** use the two-stage, single-line "Write then Modify" protocol (`(cat <<'EOF' > ...) && sed ...`).

### 3.3. The Verification Block

- **Mandate:** For providing context for `QA-Bot` to verify. It **MUST** be enclosed in a ```diff fenced code block and contain the full output of `task context verify`.

### 3.4. The Question Block

- **Mandate:** For asking the Orchestrator a question. It **MUST** be a standard markdown block quote.
