#!/bin/bash
# scripts/test.sh
# A self-contained script for running all project tests.

# --- Script Parameters ---
# The log file path is expected as the first argument.
# Default to 'test-results.log' if no argument is provided.
TEST_LOG_FILE=${1:-test-results.log}

# --- Main Logic ---
echo
echo "Please select a test suite to run:"
PS3="Your choice: "
select opt in \
  "Run unit tests (no race detector)" \
  "Run unit tests (WITH race detector)" \
  "Run SLOW end-to-end integration tests (will deploy first)" \
  "View unit test coverage report" \
  "Quit"
do
  case $opt in
    "Run unit tests (no race detector)")
      echo "--> Running all unit tests (no race detector). Output will be saved to ${TEST_LOG_FILE}"
      # The command now lives directly in the script.
      (go test -coverprofile=coverage.out ./... 2>&1 | tee "${TEST_LOG_FILE}"; exit "${PIPESTATUS[0]}")
      break
      ;;
    "Run unit tests (WITH race detector)")
      echo "--> Running all unit tests with race detector enabled. Output will be saved to ${TEST_LOG_FILE}"
      (CGO_ENABLED=1 go test -race -coverprofile=coverage.out ./... 2>&1 | tee "${TEST_LOG_FILE}"; exit "${PIPESTATUS[0]}")
      break
      ;;
    "Run SLOW end-to-end integration tests (will deploy first)")
      echo "--> This will first deploy the application and then run the integration tests."
      # We call the main `task deploy` command, which is an acceptable cross-boundary call.
      (task deploy && task _test:run-integration) || echo -e "\n\033[0;31m[ ❌ FAILURE ] Deploy or Integration Test failed.\033[0m"
      break
      ;;
    "View unit test coverage report")
      if [ ! -f coverage.out ]; then
        echo "Error: Coverage report 'coverage.out' not found. Please run a unit test first."
        exit 1
      fi
      echo "--> Opening HTML coverage report..."
      go tool cover -html=coverage.out
      break
      ;;
    "Quit")
      echo "Aborted."
      break
      ;;
    *) echo "Invalid option $REPLY";;
  esac
done