#!/bin/bash
set -e

GITHUB_URL="$1"
RUNNER_TOKEN="$2"
RUNNER_COUNT="$3"

RUNNER_VERSION="2.330.0"
RUNNER_USER="ghrunner"

echo "Installing GitHub runners..."
echo "Repo URL: $GITHUB_URL"
echo "Runner count: $RUNNER_COUNT"

# Create user if not exists
if ! id $RUNNER_USER &>/dev/null; then
  useradd -m $RUNNER_USER
fi

yum update -y
yum install -y curl git tar

cd /home/$RUNNER_USER

for i in $(seq 1 $RUNNER_COUNT); do
  RUNNER_DIR="actions-runner-$i"
  mkdir -p $RUNNER_DIR
  cd $RUNNER_DIR

  echo "Installing runner $i..."

  curl -L -o runner.tar.gz \
    https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz

  tar xzf runner.tar.gz
  chown -R $RUNNER_USER:$RUNNER_USER .

  sudo -u $RUNNER_USER ./config.sh \
    --url "$GITHUB_URL" \
    --token "$RUNNER_TOKEN" \
    --name "ec2-runner-$i" \
    --labels "ec2,self-hosted" \
    --unattended \
    --replace

  ./svc.sh install
  ./svc.sh start

  cd ..
done

echo "GitHub runners installed successfully"
