#!/bin/bash
# scripts/destroy.sh
# A heavily guarded script to delete all project infrastructure.

# Exit immediately if a command fails. This is critical for safety.
set -e

# --- Script Parameters ---
# The script expects the three project IDs as arguments.
if [ "$#" -ne 3 ]; then
    echo "Error: This script requires three project ID arguments." >&2
    echo "Usage: $0 [COMPUTE_PROJECT_ID] [STORAGE_PROJECT_ID] [ASSETS_PROJECT_ID]" >&2
    exit 1
fi

COMPUTE_PROJECT_ID=$1
STORAGE_PROJECT_ID=$2
ASSETS_PROJECT_ID=$3

# --- Main Logic ---

echo
echo "======================================================================"
echo "                          DANGER ZONE"
echo "======================================================================"
echo "You are about to permanently delete all GCP projects for this"
echo "environment. This action is irreversible and will result in data loss."
echo "======================================================================"
echo

# Create an array of the projects to delete.
PROJECTS_TO_DELETE=(
  "$COMPUTE_PROJECT_ID"
  "$STORAGE_PROJECT_ID"
  "$ASSETS_PROJECT_ID"
)

# Loop through each project and require explicit confirmation.
for PROJECT_ID in "${PROJECTS_TO_DELETE[@]}"; do
  echo
  echo "----------------------------------------------------------------------"
  echo -e "To confirm the deletion of project \033[1;31m${PROJECT_ID}\033[0m, please type its full ID below."
  read -p "Type '${PROJECT_ID}' to confirm: " CONFIRMATION

  if [[ "$CONFIRMATION" == "$PROJECT_ID" ]]; then
    echo "Confirmation matched. Deleting project '${PROJECT_ID}'..."
    gcloud projects delete "${PROJECT_ID}" --quiet
    echo -e "✅ Project '${PROJECT_ID}' has been scheduled for deletion."
  else
    echo "Confirmation failed. Skipping deletion of project '${PROJECT_ID}'."
  fi
  echo "----------------------------------------------------------------------"
done

echo
echo "Destruction process complete."