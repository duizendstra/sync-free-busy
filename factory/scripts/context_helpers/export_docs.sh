#!/bin/bash
# factory/scripts/context_helpers/export_docs.sh
# Exports only the documentation and project management files.

set -e

# --- Configuration ---
OUTPUT_FILE="context_export_docs.md"

echo "--> Generating docs-only export to $OUTPUT_FILE..."

# --- Main Logic ---

# 1. Start the report with a clear, hardcoded prompt.
cat <<EOF > "$OUTPUT_FILE"
# AI INSTRUCTION: Documentation Context Analysis

## Your Role
Assume the role of a technical writer and project manager. Your memory is being initialized with the project's documentation, changelog, and license.

## Your Task
The content immediately following this prompt is an export of the project's documentation. Your primary task is to **fully ingest and internalize this content**.
---
EOF

# 2. Append all text files from docs/, plus root documentation files.
git ls-files "docs/" "README.md" "CHANGELOG.md" "LICENSE" | while read -r file; do
  # A simple check to skip binary/non-text files.
  if ! file --brief --mime-type "$file" | grep -q 'text'; then
    echo "--> Skipping non-text file: $file"
    continue
  fi

  # Append the file's content, wrapped in a markdown code block.
  {
    echo ""
    echo "======== FILE: ${file} ========"
    echo "\`\`\`${file##*.}"
    cat "$file"
    echo "\`\`\`"
    echo "======== END FILE: ${file} ========"
  } >> "$OUTPUT_FILE"
done

echo "✅ Docs export complete. Report saved to '$OUTPUT_FILE'."
