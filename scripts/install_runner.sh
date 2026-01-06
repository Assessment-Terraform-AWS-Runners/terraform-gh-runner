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

if [[ -z "$GITHUB_URL" || -z "$RUNNER_TOKEN" || -z "$RUNNER_COUNT" ]]; then
  echo "❌ Usage: ./install_runner.sh <repo_url> <runner_token> <runner_count>"
  exit 1
fi

# Dependencies
sudo yum update -y
sudo yum install -y curl git tar

mkdir -p "$BASE_DIR"
cd "$BASE_DIR"

for i in $(seq 1 "$RUNNER_COUNT"); do
  RUNNER_DIR="runner-$i"

  if [[ -d "$RUNNER_DIR" ]]; then
    echo "⚠ Runner $RUNNER_DIR already exists, skipping..."
    continue
  fi

  echo "---- Installing runner-$i ----"

  mkdir "$RUNNER_DIR"
  cd "$RUNNER_DIR"

  curl -L -o runner.tar.gz \
    https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz

  tar xzf runner.tar.gz
  rm -f runner.tar.gz

  ./config.sh \
    --url "$GITHUB_URL" \
    --token "$RUNNER_TOKEN" \
    --name "$(hostname)-runner-$i" \
    --labels "ec2,self-hosted" \
    --unattended \
    --replace

  sudo ./svc.sh install ec2-user
  sudo ./svc.sh start

  cd ..
done

echo "✅ All GitHub runners installed and started successfully"
