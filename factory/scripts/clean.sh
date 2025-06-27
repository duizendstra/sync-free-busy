#!/bin/bash
# scripts/clean.sh
# A smart script for cleaning the project. It can be run interactively
# or with a specific mode ('project' or 'full') as an argument.

set -e

# --- Script Functions ---

# Function to perform the actual file cleaning operations.
do_clean_files() {
  local MODE=$1
  case "$MODE" in
    "project")
      echo "--> Cleaning local project artifacts (bin/, .task/, coverage.*, contextvibes*)..."
      rm -rf bin .task coverage.*
      rm -f contextvibes*
      echo "✅ Project artifacts cleaned."
      ;;
    "full")
      echo "--> Cleaning local project artifacts..."
      rm -rf bin .task coverage.*
      rm -f contextvibes*

      echo "--> Cleaning Go caches (build, module, test)..."
      go clean -cache -modcache -testcache

      echo "--> Pruning all unused Docker resources (this may take a moment)..."
      docker system prune -af --volumes

      echo "✅ Full system clean complete."
      ;;
    *)
      # This case should not be hit in normal operation.
      echo "Error: Invalid cleaning mode '$MODE' passed to do_clean function." >&2
      exit 1
      ;;
  esac
}

# *** THIS IS THE NEW FUNCTION ***
# Function to find and delete stale local branches.
do_clean_branches() {
  echo "--> Fetching remote state and pruning deleted branches..."
  git fetch --prune
  
  echo "--> Searching for local branches that are merged into 'main' and do not exist on remote..."
  
  # Get local branches merged into main, excluding main itself and the current branch.
  MERGED_LOCAL_BRANCHES=$(git branch --merged main | grep -vE '^\*|main$' | sed 's/^[ \t]*//')
  
  # Get all remote branch names, stripped of their 'origin/' prefix.
  REMOTE_BRANCHES=$(git branch -r | sed 's|origin/||' | sed 's/^[ \t]*//')

  # Find branches that are in the first list but not the second.
  # `comm -23` shows lines unique to the first file/stream.
  BRANCHES_TO_DELETE=$(comm -23 <(echo "$MERGED_LOCAL_BRANCHES" | sort) <(echo "$REMOTE_BRANCHES" | sort))

  if [ -z "$BRANCHES_TO_DELETE" ]; then
    echo "✅ No stale local branches found. Your repository is clean!"
    return
  fi

  echo
  echo "The following stale branches can be safely deleted:"
  echo -e "\033[0;33m$BRANCHES_TO_DELETE\033[0m" # Print in yellow
  echo
  read -p "Proceed with deletion? (y/N) " -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "$BRANCHES_TO_DELETE" | xargs git branch -d
    echo "✅ Stale branches have been deleted."
  else
    echo "Aborted by user. No branches were deleted."
  fi
}


# Function to display the interactive menu.
show_menu() {
  echo
  echo "Please select a cleaning mode:"
  PS3="Your choice: "
  select opt in \
    "Project Files Only (Fast: Removes bin/, coverage.*, etc.)" \
    "Full System Clean (Slow: Also purges Go & Docker caches)" \
    "Stale Branches (Merged locally, gone from remote)" \
    "Quit"
  do
    case $opt in
      "Project Files Only (Fast: Removes bin/, coverage.*, etc.)")
        do_clean_files "project"
        break
        ;;
      "Full System Clean (Slow: Also purges Go & Docker caches)")
        echo
        read -p "DANGER: This will remove all unused Docker images, containers, and volumes on your system. Are you sure? (y/N) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
          do_clean_files "full"
        else
          echo "Aborted by user."
        fi
        break
        ;;
      # *** THIS IS THE NEW MENU OPTION ***
      "Stale Branches (Merged locally, gone from remote)")
        do_clean_branches
        break
        ;;
      "Quit")
        echo "Aborted."
        break
        ;;
      *) echo "Invalid option $REPLY";;
    esac
  done
}

# --- Main Script Logic ---

# If the first argument ($1) is empty, show the interactive menu.
if [ -z "$1" ]; then
  show_menu
else
  # If an argument is provided, pass it directly to the file cleaning function.
  # Note: Branch cleaning is interactive only.
  do_clean_files "$1"
fi