#!/bin/bash
# factory/scripts/commit.sh
#
# WHY:  Handles the logic for committing changes safely.
# WHAT: Checks that the current branch is not 'main', then stages all
#       changes and commits them using the arguments passed from the task.

set -e

# --- Configuration ---
MAIN_BRANCH="main"
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)

# --- Safety Check ---
# Prevent direct commits to the main branch.
if [ "$CURRENT_BRANCH" == "$MAIN_BRANCH" ]; then
  gum style --border normal --margin "1" --padding "1 2" --border-foreground 99 "❌ ERROR: Direct commits to the '$MAIN_BRANCH' branch are not allowed."
  echo "   Please use 'task task-start' to create a feature branch first."
  exit 1
fi

echo "--> Staging all changes..."
git add .

echo "--> Committing staged changes..."
# The "$@" special variable passes all arguments from the Taskfile
# (e.g., -m "My message") directly to the git commit command.
git commit "$@"

gum style --foreground 212 "✅ Commit successful."
