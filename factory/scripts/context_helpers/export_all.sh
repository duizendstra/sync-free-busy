#!/bin/bash
# factory/scripts/context_helpers/export_all.sh
#
# WHAT: Exports a comprehensive snapshot of the entire project, organized
#       by our "products, factory, docs" architectural model.
# WHY:  Provides a complete, structured context file for high-level AI
#       analysis, onboarding, or architectural review.

set -e

# --- Configuration ---
OUTPUT_FILE="context_export_all.md"

# --- Helper Functions ---

is_text_file() {
  # Uses 'file' command and 'grep' to check for common text-like mimetypes.
  # This version is more robust and includes application/json, etc.
  local mime_type
  mime_type=$(file --brief --mime-type "$1")
  [[ "$mime_type" == text/* || "$mime_type" == application/json || "$mime_type" == application/javascript ]]
}

# Helper to append a "book" of files to the main report.
# Usage: append_book "Title" "path1" "path2" ...
append_book() {
  local title="$1"
  shift # Remove the title, leaving only the paths
  local paths=("$@")
  local files

  # Find all files tracked by git in the given paths, then pipe to grep
  # to filter out any package-lock.json files.
  files=$(git ls-files -- "${paths[@]}" | grep -v 'package-lock\.json$' || true)


  # Append the book header to the main output file.
  { echo ""; echo "---"; echo "## Book: ${title}"; echo ""; } >> "$OUTPUT_FILE"

  # Process each file found.
  echo "$files" | while read -r file; do
    # Skip if the file doesn't exist or is not a text file.
    if [ ! -f "$file" ] || ! is_text_file "$file"; then
      echo "--> Skipping non-text file: $file"
      continue
    fi

    # Append the file's content, wrapped in markdown code blocks.
    {
      echo ""
      echo "======== FILE: ${file} ========"
      echo "\`\`\`${file##*.}"
      cat "$file"
      echo "\`\`\`"
      echo "======== END FILE: ${file} ========"
    } >> "$OUTPUT_FILE"
  done
}

# --- Main Logic ---

echo "--> Generating full project export to $OUTPUT_FILE..."

# 1. Start the report with a clear, hardcoded prompt.
cat <<EOF > "$OUTPUT_FILE"
# AI INSTRUCTION: Full Project Context Analysis

## 1. Your Role
Assume the role of a senior software engineer and technical architect. Your memory is now being initialized with the complete state of a software project.

## 2. Your Task
The content immediately following this prompt is a comprehensive export of the project, organized by its architectural model. Your primary task is to **fully ingest and internalize this entire context**.

## 3. Required Confirmation
After you have processed all the information, your **only** response should be a confirmation message like "Context loaded."
---
EOF

# 2. Append the current Git repository state.
{
  echo ""
  echo "---"
  echo "## Git Repository State"
  echo ""
  echo "### Current Branch"
  echo "\`\`\`"
  git rev-parse --abbrev-ref HEAD
  echo "\`\`\`"
  echo ""
  echo "### Local Changes (Status)"
  echo "\`\`\`"
  git status
  echo "\`\`\`"
  echo ""
  echo "### Local Branches"
  echo "\`\`\`"
  git branch
  echo "\`\`\`"
  echo ""
  echo "### Remote Branches"
  echo "\`\`\`"
  git branch -r
  echo "\`\`\`"
} >> "$OUTPUT_FILE"


# 3. Execute the export for each part of our architecture.
append_book "The Products (Deployable Code)" "products/"
append_book "The Factory (Automation Framework)" "factory/" "Taskfile.yml"
append_book "The Library (Project Documentation)" "docs/" "README.md" "CHANGELOG.md" "LICENSE"

echo "✅ Full project export complete. Report saved to '$OUTPUT_FILE'."
