#!/bin/bash

# required env
OWNER=$OWNER
REPO=$REPO
ACCESS_TOKEN=$ACCESS_TOKEN

# optional env
RUNNER_NAME_PREFIX=${RUNNER_NAME_PREFIX:-github-runner}

# un-export these, so that they must be passed explicitly to the environment of
# any command that needs them. This may help prevent leaks.
export -n ACCESS_TOKEN
export -n REG_TOKEN

RUNNER_NAME=${RUNNER_NAME_PREFIX}-$(hostname)
# RUNNER_NAME=${RUNNER_NAME_PREFIX}-$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 13 ; echo '')

REG_TOKEN=$(curl -sX POST -H "Accept: application/vnd.github.v3+json" -H "Authorization: token ${ACCESS_TOKEN}" https://api.github.com/repos/${OWNER}/${REPO}/actions/runners/registration-token | jq .token --raw-output)
cd /home/docker/actions-runner
./config.sh --unattended --url https://github.com/${OWNER}/${REPO} --token ${REG_TOKEN} --name ${RUNNER_NAME} --ephemeral --disableupdate

cleanup() {
    echo "Removing runner..."
    ./config.sh remove --token ${REG_TOKEN}
}

trap 'cleanup; exit 130' INT
trap 'cleanup; exit 143' TERM

./run.sh & wait $!