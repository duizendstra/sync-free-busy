#!/bin/bash
# factory/scripts/task_finish.sh
#
# WHY:  Safely prepares a feature branch for a pull request by analyzing
#       the situation first and presenting a clear decision to the user.
# WHAT: It checks for merge conflicts before attempting to merge, and only
#       proceeds with user confirmation.

set -e

# --- Configuration ---
MAIN_BRANCH="main"
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)

# --- Phase 1: Prerequisite Verification ---
gum style --border normal --margin "1" --padding "1 2" --border-foreground 212 "🏁 Finishing Task: Preparing Pull Request..."

echo "--> Verifying prerequisites..."
if [ "$CURRENT_BRANCH" == "$MAIN_BRANCH" ]; then
  echo "❌ ERROR: You cannot run task-finish from the '$MAIN_BRANCH' branch."
  exit 1
fi
if ! git diff --quiet --exit-code; then
  echo "❌ ERROR: You have uncommitted changes. Please commit or stash them first."
  exit 1
fi
if ! gh auth status > /dev/null 2>&1; then
    echo "❌ ERROR: GitHub CLI ('gh') is not authenticated. Please run 'gh auth login'."
    exit 1
fi
echo "✅ Prerequisites met."

# --- Phase 2: Conflict Analysis ---
echo "--> Analyzing branch status against '$MAIN_BRANCH'..."
git fetch origin

# Use git merge-tree to check for conflicts without actually merging.
if git merge-tree `git merge-base origin/$MAIN_BRANCH HEAD` HEAD origin/$MAIN_BRANCH | grep -q '<<<<<<<'; then
    gum style --foreground 99 "❌ CONFLICT DETECTED: This branch has conflicts with '$MAIN_BRANCH'."
    echo "   Please resolve these manually before creating a pull request."
    echo "   Recommended Action: Run 'git pull --rebase origin main', fix conflicts, and run this task again."
    exit 1
fi
echo "✅ No merge conflicts detected."

# --- Phase 3: User Confirmation ---
if ! gum confirm "This branch is clean. Proceed to create Pull Request?"; then
    echo "Aborted by user."
    exit 1
fi

# --- Phase 4: Execution ---
echo "--> Syncing '$CURRENT_BRANCH' with latest '$MAIN_BRANCH'..."
git merge origin/"$MAIN_BRANCH"

echo "--> Pushing updated branch to remote..."
git push -u origin "$CURRENT_BRANCH"

echo "--> Opening browser to create a Pull Request..."
# Use gh pr create to automatically fill in details from commits and open the web browser.
gh pr create --fill --web

gum style --border normal --margin "1" --padding "1 2" --border-foreground 212 "✅ 'task-finish' complete. Please finalize your PR in the browser."
