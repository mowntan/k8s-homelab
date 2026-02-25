#!/bin/bash
set -e

# Fetch a fresh registration token using the PAT
REG_TOKEN=$(curl -fsSL \
  -X POST \
  -H "Authorization: token ${GITHUB_PAT}" \
  -H "Accept: application/vnd.github+json" \
  "https://api.github.com/repos/${GITHUB_REPOSITORY}/actions/runners/registration-token" \
  | jq -r '.token')

if [ -z "${REG_TOKEN}" ] || [ "${REG_TOKEN}" = "null" ]; then
  echo "ERROR: Failed to obtain registration token. Check GITHUB_PAT and GITHUB_REPOSITORY."
  exit 1
fi

# Deregister cleanly on shutdown
cleanup() {
  echo "Deregistering runner..."
  ./config.sh remove --token "${REG_TOKEN}" || true
  exit 0
}
trap cleanup SIGINT SIGTERM

# Configure the runner
./config.sh \
  --url "https://github.com/${GITHUB_REPOSITORY}" \
  --token "${REG_TOKEN}" \
  --name "${RUNNER_NAME:-$(hostname)}" \
  --labels "${RUNNER_LABELS:-self-hosted,linux}" \
  --work "${RUNNER_WORKDIR:-/work}" \
  --unattended \
  --replace

# Start the runner
./run.sh
