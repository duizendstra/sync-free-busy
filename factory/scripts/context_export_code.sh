#!/bin/bash
# WHAT: Exports only the application source code.
set -e

OUTPUT_FILE="contextvibes_export_code.md"
CUSTOM_PROMPT_PATH="docs/prompts/export-code-context.md"
FALLBACK_PROMPT_PATH="docs/prompts/export-project-context.md"

echo "--> Generating Code export..."

# --- Use the specific prompt if it exists, otherwise use the fallback ---
if [ -f "$CUSTOM_PROMPT_PATH" ]; then
  echo "--> Using specific code prompt: $CUSTOM_PROMPT_PATH"
  cat "$CUSTOM_PROMPT_PATH" > "$OUTPUT_FILE"
else
  echo "--> Specific prompt not found. Using fallback: $FALLBACK_PROMPT_PATH"
  cat "$FALLBACK_PROMPT_PATH" > "$OUTPUT_FILE"
fi

# --- Append the file content ---
echo "" >> "$OUTPUT_FILE" && echo "---" >> "$OUTPUT_FILE"
echo "## Book: The Application (Code)" >> "$OUTPUT_FILE"

git ls-files cmd/ internal/ go.mod go.sum | while read -r file; do
  if [ -f "$file" ]; then
    echo "" >> "$OUTPUT_FILE" && echo "======== FILE: ${file} ========" >> "$OUTPUT_FILE"
    echo "\`\`\`${file##*.}" >> "$OUTPUT_FILE"
    cat "$file" >> "$OUTPUT_FILE"
    echo "\`\`\`" >> "$OUTPUT_FILE" && echo "======== END FILE: ${file} ========" >> "$OUTPUT_FILE"
  fi
done

echo "✅ Code export complete. Report saved to '$OUTPUT_FILE'."
