#!/bin/bash
# factory/scripts/test.sh
#
# WHAT: Interactively runs the Jest test suite for a selected product.
# WHY:  Provides a single entry point for running all project tests.

set -e

gum style --border normal --margin "1" --padding "1 2" --border-foreground 212 "🧪 Running Tests..."

echo "Please select the product to test:"
PRODUCT=$(gum choose "direct-link" "availability-hub")

if [ -z "$PRODUCT" ]; then
  echo "No product selected. Aborting tests."
  exit 1
fi

echo "--> Running Jest tests for '$PRODUCT'..."
# Change directory into the selected product, run jest, then change back.
# Running in a subshell `(...)` makes the directory change temporary.
(cd "products/$PRODUCT" && npx jest)

gum style --foreground 212 "✅ Tests for '$PRODUCT' finished."
