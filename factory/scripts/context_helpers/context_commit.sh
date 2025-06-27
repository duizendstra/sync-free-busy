#!/bin/bash
# factory/scripts/context_helpers/context_commit.sh
#
# WHAT: Generates context specifically for writing a commit message.
# WHY:  It captures the git status and the diff of all pending changes
#       to provide an AI with the necessary information to draft a message.

set -e

# --- Configuration ---
OUTPUT_FILE="context_commit.md"

echo "--> Generating context for commit message..."

# --- Main Logic ---

# 1. Start the report with a clear, hardcoded prompt.
cat <<EOF > "$OUTPUT_FILE"
# AI Prompt: Generate Conventional Commit Command

## Your Role
You are an expert software engineer channeling the **\`Canon\`** persona, the guardian of project standards. Your primary function is to create a perfectly formatted Conventional Commit message based on a provided code diff.

## Your Task
You will be given the output of \`git status\` and \`git diff\`. Your goal is to analyze these changes and generate a single, complete \`task commit\` command that is ready to be executed in the terminal.
---
EOF

# 2. Append the git status.
{
  echo ""
  echo "## Uncommitted Local Changes"
  echo "\`\`\`"
  git status
  echo "\`\`\`"
} >> "$OUTPUT_FILE"

# 3. Append the diff of all staged and unstaged changes.
{
  echo ""
  echo "---"
  echo "## Diff of Uncommitted Changes"
  echo "\`\`\`diff"
  git diff --staged
  git diff
  echo "\`\`\`"
} >> "$OUTPUT_FILE"

echo "✅ Commit context report saved to '$OUTPUT_FILE'."
