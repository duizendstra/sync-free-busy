#!/bin/bash
# factory/scripts/clean.sh
#
# WHAT: Removes temporary build artifacts and other generated files.
# WHY:  Provides a single, consistent way to return the project to a clean state.

set -e

gum style --border normal --margin "1" --padding "1 2" --border-foreground 212 "🧹 Starting Project Cleanup..."

echo "--> Removing all 'node_modules' directories..."
# Use find to locate and remove all node_modules directories.
# -prune is an optimization to prevent find from descending into the found directories.
find . -name "node_modules" -type d -prune -exec rm -rf '{}' +

echo "--> Removing all 'package-lock.json' files..."
# Use find to locate and remove all package-lock.json files.
find . -name "package-lock.json" -type f -delete

echo "--> Removing temporary context files (context_*.md)..."
# Use find to remove context files from the root directory only.
find . -maxdepth 1 -name "context_*.md" -type f -delete

gum style --foreground 212 "✅ Cleanup complete."
