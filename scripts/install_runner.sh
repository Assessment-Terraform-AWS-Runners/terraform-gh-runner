#!/bin/bash
set -e

GITHUB_URL="$1"
RUNNER_TOKEN="$2"
RUNNER_COUNT="$3"

RUNNER_VERSION="2.330.0"
BASE_DIR="/home/ec2-user/actions-runners"

echo "========================================="
echo " GitHub Runner Installation"
echo " Repo URL     : $GITHUB_URL"
echo " Runner Count : $RUNNER_COUNT"
echo " User         : ec2-user"
echo "========================================="

sudo yum install -y curl git tar

mkdir -p "$BASE_DIR"
cd "$BASE_DIR"

for i in $(seq 1 "$RUNNER_COUNT"); do
  RUNNER_NAME="ec2-runner-$i"
  RUNNER_DIR="$BASE_DIR/runner-$i"
  WORK_DIR="$RUNNER_DIR/_work"

  echo "---- Installing $RUNNER_NAME ----"

  mkdir -p "$RUNNER_DIR"
  cd "$RUNNER_DIR"

  curl -Ls -o runner.tar.gz \
    https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz

  tar xzf runner.tar.gz
  rm -f runner.tar.gz

  ./config.sh \
    --url "$GITHUB_URL" \
    --token "$RUNNER_TOKEN" \
    --name "$RUNNER_NAME" \
    --labels "self-hosted,ec2" \
    --work "$WORK_DIR" \
    --unattended \
    --replace

  sudo ./svc.sh install ec2-user
  sudo ./svc.sh start

  cd "$BASE_DIR"
done

echo "✅ All runners installed and started"
