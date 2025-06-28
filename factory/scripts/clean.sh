#!/bin/bash
# factory/scripts/clean.sh
#
# WHAT: Switches to the main branch, pulls the latest changes, and removes
#       temporary build artifacts and merged local branches.
# WHY:  Provides a single, consistent command to run after a PR has been merged.

set -e

gum style --border normal --margin "1" --padding "1 2" --border-foreground 212 "🧹 Starting Project Synchronization & Cleanup..."

echo "--> Switching to 'main' branch..."
git checkout main

echo "--> Pulling latest changes from origin..."
git pull origin main

echo "--> Removing all 'node_modules' directories..."
find . -name "node_modules" -type d -prune -exec rm -rf '{}' +

echo "--> Removing all 'package-lock.json' files..."
find . -name "package-lock.json" -type f -delete

echo "--> Removing temporary context files (context_*.md)..."
find . -maxdepth 1 -name "context_*.md" -type f -delete

echo "--> Removing local branches that have been merged into 'main'..."
# First, update our view of the remote and clean up stale remote branches
git fetch --prune origin

# Then, find local branches merged into main, filter out 'main' and the current branch ('*'), and delete them.
# The 'xargs -r' command ensures 'git branch -d' only runs if there are branches to delete.
git branch --merged main | grep -vE '^\*|main$' | xargs -r git branch -d

gum style --foreground 212 "✅ Sync and cleanup complete. Project is up-to-date."
