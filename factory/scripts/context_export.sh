#!/bin/bash
# scripts/status_export.sh
# Generates the most comprehensive project snapshot for an LLM.
# It intelligently uses a custom prompt if it exists, otherwise falls back to a default.

set -e

OUTPUT_FILE="contextvibes_status.md"
MAIN_BRANCH="main"
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
CUSTOM_PROMPT_PATH="docs/prompts/export-project-context.md"

echo "--> Generating comprehensive project export..."

# --- Header and Prompt ---
# Check for a custom prompt file first. If it exists, use it.
if [ -f "$CUSTOM_PROMPT_PATH" ]; then
  echo "--> Found custom prompt at '$CUSTOM_PROMPT_PATH'. Using it."
  cat "$CUSTOM_PROMPT_PATH" > "$OUTPUT_FILE"
else
  # Otherwise, use the built-in default prompt.
  echo "--> Custom prompt not found. Using default."
  {
    echo "# AI Prompt: Full Project Context Analysis"
    echo ""
    echo "## Your Role"
    echo "You are an expert AI pair programmer. Your task is to analyze the following comprehensive project export to get a complete and up-to-date understanding of the repository's current state."
    echo ""
    echo "## The Task"
    echo "Read and fully absorb all the provided information. This is the ground truth of the project from now on. Acknowledge that you are up-to-date and ready for the next instruction."
  } > "$OUTPUT_FILE"
fi

# Append the standard export header and content to the file.
{
  echo ""
  echo "---"
  echo "# Comprehensive Project Export"
  echo ""
  echo "**Branch:** \`$CURRENT_BRANCH\`"
  echo "**Generated:** $(date)"
  echo ""
  echo "---"
} >> "$OUTPUT_FILE"

# --- Git Status Section ---
{
  echo "## 1. Uncommitted Local Changes"
  echo '```'
  if [[ -z $(git status --porcelain) ]]; then
    echo "No uncommitted local changes. The working directory is clean."
  else
    git status
  fi
  echo '```'
  echo ""
  echo "---"
} >> "$OUTPUT_FILE"

# --- New Work Section ---
if [ "$CURRENT_BRANCH" != "$MAIN_BRANCH" ]; then
  MERGE_BASE=$(git merge-base "$MAIN_BRANCH" HEAD)
  {
    echo "## 2. New Work on This Branch (Compared to \`$MAIN_BRANCH\`)"
    echo ""
    if [ "$(git rev-list --count $MERGE_BASE..HEAD)" -eq 0 ]; then
      echo "No new commits found on this branch compared to \`$MAIN_BRANCH\`."
    else
      echo "**Commit History:**"
      echo '```'
      git log --oneline $MERGE_BASE..HEAD
      echo '```'
    fi
    echo ""
    echo "---"
  } >> "$OUTPUT_FILE"
fi

# --- Project Structure Section ---
{
  echo "## 3. Project Structure"
  echo ""
  echo '```'
  tree -a -I '.git|.task|bin|node_modules|.venv|__pycache__|*.log|contextvibes_*.md'
  echo '```'
  echo ""
  echo "---"
} >> "$OUTPUT_FILE"

# --- Full Content of All Tracked Files Section ---
# This section dynamically finds every file tracked by Git and cats its content.
echo "## 4. Full Content of All Tracked Files" >> "$OUTPUT_FILE"

# Use 'git ls-files' to get a definitive list of all tracked files.
git ls-files | while read -r file; do
    # Check if the file is a binary, non-text, or empty. All are safe to process.
    # We use an extended grep to look for multiple keywords that indicate a non-binary file.
    # CRITICAL: We now include 'empty' as a valid type to handle empty files correctly.
    if ! file "$file" | grep -E -q 'text|script|JSON|XML|YAML|HTML|CSS|Markdown|empty'; then
        echo "--> Skipping binary file: $file"
        continue
    fi
    
    # We must also ensure we don't include the output file itself.
    if [ "$file" == "$OUTPUT_FILE" ]; then
        continue
    fi

    {
      echo ""
      echo "======== FILE: ${file} ========"
      # Use a language hint for markdown code blocks if possible.
      extension="${file##*.}"
      echo "\`\`\`${extension}"
      # Use `cat` to append the file's content.
      cat "$file"
      echo '```'
      echo "======== END FILE: ${file} ========"
    } >> "$OUTPUT_FILE"
done


echo "✅ Comprehensive export complete. Report saved to '$OUTPUT_FILE'."