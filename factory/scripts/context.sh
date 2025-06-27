#!/bin/bash
# scripts/context.sh (v3 - Standalone Script Controller)
#
# WHAT: A master script for context generation. It acts as a router, calling
#       the correct standalone script based on the user's goal.
# WHY:  Provides a single entry point (`task context`) while keeping all
#       implementation logic in dedicated, single-responsibility files.

set -e

# --- The Interactive Menu ---
# This function displays the menu and calls the appropriate standalone script.
show_menu() {
  echo
  echo "Please select a context generation goal:"
  PS3="Your choice: "
  options=(
    "For a Commit Message"
    "For a Pull Request Description"
    "For Quick Verification"
    "Export: Code Only"
    "Export: Automation Only"
    "Export: Documentation Only"
    "Export: Full Project (All)"
    "Quit"
  )
  select opt in "${options[@]}"; do
    case $opt in
      "For a Commit Message")         ./scripts/context_commit.sh; break ;;
      "For a Pull Request Description") ./scripts/context_pr.sh; break ;;
      "For Quick Verification")         ./scripts/context_verify.sh; break ;;
      "Export: Code Only")            ./scripts/context_export_code.sh; break ;;
      "Export: Automation Only")        ./scripts/context_export_automation.sh; break ;;
      "Export: Documentation Only")     ./scripts/context_export_docs.sh; break ;;
      "Export: Full Project (All)")   ./scripts/context_export_all.sh; break ;;
      "Quit")                         echo "Aborted."; break ;;
      *)                              echo "Invalid option $REPLY";;
    esac
  done
}

# --- Main Controller Logic ---
MODE=$1
case "$MODE" in
  # --- Parameterized Modes for Automation ---
  commit)            ./scripts/context_commit.sh ;;
  pr)                ./scripts/context_pr.sh ;;
  verify)            ./scripts/context_verify.sh ;;
  export-code)       ./scripts/context_export_code.sh ;;
  export-automation) ./scripts/context_export_automation.sh ;;
  export-docs)       ./scripts/context_export_docs.sh ;;
  export-all)        ./scripts/context_export_all.sh ;;

  # --- Interactive Mode ---
  "")
    show_menu
    ;;

  # --- Error Case ---
  *)
    echo "❌ ERROR: Invalid mode '$MODE' provided." >&2
    echo "   Valid modes are: commit, pr, verify, export-code, export-automation, export-docs, export-all" >&2
    exit 1
    ;;
esac

exit 0