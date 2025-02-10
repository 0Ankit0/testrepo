#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Ensure the token is provided
if [ -z "$RUNNER_TOKEN" ]; then
  echo "ERROR: RUNNER_TOKEN environment variable is not set."
  exit 1
fi

# Check if the runner is already configured
if [ ! -f .runner ]; then
  echo "Configuring the GitHub Actions Runner..."
  ./config.sh --url $RUNNER_URL --token $RUNNER_TOKEN --name $(hostname) --work _work --unattended --replace
fi

# Start the GitHub Actions Runner
echo "Starting the GitHub Actions Runner..."
./run.sh
