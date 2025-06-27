#!/bin/bash
# scripts/finish_task.sh (PLAYBOOK VERSION)
#
# WHY:  Safely prepares a feature branch for a pull request by analyzing
#       the situation first and presenting a clear decision to the user.
# WHAT: It checks for uncommitted changes and merge conflicts *before*
#       acting, and only proceeds with user confirmation.
# HOW:  Uses git commands to check status and simulate merges, and an
#       interactive 'read' prompt for decisions.

set -e

# --- Phase 1: Prerequisite Verification ---
MAIN_BRANCH="main"
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)

echo "--> Starting playbook for finishing task on branch '$CURRENT_BRANCH'..."

if [ "$CURRENT_BRANCH" == "$MAIN_BRANCH" ]; then
  echo "❌ ERROR: You cannot run task-finish from the '$MAIN_BRANCH' branch."
  exit 1
fi

if ! gh auth status > /dev/null 2>&1; then
    echo "❌ ERROR: GitHub CLI ('gh') is not authenticated. Please run 'gh auth login'."
    exit 1
fi

# --- Phase 2: State Analysis ---
echo "--> Analyzing local and remote state..."

# Check for uncommitted changes
if ! git diff --quiet --exit-code; then
  echo "⚠️  ANALYSIS: You have uncommitted changes."
  echo "   RECOMMENDATION: Run 'task status', choose 'Generate Commit Message',"
  echo "   and then run the 'task commit' command I provide you."
  exit 1
fi

# Check for conflicts with the main branch
git fetch origin
if git merge-tree `git merge-base origin/$MAIN_BRANCH HEAD` HEAD origin/$MAIN_BRANCH | grep -q '<<<<<<<'; then
    echo "❌ CONFLICT DETECTED: This branch has conflicts with the latest changes in '$MAIN_BRANCH'."
    echo "   RECOMMENDATION: Run 'git pull --rebase origin main', fix the conflicts,"
    echo "   commit the fixes, and then run 'task task-finish' again."
    exit 1
fi

echo "✅ ANALYSIS: Branch is clean and has no conflicts with '$MAIN_BRANCH'."

# --- Phase 3: Orchestrator Decision ---
echo ""
read -p "Proceed with syncing branch and creating Pull Request? (Y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Nn]$ ]]; then
    echo "Aborted by user."
    exit 1
fi

# --- Phase 4: Execution ---
echo ""
echo "--> Syncing '$CURRENT_BRANCH' with '$MAIN_BRANCH' and pushing to remote..."
git pull --rebase origin "$MAIN_BRANCH"
git push --force-with-lease

echo ""
echo "--> Opening browser to create a Pull Request..."
gh pr create --fill --web

echo ""
echo "✅ 'task-finish' complete. Please finalize your PR in the browser."