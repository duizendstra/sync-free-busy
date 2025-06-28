#!/bin/bash
# factory/scripts/context_helpers/export_automation.sh
# Exports only the factory automation files.

set -e

# --- Configuration ---
OUTPUT_FILE="context_export_automation.md"

# --- Helper Function ---
is_text_file() {
  local mime_type
  mime_type=$(file --brief --mime-type "$1")
  [[ "$mime_type" == text/* || "$mime_type" == application/json || "$mime_type" == application/javascript || "$mime_type" == application/x-yaml ]]
}

echo "--> Generating automation-only export to $OUTPUT_FILE..."

# --- Main Logic ---

# 1. Start the report with a clear, hardcoded prompt.
cat <<EOF > "$OUTPUT_FILE"
# AI INSTRUCTION: Automation Framework Analysis

## Your Role
Assume the role of an expert DevOps engineer and automation specialist. Your memory is being initialized with the project's automation framework.

## Your Task
The content immediately following this prompt is an export of the project's automation files. Your primary task is to **fully ingest and internalize this context** to understand how the project is built, tested, and managed.
---
EOF

# 2. Append all text files from factory/ and the root Taskfile.yml
git ls-files "factory/" "Taskfile.yml" | while read -r file; do
  if ! is_text_file "$file"; then
    echo "--> Skipping non-text file: $file (MIME: $(file --brief --mime-type "$file"))"
    continue
  fi
  {
    echo ""
    echo "======== FILE: ${file} ========"
    echo "\`\`\`${file##*.}"
    cat "$file"
    echo "\`\`\`"
    echo "======== END FILE: ${file} ========"
  } >> "$OUTPUT_FILE"
done

echo "✅ Automation export complete. Report saved to '$OUTPUT_FILE'."
