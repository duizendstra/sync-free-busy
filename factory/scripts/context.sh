#!/bin/bash
# factory/scripts/context.sh
#
# WHAT: A master script for context generation. It acts as a router, calling
#       the correct helper script based on the user's goal.
# WHY:  Provides a single entry point (`task context`) while keeping all
#       implementation logic in dedicated, single-responsibility files.

set -e

# --- Configuration ---
# Get the absolute path to the project root. This is the most reliable way.
GIT_ROOT=$(git rev-parse --show-toplevel)
# Define the helpers directory relative to the known project root.
HELPERS_DIR="$GIT_ROOT/factory/scripts/context_helpers"

# --- The Interactive Menu (using gum) ---
show_menu() {
  gum style --border normal --margin "1" --padding "1 2" --border-foreground 212 "CONTEXT GENERATOR"
  echo "Please select the type of context you want to generate:"

  CHOICE=$(gum choose \
    "For a Commit Message" \
    "For a Pull Request Description" \
    "For Quick Verification" \
    "Export: Full Project (All)" \
    "Export: Code Only" \
    "Export: Documentation Only" \
    "Export: Automation Only" \
    "Quit")

  case "$CHOICE" in
    "For a Commit Message")         "$HELPERS_DIR/context_commit.sh" ;;
    "For a Pull Request Description") "$HELPERS_DIR/context_pr.sh" ;;
    "For Quick Verification")         "$HELPERS_DIR/context_verify.sh" ;;
    "Export: Full Project (All)")   "$HELPERS_DIR/export_all.sh" ;;
    "Export: Code Only")            "$HELPERS_DIR/export_code.sh" ;;
    "Export: Documentation Only")     "$HELPERS_DIR/export_docs.sh" ;;
    "Export: Automation Only")        "$HELPERS_DIR/export_automation.sh" ;;
    "Quit")                         echo "Aborted."; exit 0 ;;
    *)                              echo "No selection. Aborting."; exit 1 ;;
  esac
}

# --- Main Controller Logic ---
MODE=$1

if [ -z "$MODE" ]; then
  show_menu
  exit 0
fi

case "$MODE" in
  commit)            "$HELPERS_DIR/context_commit.sh" ;;
  pr)                "$HELPERS_DIR/context_pr.sh" ;;
  verify)            "$HELPERS_DIR/context_verify.sh" ;;
  export-all)        "$HELPERS_DIR/export_all.sh" ;;
  export-code)       "$HELPERS_DIR/export_code.sh" ;;
  export-docs)       "$HELPERS_DIR/export_docs.sh" ;;
  export-automation) "$HELPERS_DIR/export_automation.sh" ;;
  *)
    echo "❌ ERROR: Invalid mode '$MODE' provided." >&2
    echo "   Valid modes are: commit, pr, verify, export-all, export-code, export-docs, export-automation" >&2
    exit 1
    ;;
esac
