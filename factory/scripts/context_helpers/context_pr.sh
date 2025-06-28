#!/bin/bash
# factory/scripts/context_helpers/context_pr.sh
#
# WHAT: Generates context for writing a Pull Request description by diffing
#       the current branch against the 'main' branch.

set -e

# --- Configuration ---
OUTPUT_FILE="context_pr.md"
MAIN_BRANCH="main" # Assuming 'main' is your primary branch

echo "--> Generating context for Pull Request description..."

# --- Main Logic ---

# 1. Check for uncommitted changes and warn the user.
if ! git diff --quiet --exit-code; then
  gum style --foreground 212 "⚠️  Warning: You have uncommitted changes. They will not be included in the PR context."
fi

# 2. Find the common ancestor to create a clean diff.
MERGE_BASE=$(git merge-base $MAIN_BRANCH HEAD)

# 3. Start the report with a clear, hardcoded prompt.
cat <<EOF > "$OUTPUT_FILE"
# AI Prompt: Generate Pull Request Description

## Your Role
You are an expert software engineer writing a clear and comprehensive description for a pull request.

## The Task
Analyze the following git commit history and aggregated diff for the entire feature branch against the \`$MAIN_BRANCH\` branch. Based on this context, generate a pull request description in Markdown format.
---
EOF

# 4. Append the commit history for the current branch.
{
  echo ""
  echo "## Commit History on This Branch"
  echo "\`\`\`"
  # Use a clean format for the log
  git log --pretty=format:'%h %s (%an, %cr)' $MERGE_BASE..HEAD
  echo "\`\`\`"
} >> "$OUTPUT_FILE"

# 5. Append the full diff against the main branch.
{
  echo ""
  echo "---"
  echo "## Full Diff for Branch (vs. $MAIN_BRANCH)"
  echo "\`\`\`diff"
  git diff $MERGE_BASE..HEAD
  echo "\`\`\`"
} >> "$OUTPUT_FILE"

echo "✅ Pull Request context report saved to '$OUTPUT_FILE'."
