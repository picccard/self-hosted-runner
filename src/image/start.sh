#!/bin/bash
OWNER=$OWNER
REPO=$REPO
ACCESS_TOKEN=$ACCESS_TOKEN

RUNNER_NAME="RUNNER-$(hostname)"


REG_TOKEN=$(curl -sX POST -H "Accept: application/vnd.github.v3+json" -H "Authorization: token ${ACCESS_TOKEN}" https://api.github.com/repos/${OWNER}/${REPO}/actions/runners/registration-token | jq .token --raw-output)
cd /home/docker/actions-runner
./config.sh --unattended --url https://github.com/${OWNER}/${REPO} --token ${REG_TOKEN} --name ${RUNNER_NAME} --ephemeral --disableupdate

cleanup() {
    echo "Removing runner..."
    ./config.sh remove --unattended --token ${REG_TOKEN}
}

trap 'cleanup; exit 130' INT
trap 'cleanup; exit 143' TERM

./run.sh & wait $!