#!/bin/bash
# scripts/status_verify.sh
# Generates a focused report of all recent changes for AI verification.
# This includes uncommitted changes and new commits on the current branch.

set -e

OUTPUT_FILE="contextvibes_status.md"
MAIN_BRANCH="main"
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)

# --- Header and AI Prompt ---
{
  echo "# AI Prompt: Verification of Changes"
  echo ""
  echo "## Your Role"
  echo "You are an expert AI pair programmer acting as a code reviewer."
  echo ""
  echo "## The Task"
  echo "Carefully analyze the following git status and aggregated diff. Verify that the changes accurately reflect the instructions I just gave you. Confirm if the implementation is correct or point out any discrepancies."
  echo ""
  echo "---"
  echo "# Verification Report"
  echo ""
  echo "**Branch:** \`$CURRENT_BRANCH\`"
  echo "**Generated:** $(date -u)"
  echo ""
  echo "---"
} > "$OUTPUT_FILE"

# --- 1. Uncommitted Changes Summary ---
{
  echo "## 1. Uncommitted Local Changes"
  echo '```'
  if [[ -z $(git status --porcelain) ]]; then
    echo "No uncommitted local changes."
  else
    git status
  fi
  echo '```'
  echo ""
  echo "---"
} >> "$OUTPUT_FILE"

# --- 2. Aggregated Diff (Committed + Uncommitted) ---
{
  echo "## 2. Aggregated Diff of All Changes vs \`$MAIN_BRANCH\`"
  echo '```diff'
  
  # Define the merge base to compare against.
  MERGE_BASE=$(git merge-base $MAIN_BRANCH HEAD)

  # First, show the diff of all committed changes on this branch.
  git diff $MERGE_BASE..HEAD
  
  # Second, show the diff of all uncommitted (staged and unstaged) changes.
  git diff HEAD

  echo '```'
} >> "$OUTPUT_FILE"

echo "✅ Verification report generated. Saved to '$OUTPUT_FILE'."