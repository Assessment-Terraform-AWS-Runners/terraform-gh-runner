#!/bin/bash
set -e

GITHUB_URL="$1"
RUNNER_TOKEN="$2"
RUNNER_COUNT="$3"

RUNNER_VERSION="2.330.0"
RUNNER_BASE_DIR="/home/ec2-user"

echo "Repo URL     : $GITHUB_URL"
echo "Runner count : $RUNNER_COUNT"
echo "User         : ec2-user"

sudo yum update -y
sudo yum install -y curl git tar

cd "$RUNNER_BASE_DIR"

for i in $(seq 1 "$RUNNER_COUNT"); do
  RUNNER_DIR="actions-runner-$i"
  RUNNER_NAME="ec2-runner-$i"

  echo "-------------------------------------"
  echo " Installing $RUNNER_NAME"
  echo "-------------------------------------"

  mkdir -p "$RUNNER_DIR"
  cd "$RUNNER_DIR"

  # Download runner if not exists
  if [ ! -f "config.sh" ]; then
    curl -s -L -o actions-runner.tar.gz \
      https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz
    tar xzf actions-runner.tar.gz
  fi

  # Configure runner only once
  if [ ! -f ".runner" ]; then
    ./config.sh \
      --url "$GITHUB_URL" \
      --token "$RUNNER_TOKEN" \
      --name "$RUNNER_NAME" \
      --labels "self-hosted,ec2" \
      --unattended \
      --replace
  else
    echo "Runner $RUNNER_NAME already configured"
  fi

  # Install + start service
  sudo ./svc.sh install
  sudo ./svc.sh start
  sudo ./svc.sh status

  cd ..
done

echo "✅ All GitHub runners installed and running"
