#!/bin/bash
# scripts/verify.sh (v2 - Corrected Syntax)
# An automated health check for the project's GCP infrastructure.
# It reads configuration from the .env file and verifies that each
# resource and permission is correctly configured.

# Exit immediately if any command fails.
set -e

# --- Configuration & Setup ---
# Define colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Helper function to print a check result
# Usage: print_result $? "Description of the check" "Optional command to fix"
print_result() {
  if [ "$1" -eq 0 ]; then
    echo -e "[ ${GREEN}OK${NC} ] $2"
  else
    echo -e "[ ${RED}FAIL${NC} ] $2"
    # This is the corrected 'if' block.
    if [ -n "$3" ]; then
      echo -e "       ${YELLOW}Suggestion to fix:${NC} $3"
    fi
    # Optional: Exit on first failure
    # exit 1
  fi
}

# --- Main Verification Logic ---
echo "--- Starting Infrastructure Verification ---"

# 1. Load environment variables
if [ ! -f .env ]; then
    echo -e "[ ${RED}FATAL${NC} ] .env file not found. Cannot run verification."
    exit 1
fi
set -a
source .env
set +a

# 2. Fetch dynamic values needed for checks
echo "--> Fetching current user and project numbers..."
CURRENT_USER=$(gcloud config get-value account --quiet)
COMPUTE_PROJECT_NUMBER=$(gcloud projects describe "$COMPUTE_PROJECT_ID" --format='value(projectNumber)' --quiet)
echo "    - Verifying as user: ${CURRENT_USER}"
echo "    - Compute Project Number: ${COMPUTE_PROJECT_NUMBER}"

# --- 3. Verify Projects ---
echo
echo "--- Verifying GCP Project Existence & Status ---"
gcloud projects describe "$ASSETS_PROJECT_ID" --format="value(lifecycleState)" | grep -q "ACTIVE"
print_result $? "Assets Project '${ASSETS_PROJECT_ID}' is ACTIVE" "gcloud projects create '${ASSETS_PROJECT_ID}' ..."

gcloud projects describe "$STORAGE_PROJECT_ID" --format="value(lifecycleState)" | grep -q "ACTIVE"
print_result $? "Storage Project '${STORAGE_PROJECT_ID}' is ACTIVE" "gcloud projects create '${STORAGE_PROJECT_ID}' ..."

gcloud projects describe "$COMPUTE_PROJECT_ID" --format="value(lifecycleState)" | grep -q "ACTIVE"
print_result $? "Compute Project '${COMPUTE_PROJECT_ID}' is ACTIVE" "gcloud projects create '${COMPUTE_PROJECT_ID}' ..."

# --- 4. Verify Enabled APIs ---
echo
echo "--- Verifying Required GCP APIs ---"
gcloud services list --enabled --project="$ASSETS_PROJECT_ID" --filter="config.name:artifactregistry.googleapis.com" --format="value(config.name)" | grep -q "artifactregistry"
print_result $? "API 'artifactregistry.googleapis.com' is enabled in Assets Project" "gcloud services enable artifactregistry.googleapis.com --project='${ASSETS_PROJECT_ID}'"

gcloud services list --enabled --project="$STORAGE_PROJECT_ID" --filter="config.name:storage.googleapis.com" --format="value(config.name)" | grep -q "storage"
print_result $? "API 'storage.googleapis.com' is enabled in Storage Project" "gcloud services enable storage.googleapis.com --project='${STORAGE_PROJECT_ID}'"

gcloud services list --enabled --project="$COMPUTE_PROJECT_ID" --filter="config.name:run.googleapis.com" --format="value(config.name)" | grep -q "run"
print_result $? "API 'run.googleapis.com' is enabled in Compute Project" "gcloud services enable run.googleapis.com --project='${COMPUTE_PROJECT_ID}'"

gcloud services list --enabled --project="$COMPUTE_PROJECT_ID" --filter="config.name:iam.googleapis.com" --format="value(config.name)" | grep -q "iam"
print_result $? "API 'iam.googleapis.com' is enabled in Compute Project" "gcloud services enable iam.googleapis.com --project='${COMPUTE_PROJECT_ID}'"

# --- 5. Verify Specific Resources ---
echo
echo "--- Verifying Specific GCP Resources ---"
gcloud artifacts repositories describe "$ARTIFACT_REGISTRY_NAME" --project="$ASSETS_PROJECT_ID" --location="$ASSETS_GCP_REGION" &> /dev/null
print_result $? "Artifact Registry repo '${ARTIFACT_REGISTRY_NAME}' exists" "gcloud artifacts repositories create '${ARTIFACT_REGISTRY_NAME}' --repository-format=docker --location='${ASSETS_GCP_REGION}' --project='${ASSETS_PROJECT_ID}'"

gsutil ls -b "gs://${GCS_BUCKET_NAME}" &> /dev/null
print_result $? "GCS Bucket 'gs://${GCS_BUCKET_NAME}' exists" "gsutil mb -p '${STORAGE_PROJECT_ID}' 'gs://${GCS_BUCKET_NAME}'"

gcloud run jobs describe "$CLOUD_RUN_JOB_NAME" --project="$COMPUTE_PROJECT_ID" --region="$COMPUTE_GCP_REGION" &> /dev/null
print_result $? "Cloud Run Job '${CLOUD_RUN_JOB_NAME}' exists" "task deploy"

# --- 6. Verify IAM Permissions ---
echo
echo "--- Verifying Key IAM Permissions ---"
# Check 1: Developer can push to Artifact Registry
gcloud projects get-iam-policy "$ASSETS_PROJECT_ID" --flatten="bindings[].members" --filter="bindings.role='roles/artifactregistry.writer' AND bindings.members='user:${CURRENT_USER}'" --format="value(bindings.members)" | grep -q "${CURRENT_USER}"
print_result $? "Developer (${CURRENT_USER}) has 'Artifact Registry Writer' on Assets Project" "gcloud projects add-iam-policy-binding '${ASSETS_PROJECT_ID}' --member='user:${CURRENT_USER}' --role='roles/artifactregistry.writer'"

# Check 2: Cloud Run can pull from Artifact Registry
CLOUD_RUN_SERVICE_AGENT="service-${COMPUTE_PROJECT_NUMBER}@gcp-sa-run.iam.gserviceaccount.com"
gcloud projects get-iam-policy "$ASSETS_PROJECT_ID" --flatten="bindings[].members" --filter="bindings.role='roles/artifactregistry.reader' AND bindings.members='serviceAccount:${CLOUD_RUN_SERVICE_AGENT}'" --format="value(bindings.members)" | grep -q "${CLOUD_RUN_SERVICE_AGENT}"
print_result $? "Cloud Run Service Agent has 'Artifact Registry Reader' on Assets Project" "gcloud projects add-iam-policy-binding '${ASSETS_PROJECT_ID}' --member='serviceAccount:${CLOUD_RUN_SERVICE_AGENT}' --role='roles/artifactregistry.reader'"

# Check 3: Cloud Run Job's SA can write to the GCS bucket
EFFECTIVE_SA=${TARGET_PRINCIPAL_SA}
gsutil iam get "gs://${GCS_BUCKET_NAME}" | grep -A 2 "roles/storage.objectAdmin" | grep -q "serviceAccount:${EFFECTIVE_SA}"
print_result $? "Job SA (${EFFECTIVE_SA}) has 'Storage Object Admin' on GCS Bucket" "gsutil iam ch 'serviceAccount:${EFFECTIVE_SA}:objectAdmin' 'gs://${GCS_BUCKET_NAME}'"


echo
echo -e "--- ${GREEN}Verification Complete${NC} ---"