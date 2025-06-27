#!/bin/bash
# WHAT: Exports only the automation and configuration files.
set -e

OUTPUT_FILE="contextvibes_export_automation.md"
CUSTOM_PROMPT_PATH="docs/prompts/export-automation-context.md"
FALLBACK_PROMPT_PATH="docs/prompts/export-project-context.md"

echo "--> Generating Automation export..."

# --- Use the specific prompt if it exists, otherwise use the fallback ---
if [ -f "$CUSTOM_PROMPT_PATH" ]; then
  echo "--> Using specific automation prompt: $CUSTOM_PROMPT_PATH"
  cat "$CUSTOM_PROMPT_PATH" > "$OUTPUT_FILE"
else
  echo "--> Specific prompt not found. Using fallback: $FALLBACK_PROMPT_PATH"
  cat "$FALLBACK_PROMPT_PATH" > "$OUTPUT_FILE"
fi

# --- Append the file content ---
echo "" >> "$OUTPUT_FILE" && echo "---" >> "$OUTPUT_FILE"
echo "## Book: The Factory (Automation & Config)" >> "$OUTPUT_FILE"

git ls-files Taskfile.yml tasks/ scripts/ Dockerfile docker-compose.yml .idx/ .gitignore .dockerignore | while read -r file; do
  if [ -f "$file" ]; then
    echo "" >> "$OUTPUT_FILE" && echo "======== FILE: ${file} ========" >> "$OUTPUT_FILE"
    echo "\`\`\`${file##*.}" >> "$OUTPUT_FILE"
    cat "$file" >> "$OUTPUT_FILE"
    echo "\`\`\`" >> "$OUTPUT_FILE" && echo "======== END FILE: ${file} ========" >> "$OUTPUT_FILE"
  fi
done

echo "✅ Automation export complete. Report saved to '$OUTPUT_FILE'."