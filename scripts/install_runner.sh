#!/bin/bash
set -e

GITHUB_URL="$1"
RUNNER_TOKEN="$2"
RUNNER_COUNT="$3"
INSTANCE_INDEX="$4"

RUNNER_VERSION="2.330.0"
RUNNER_BASE_DIR="/home/ec2-user/actions-runners"

echo "==============================="
echo "GitHub Runner Installation"
echo "Repo URL        : $GITHUB_URL"
echo "Runner Count    : $RUNNER_COUNT"
echo "Instance Index  : $INSTANCE_INDEX"
echo "==============================="

# Install prereqs
sudo yum update -y
sudo yum install -y curl git tar

# Ensure base directory exists AND OWNERSHIP IS CORRECT
sudo mkdir -p "$RUNNER_BASE_DIR"
sudo chown -R ec2-user:ec2-user "$RUNNER_BASE_DIR"

cd "$RUNNER_BASE_DIR"

for i in $(seq 1 "$RUNNER_COUNT"); do
  RUNNER_NAME="ec2-${INSTANCE_INDEX}-runner-${i}"
  RUNNER_DIR="runner-${i}"

  echo "---- Installing $RUNNER_NAME ----"

  mkdir -p "$RUNNER_DIR"
  cd "$RUNNER_DIR"

  if [ ! -f "./config.sh" ]; then
    curl -L -o runner.tar.gz \
      https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz
    tar xzf runner.tar.gz
  fi

  sudo chown -R ec2-user:ec2-user .

  ./config.sh \
    --url "$GITHUB_URL" \
    --token "$RUNNER_TOKEN" \
    --name "$RUNNER_NAME" \
    --labels "self-hosted,ec2" \
    --unattended \
    --replace

  sudo ./svc.sh install
  sudo ./svc.sh start

  cd ..
done

echo "✅ All GitHub runners installed successfully"
