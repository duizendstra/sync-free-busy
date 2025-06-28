#!/bin/bash
# factory/scripts/context_helpers/context_verify.sh
#
# WHAT: Generates a focused report of all recent changes for AI verification.
#       This includes uncommitted changes and new commits on the current branch.

set -e

# --- Configuration ---
OUTPUT_FILE="context_verify.md"
MAIN_BRANCH="main"
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)

echo "--> Generating comprehensive verification context..."

# --- Main Logic ---

# 1. Start the report with a clear, hardcoded prompt.
cat <<EOF > "$OUTPUT_FILE"
# AI Prompt: Verification of Changes

## Your Role
You are an expert AI pair programmer acting as a code reviewer.

## The Task
Carefully analyze the following git status and aggregated diff. Verify that the changes accurately reflect the instructions I just gave you. Confirm if the implementation is correct or point out any discrepancies.
---
# Verification Report

**Branch:** \`$CURRENT_BRANCH\`
**Generated:** $(date -u)
---
EOF

# 2. Append a summary of uncommitted changes.
{
  echo ""
  echo "## 1. Uncommitted Local Changes"
  echo "\`\`\`"
  # Check if there are any changes, otherwise print a clean message.
  if [[ -z $(git status --porcelain) ]]; then
    echo "No uncommitted local changes."
  else
    git status
  fi
  echo "\`\`\`"
} >> "$OUTPUT_FILE"

# 3. Append the full aggregated diff (committed on branch + uncommitted).
{
  echo ""
  echo "---"
  echo "## 2. Aggregated Diff of All Changes vs \`$MAIN_BRANCH\`"
  echo "\`\`\`diff"

  # Find the common ancestor commit to compare against.
  MERGE_BASE=$(git merge-base $MAIN_BRANCH HEAD)

  # First, show the diff of all committed changes on this branch.
  git diff $MERGE_BASE..HEAD

  # Second, show the diff of all uncommitted (staged and unstaged) changes.
  git diff HEAD

  echo "\`\`\`"
} >> "$OUTPUT_FILE"

echo "✅ Verification report generated. Saved to '$OUTPUT_FILE'."
