#!/bin/bash
# scripts/status_commit.sh
# Generates context for a commit message (uncommitted changes only).

set -e

OUTPUT_FILE="contextvibes_status.md"

echo "--> Generating report with commit message prompt..."
cat ./docs/prompts/generate-commit-message.md > "$OUTPUT_FILE"

echo "## Uncommitted Local Changes" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"
echo '```' >> "$OUTPUT_FILE"
git status >> "$OUTPUT_FILE"
echo '```' >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"
echo "---" >> "$OUTPUT_FILE"
echo "## Diff of Uncommitted Changes" >> "$OUTPUT_FILE"
echo '```diff' >> "$OUTPUT_FILE"
git diff --staged >> "$OUTPUT_FILE"
git diff >> "$OUTPUT_FILE"
echo '```' >> "$OUTPUT_FILE"

echo "✅ Report with commit prompt saved to '$OUTPUT_FILE'."