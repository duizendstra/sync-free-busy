#!/bin/bash
# WHAT: Exports all tracked text files, organized by book.
set -e
OUTPUT_FILE="contextvibes_export_all.md"
PROMPT_FILE="docs/prompts/export-project-context.md"

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

echo "--> Generating full project export..."
cat "$PROMPT_FILE" > "$OUTPUT_FILE"
export_book "The Application (Code)" cmd/ internal/ go.mod go.sum
export_book "The Factory (Automation & Config)" Taskfile.yml tasks/ scripts/ Dockerfile docker-compose.yml .idx/ .gitignore .dockerignore
export_book "The Library (Documentation & Guidance)" README.md CHANGELOG.md docs/ playbooks/
echo "✅ Full project export complete. Report saved to '$OUTPUT_FILE'."