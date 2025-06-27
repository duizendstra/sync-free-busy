#!/bin/bash
# scripts/release.sh
# This script performs a versioned release, including safety checks,
# git tagging, building, pushing, and deploying.

# Exit immediately if any command fails.
set -e

# --- 1. Input Validation ---
VERSION=$1
if [ -z "$VERSION" ]; then
  echo "Error: No version tag provided." >&2
  echo "Usage: ./scripts/release.sh v1.2.3" >&2
  exit 1
fi

echo "--> Starting release process for version: ${VERSION}"

# --- 2. Pre-flight Safety Checks ---
echo "--> Running pre-flight safety checks..."

if ! git diff --quiet --exit-code; then
  echo "Error: You have uncommitted changes. Please commit or stash them before releasing." >&2
  exit 1
fi

if git rev-parse -q --verify "refs/tags/${VERSION}" >/dev/null; then
  echo "Error: Git tag '${VERSION}' already exists." >&2
  exit 1
fi

echo "--> Running tests..."
# We call back to the task runner to execute the full test suite.
if ! task test; then
    echo "Error: Tests failed. Aborting release." >&2
    exit 1
fi

echo "✅ Pre-flight checks passed."

# --- 3. Tagging and Deployment ---
# This section reuses logic from the deploy.sh script but is self-contained.
GIT_COMMIT=$(git rev-parse --short HEAD)
IMAGE_FQN="${ARTIFACT_REGISTRY_REPO}/${CONTAINER_NAME}"
PROJECT_NUMBER=$(gcloud projects describe "$COMPUTE_PROJECT_ID" --format='value(projectNumber)')
DEFAULT_SA="${PROJECT_NUMBER}-compute@developer.gserviceaccount.com"
EFFECTIVE_SA=${TARGET_PRINCIPAL_SA:-$DEFAULT_SA}
ENV_VARS_STRING="^;^TARGET_USER_EMAILS=${TARGET_USER_EMAILS};GCS_BUCKET_NAME=${GCS_BUCKET_NAME};TARGET_PRINCIPAL_SA=${EFFECTIVE_SA};GOOGLE_CLOUD_PROJECT=${COMPUTE_PROJECT_ID};LOG_LEVEL=${LOG_LEVEL}"

echo "--> Creating git tag '${VERSION}'..."
git tag -a "${VERSION}" -m "Release ${VERSION}"

echo "--> Building and pushing container image: ${IMAGE_FQN}:${VERSION}"
gcloud auth configure-docker "${ASSETS_GCP_REGION}-docker.pkg.dev" --quiet
docker buildx build \
  --platform linux/amd64 \
  -t "${IMAGE_FQN}:${VERSION}" \
  -t "${IMAGE_FQN}:latest" \
  --push \
  .

echo "--> Deploying job '${CLOUD_RUN_JOB_NAME}' with image tag '${VERSION}'..."
gcloud run jobs deploy "${CLOUD_RUN_JOB_NAME}" \
  --image "${IMAGE_FQN}:${VERSION}" \
  --region "${COMPUTE_GCP_REGION}" \
  --service-account "${EFFECTIVE_SA}" \
  --set-env-vars="${ENV_VARS_STRING}" \
  --project="${COMPUTE_PROJECT_ID}" \
  --quiet

# --- 4. Finalization ---
echo "--> Pushing git tag to remote..."
git push origin "${VERSION}"

echo -e "\n[ ✅ SUCCESS ] Release ${VERSION} is complete."