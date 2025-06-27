#!/bin/bash
# scripts/start_task.sh (v5 - State-Aware with Compliance Checks)
#
# WHY:  Intelligently guides the user and enforces git best practices.
# WHAT: Checks branch name for compliance with standards (e.g., feat/add-login).
#       If on 'main', assumes "New Task". If on another branch, presents a menu.
# HOW:  Uses git commands, regex for validation, and interactive prompts.

set -e

# --- Phase 1: Prerequisite Checks & State Sync ---
echo "--> Syncing with remote to get the latest state..."
git fetch origin --prune
MAIN_BRANCH="main"
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
STASH_PERFORMED=false
WORKFLOW_TYPE=""

# --- Phase 2: Handle Uncommitted Changes ---
if ! git diff --quiet --exit-code; then
  echo "⚠️  You have uncommitted changes."
  read -p "    Stash them and continue? (Y/n) " -n 1 -r
  echo
  if [[ $REPLY =~ ^[Nn]$ ]]; then
    echo "Aborted by user. Please commit or stash your changes before running again."
    exit 1
  else
    git stash
    STASH_PERFORMED=true
    echo "✅ Changes stashed."
  fi
fi

# --- Phase 3: Main Workflow & Validation Logic ---

# Function to validate the branch name against best practices.
validate_branch_name() {
  local branch_name="$1"
  # Regex: Starts with a type, then a slash, then lowercase letters/numbers/hyphens.
  local branch_regex="^(feat|fix|chore|refactor|docs|test)\/([a-z0-9\-]+)$"
  
  if [[ "$branch_name" =~ $branch_regex ]]; then
    return 0 # Success
  else
    echo "❌ ERROR: Invalid branch name: '$branch_name'."
    echo "   Branch names MUST follow the convention: type/short-description"
    echo "   - type:      feat, fix, chore, refactor, docs, or test"
    echo "   - separator: /"
    echo "   - desc:      lowercase letters, numbers, and hyphens only"
    echo "   - Example:   feat/add-user-login"
    return 1 # Failure
  fi
}

# Inner function to handle creating a new branch.
create_new_branch() {
  local new_branch_name=""
  while true; do
    read -p "Please enter a name for the new feature branch (or press Enter to cancel): " new_branch_name
    if [ -z "$new_branch_name" ]; then
      echo "Operation cancelled."
      return 1 # Cancellation
    fi

    # Validate the branch name before attempting to create it.
    if ! validate_branch_name "$new_branch_name"; then
      new_branch_name="" # Clear for re-prompt
      continue # Go to the next loop iteration to re-ask the user.
    fi

    # Try to create the branch
    if git checkout -b "$new_branch_name"; then
      echo "✅ Switched to a new branch '$new_branch_name'."
      WORKFLOW_TYPE="new_branch"
      return 0 # Success
    else
      # This case is now less likely but kept as a safeguard.
      echo "❌ ERROR: Could not create branch '$new_branch_name' with git."
      new_branch_name="" # Clear for re-prompt
    fi
  done
}

# --- Main Logic Fork: New Task vs. Continue Task ---

if [ "$CURRENT_BRANCH" == "$MAIN_BRANCH" ]; then
  echo "--> You are on the '$MAIN_BRANCH' branch. Starting a new task..."
  create_new_branch
  if [ $? -eq 1 ]; then
    if [ "$STASH_PERFORMED" = true ]; then
      echo "--> Restoring stashed changes to '$MAIN_BRANCH'..."
      git stash pop
    fi
    exit 1
  fi
else
  echo "--> You are on branch '$CURRENT_BRANCH'. What would you like to do?"
  PS3="Your choice: "
  options=(
    "Switch to another existing local branch"
    "Create a new feature branch from here"
    "Quit"
  )
  select opt in "${options[@]}"; do
    case $opt in
      "Switch to another existing local branch")
        branches=$(git branch --list --format='%(refname:short)' | grep -vE "^(main|${CURRENT_BRANCH})$")
        if [ -z "$branches" ]; then
          echo "No other local branches to switch to."
          if [ "$STASH_PERFORMED" = true ]; then git stash pop; fi
          exit 1
        fi

        echo "Select a branch to switch to:"
        select branch_to_switch in $branches "Go Back"; do
          if [ "$branch_to_switch" == "Go Back" ]; then
            if [ "$STASH_PERFORMED" = true ]; then git stash pop; fi
            echo "Operation cancelled."
            exit 1
          elif [ -n "$branch_to_switch" ]; then
            git checkout "$branch_to_switch"
            echo "✅ Switched to branch '$branch_to_switch'."
            WORKFLOW_TYPE="switched_branch"
            break
          else
            echo "Invalid option. Please try again."
          fi
        done
        break
        ;;
      "Create a new feature branch from here")
        create_new_branch
        if [ $? -eq 1 ]; then
          if [ "$STASH_PERFORMED" = true ]; then
            echo "--> Restoring stashed changes to '$CURRENT_BRANCH'..."
            git stash pop
          fi
          exit 1
        fi
        break
        ;;
      "Quit")
        if [ "$STASH_PERFORMED" = true ]; then
          echo "--> Restoring stashed changes to '$CURRENT_BRANCH'..."
          git stash pop
        fi
        echo "Aborted by user."
        exit 1
        ;;
      *) echo "Invalid option $REPLY";;
    esac
  done
fi

# --- Phase 4: Finalization ---
echo "" 

if [ "$STASH_PERFORMED" = true ]; then
  echo "--> Re-applying your stashed changes..."
  git stash pop
  echo "✅ Your work has been restored."
fi

if [ "$WORKFLOW_TYPE" == "new_branch" ]; then
  echo "✅ You are now ready to start development. What is your first objective?"
elif [ "$WORKFLOW_TYPE" == "switched_branch" ]; then
  echo "✅ You have switched to an existing branch. To see what's on this branch, you can run 'task status'."
fi