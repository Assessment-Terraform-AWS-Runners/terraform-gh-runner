#!/bin/bash
set -e

GITHUB_URL="$1"
RUNNER_TOKEN="$2"
RUNNER_COUNT="$3"
INSTANCE_INDEX="$4"

RUNNER_VERSION="2.330.0"
BASE_DIR="/home/ec2-user/actions-runner"

sudo yum update -y
sudo yum install -y curl git tar

cd /home/ec2-user

for i in $(seq 1 "$RUNNER_COUNT"); do
  RUNNER_DIR="${BASE_DIR}-${INSTANCE_INDEX}-${i}"

  if [ -d "$RUNNER_DIR" ]; then
    echo "Runner already exists: $RUNNER_DIR"
    continue
  fi

  mkdir "$RUNNER_DIR"
  cd "$RUNNER_DIR"

  curl -L -o runner.tar.gz \
    https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz

  tar xzf runner.tar.gz
  rm -f runner.tar.gz

  ./config.sh \
    --url "$GITHUB_URL" \
    --token "$RUNNER_TOKEN" \
    --name "ec2-${INSTANCE_INDEX}-runner-${i}" \
    --labels "self-hosted,ec2" \
    --unattended \
    --replace

  sudo ./svc.sh install ec2-user
  sudo ./svc.sh start

  cd /home/ec2-user
done
