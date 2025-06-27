#!/bin/bash
# scripts/provision_guide.sh
# Displays a comprehensive, dynamic checklist for provisioning the environment.

# Exit immediately if a command that can fail (like gcloud) fails.
set -e

# --- Main Execution Block ---

echo "----------------------------------------------------------------------"
echo "--- Infrastructure Provisioning Guide ---"
echo "----------------------------------------------------------------------"
echo
echo -e "\033[1mThree-Project Setup (Recommended Best Practice)\033[0m"
echo "This project is designed to use three separate GCP projects to enhance"
echo "security, IAM separation, and billing clarity:"
echo "  🎨 Assets Project:  Holds the container images in Artifact Registry."
echo "  📦 Storage Project: Holds the GCS buckets and application data."
echo "  ⚙️  Compute Project: Holds the Cloud Run job and its service accounts."

# --- Assets Project ---
echo
echo -e "\033[1m--- 1. 🎨 Assets Project Checklist (${ASSETS_PROJECT_ID}) ---\033[0m"
echo "   [ ] GCP Project should exist with ID '${ASSETS_PROJECT_ID}'."
echo "   [ ] Billing should be enabled for the project."
echo "   [ ] API 'artifactregistry.googleapis.com' should be enabled."
echo "   [ ] A Docker Artifact Registry repository named '${ARTIFACT_REGISTRY_NAME}' should exist in region '${ASSETS_GCP_REGION}'."

# --- Storage Project ---
echo
echo -e "\033[1m--- 2. 📦 Storage Project Checklist (${STORAGE_PROJECT_ID}) ---\033[0m"
echo "   [ ] GCP Project should exist with ID '${STORAGE_PROJECT_ID}'."
echo "   [ ] Billing should be enabled for the project."
echo "   [ ] API 'storage.googleapis.com' should be enabled."
echo "   [ ] A GCS Bucket named '${GCS_BUCKET_NAME}' should exist."

# --- Compute Project ---
echo
echo -e "\033[1m--- 3. ⚙️  Compute Project Checklist (${COMPUTE_PROJECT_ID}) ---\033[0m"
echo "   [ ] GCP Project should exist with ID '${COMPUTE_PROJECT_ID}'."
echo "   [ ] Billing should be enabled for the project."
echo "   [ ] APIs 'run.googleapis.com' and 'iam.googleapis.com' should be enabled."

# --- IAM Permissions ---
# Fetch dynamic data needed for the IAM checklist
CURRENT_USER=$(gcloud config get-value account --quiet)
COMPUTE_PROJECT_NUMBER=$(gcloud projects describe "${COMPUTE_PROJECT_ID}" --format='value(projectNumber)' --quiet 2>/dev/null || echo "COMPUTE_PROJECT_NUMBER_NOT_FOUND")

echo
echo -e "\033[1m--- 4. 🔑 IAM Permissions Checklist ---\033[0m"
echo "   [ ] DEVELOPER (to push images): Your account (${CURRENT_USER}) needs the 'Artifact Registry Writer' role on the Assets Project '${ASSETS_PROJECT_ID}'."
echo "   [ ] DEPLOYMENT (to pull images): The Cloud Run Service Agent (service-${COMPUTE_PROJECT_NUMBER}@gcp-sa-run.iam.gserviceaccount.com) of the Compute Project needs the 'Artifact Registry Reader' role on the Assets Project '${ASSETS_PROJECT_ID}'."

echo -e "\n[ OK ] End of provisioning checklist."