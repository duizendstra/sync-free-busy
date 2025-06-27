#!/bin/bash
# scripts/commit.sh (v6 - Fully Robust)
#
# WHY:  A self-contained script to handle commits. It does not call other scripts.
# WHAT: If a commit message is provided via arguments (e.g., -m "msg"), it stages
#       all changes and then commits. If no arguments are provided, it also
#       stages all changes and then generates context for an LLM.
# HOW:  Checks for argument count ($#) and contains all logic within this file.

set -e

# --- Configuration ---
MAIN_BRANCH="main"
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
OUTPUT_FILE="contextvibes_status.md"
PROMPT_FILE="docs/prompts/generate-commit-message.md"

# --- Safety Check: Prevent direct commits to the main branch ---
if [ "$CURRENT_BRANCH" == "$MAIN_BRANCH" ]; then
  echo "❌ ERROR: Direct commits to the '$MAIN_BRANCH' branch are not allowed."
  echo "   Please use 'task task-start -- <branch-name>' to create a feature branch."
  exit 1
fi

# --- Main Logic: Check for a manually provided commit message ---
if [ "$#" -eq 0 ]; then
  # --- AI-ASSISTED WORKFLOW (No arguments provided) ---
  echo "--> No commit message provided. Generating context for AI..."
  echo "    (A copy of this context will also be saved to '$OUTPUT_FILE')"

  # Stage all changes first so the diff is accurate for the LLM.
  git add .

  # Group all context-generating commands to pipe their output to `tee`.
  {
    cat "$PROMPT_FILE"
    echo ""
    echo "---"
    echo "## Uncommitted Local Changes (Now Staged)"
    echo ""
    echo '```'
    git status
    echo '```'
    echo ""
    echo "---"
    echo "## Diff of Staged Changes"
    echo ""
    echo '```diff'
    git diff --staged
    echo '```'
  } | tee "$OUTPUT_FILE"
  
  echo ""
  echo "--> AI ACTION REQUIRED:"
  echo "    Review the context printed above, formulate a 'git commit ...' command, and propose it for approval."

else
  # --- MANUAL/AI-EXECUTED WORKFLOW (Arguments were provided) ---
  echo "--> Commit message provided. Committing changes now..."
  
  # *** THIS IS THE CORRECTED LOGIC ***
  # We must stage all modified/untracked files here to ensure they are
  # included in the commit.
  echo "--> Staging all changes..."
  git add .
  
  echo "--> Committing staged changes..."
  # "$@" passes all arguments from the Taskfile (e.g., -m "message") to git commit.
  git commit "$@"
  
  echo "✅ Commit successful."
fi