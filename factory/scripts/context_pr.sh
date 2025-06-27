#!/bin/bash
# scripts/status_pr.sh
# Generates context for a pull request (all changes on branch vs. main).

set -e

OUTPUT_FILE="contextvibes_status.md"
MAIN_BRANCH="main"

if ! git diff --quiet --exit-code; then
  echo "⚠️  Warning: You have uncommitted changes. They will not be included in the PR description."
fi

MERGE_BASE=$(git merge-base $MAIN_BRANCH HEAD)

echo "--> Generating report with PR description prompt..."
cat ./docs/prompts/generate-pr-description.md > "$OUTPUT_FILE"

echo "## New Work on This Branch (Compared to \`$MAIN_BRANCH\`)" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"
echo "**Commit History:**" >> "$OUTPUT_FILE"
echo '```' >> "$OUTPUT_FILE"
git log --pretty=format:'%h %s (%an, %cr)' $MERGE_BASE..HEAD >> "$OUTPUT_FILE"
echo '```' >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"
echo "**Detailed file changes (diff):**" >> "$OUTPUT_FILE"
echo '```diff' >> "$OUTPUT_FILE"
git diff $MERGE_BASE..HEAD >> "$OUTPUT_FILE"
echo '```' >> "$OUTPUT_FILE"

echo "✅ Report with PR prompt saved to '$OUTPUT_FILE'."