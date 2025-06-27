#!/bin/bash
# scripts/deploy.sh
# This script orchestrates the entire deployment process. It builds, pushes,
# and then deploys the container to Cloud Run.

# Exit immediately if any command fails.
set -e

# --- 1. Define Variables ---
echo "--> Gathering deployment variables..."

# These variables are passed from the calling Taskfile via the 'env' block.
# This script now constructs the full repository path itself.
ARTIFACT_REGISTRY_REPO="${ASSETS_GCP_REGION}-docker.pkg.dev/${ASSETS_PROJECT_ID}/${ARTIFACT_REGISTRY_NAME}"
GIT_COMMIT=$(git rev-parse --short HEAD)
IMAGE_FQN="${ARTIFACT_REGISTRY_REPO}/${CONTAINER_NAME}"
PROJECT_NUMBER=$(gcloud projects describe "$COMPUTE_PROJECT_ID" --format='value(projectNumber)')
DEFAULT_SA="${PROJECT_NUMBER}-compute@developer.gserviceaccount.com"
# Use bash parameter expansion to provide a default value if TARGET_PRINCIPAL_SA is empty.
EFFECTIVE_SA=${TARGET_PRINCIPAL_SA:-$DEFAULT_SA}

# Use the gcloud `^;^` prefix to change the delimiter to a semicolon,
# allowing commas in our TARGET_USER_EMAILS variable.
ENV_VARS_STRING="^;^TARGET_USER_EMAILS=${TARGET_USER_EMAILS};GCS_BUCKET_NAME=${GCS_BUCKET_NAME};TARGET_PRINCIPAL_SA=${EFFECTIVE_SA};GOOGLE_CLOUD_PROJECT=${COMPUTE_PROJECT_ID};LOG_LEVEL=${LOG_LEVEL}"

# --- 2. Build and Push Container ---
echo
echo "--> Building and pushing container image: ${IMAGE_FQN}:${GIT_COMMIT}"
# First, ensure Docker is authenticated with the correct Artifact Registry.
gcloud auth configure-docker "${ASSETS_GCP_REGION}-docker.pkg.dev" --quiet

# Build and push in a single, efficient step.
docker buildx build \
  --platform linux/amd64 \
  -t "${IMAGE_FQN}:${GIT_COMMIT}" \
  -t "${IMAGE_FQN}:latest" \
  --push \
  .

# --- 3. Deploy to Cloud Run ---
echo
echo "--> Deploying job '${CLOUD_RUN_JOB_NAME}' to region '${COMPUTE_GCP_REGION}'..."
gcloud run jobs deploy "${CLOUD_RUN_JOB_NAME}" \
  --image "${IMAGE_FQN}:${GIT_COMMIT}" \
  --region "${COMPUTE_GCP_REGION}" \
  --service-account "${EFFECTIVE_SA}" \
  --set-env-vars="${ENV_VARS_STRING}" \
  --project="${COMPUTE_PROJECT_ID}" \
  --quiet

echo -e "\n[ OK ] Deployment command executed successfully."