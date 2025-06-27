#!/bin/bash
# WHAT: Exports only the documentation and guidance files.
set -e

OUTPUT_FILE="contextvibes_export_docs.md"
CUSTOM_PROMPT_PATH="docs/prompts/export-docs-context.md"
FALLBACK_PROMPT_PATH="docs/prompts/export-project-context.md"

echo "--> Generating Documentation & Guidance export..."

# --- Use the specific prompt if it exists, otherwise use the fallback ---
if [ -f "$CUSTOM_PROMPT_PATH" ]; then
  echo "--> Using specific documentation prompt: $CUSTOM_PROMPT_PATH"
  cat "$CUSTOM_PROMPT_PATH" > "$OUTPUT_FILE"
else
  echo "--> Specific prompt not found. Using fallback: $FALLBACK_PROMPT_PATH"
  cat "$FALLBACK_PROMPT_PATH" > "$OUTPUT_FILE"
fi

# --- Helper function to export a "book" of files ---
export_book() {
  local title="$1"; shift
  local files
  files=$(git ls-files "$@")
  
  { echo ""; echo "---"; echo "## Book: ${title}"; echo ""; } >> "$OUTPUT_FILE"

  echo "$files" | while read -r file; do
    if [ ! -f "$file" ]; then continue; fi
    if ! file "$file" | grep -E -q 'text|script|JSON|XML|YAML|HTML|CSS|Markdown|empty'; then
        echo "--> Skipping binary file: $file"
        continue
    fi
    { echo ""; echo "======== FILE: ${file} ========"; echo "\`\`\`${file##*.}"; cat "$file"; echo "\`\`\`"; echo "======== END FILE: ${file} ========"; } >> "$OUTPUT_FILE"
  done
}

# --- Define the documentation files and directories to be exported ---
export_book "The Library (Documentation & Guidance)" README.md CHANGELOG.md docs/ playbooks/

echo "✅ Documentation export complete. Report saved to '$OUTPUT_FILE'."