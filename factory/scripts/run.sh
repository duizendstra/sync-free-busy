#!/bin/bash
# scripts/run.sh
# An interactive script to run the application in various modes.

# Exit immediately if a command exits with a non-zero status.
set -e

# --- Helper Functions ---

# Function to ensure all required environment variables are loaded.
# Task will pass most of these, but this makes the script runnable standalone.
load_env() {
  if [ -f .env ]; then
    # The 'set -a' command exports all variables created or modified.
    set -a
    source .env
    set +a
  else
    echo "Warning: .env file not found."
  fi
}

# Function to build the local binary.
build_binary() {
  echo "--> Building Go binary into ./bin/..."
  mkdir -p ./bin
  go build -v -o ./bin/florbs-go-job-worker ./cmd/main.go
}

# Function to build the local container image.
build_container() {
  echo "--> Building local image ${IMAGE_FQN}:${GIT_COMMIT}..."
  docker buildx build \
    --platform linux/amd64 \
    -t "${IMAGE_FQN}:${GIT_COMMIT}" \
    -t "${IMAGE_FQN}:latest" \
    .
}

# --- Main Logic ---

# 1. Load environment variables from .env file.
load_env

# 2. Define dynamic variables needed for container runs.
GIT_COMMIT=$(git rev-parse --short HEAD)
IMAGE_FQN="${ARTIFACT_REGISTRY_REPO}/${CONTAINER_NAME}"
CURRENT_USER=$(gcloud config get-value account --quiet)

# 3. Display the interactive menu.
echo
echo "Please select a run mode:"
PS3="Your choice: "
select opt in \
  "Run from local source code as (${CURRENT_USER})" \
  "Run from compiled binary as (${CURRENT_USER})" \
  "Run in a single container (index from .env)" \
  "Run all containers for the job (count from .env)" \
  "Trigger a remote job on Cloud Run" \
  "Quit"
do
  case $opt in
    "Run from local source code as (${CURRENT_USER})")
      echo "--> Running Go application from source..."
      # This assumes the .env file has been loaded.
      GOOGLE_APPLICATION_CREDENTIALS=./sa-key.json go run ./cmd/main.go
      break
      ;;

    "Run from compiled binary as (${CURRENT_USER})")
      build_binary
      echo "--> Running the locally built binary..."
      GOOGLE_APPLICATION_CREDENTIALS=./sa-key.json ./bin/florbs-go-job-worker
      break
      ;;

    "Run in a single container (index from .env)")
      build_container
      echo "--> Starting single container for CLOUD_RUN_TASK_INDEX=${CLOUD_RUN_TASK_INDEX}..."
      # Pass required vars to docker-compose. It will also use the .env file.
      GIT_COMMIT=${GIT_COMMIT} ARTIFACT_REGISTRY_REPO=${ARTIFACT_REGISTRY_REPO} \
      docker-compose run --rm --name "worker-${CLOUD_RUN_TASK_INDEX}" florbs-go-job-worker
      break
      ;;

    "Run all containers for the job (count from .env)")
      # Define a cleanup function and set a trap to run it on exit.
      cleanup() {
        echo -e "\n\033[0;33m--> Shutting down and removing containers...\033[0m"
        GIT_COMMIT=${GIT_COMMIT} ARTIFACT_REGISTRY_REPO=${ARTIFACT_REGISTRY_REPO} \
        docker-compose down --remove-orphans
      }
      trap cleanup EXIT

      build_container
      echo "--> Starting ${CLOUD_RUN_TASK_COUNT} job containers in the background..."
      for i in $(seq 0 $(expr ${CLOUD_RUN_TASK_COUNT} - 1)); do
        GIT_COMMIT=${GIT_COMMIT} ARTIFACT_REGISTRY_REPO=${ARTIFACT_REGISTRY_REPO} \
        docker-compose run --rm -d --name "worker-$i" -e "CLOUD_RUN_TASK_INDEX=$i" florbs-go-job-worker
      done
      echo -e "\n\033[0;32m[  OK  ]\033[0m All containers started. Streaming logs now (press Ctrl+C to stop)..."
      docker-compose logs -f --tail="all"
      break
      ;;

    "Trigger a remote job on Cloud Run")
      TASK_COUNT=$(echo "${TARGET_USER_EMAILS}" | tr ',' '\n' | wc -l | xargs)
      ENV_VARS_STRING="^;^TARGET_USER_EMAILS=${TARGET_USER_EMAILS};GCS_BUCKET_NAME=${GCS_BUCKET_NAME};TARGET_PRINCIPAL_SA=${TARGET_PRINCIPAL_SA};GOOGLE_CLOUD_PROJECT=${COMPUTE_PROJECT_ID};LOG_LEVEL=${LOG_LEVEL}"

      echo "--> Triggering remote Cloud Run Job '${CLOUD_RUN_JOB_NAME}' with ${TASK_COUNT} tasks..."
      # *** THIS IS THE CORRECTED LINE ***
      gcloud run jobs update "${CLOUD_RUN_JOB_NAME}" \
        --region "${COMPUTE_GCP_REGION}" \
        --project "${COMPUTE_PROJECT_ID}" \
        --tasks "${TASK_COUNT}" \
        --parallelism "${CLOUD_RUN_TASK_PARALISM}" \
        --update-env-vars="${ENV_VARS_STRING}" \
        --wait
      break
      ;;

    "Quit")
      echo "Aborted."
      break
      ;;
    *) echo "Invalid option $REPLY";;
  esac
done