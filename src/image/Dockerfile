FROM mcr.microsoft.com/powershell:7.3-ubuntu-22.04

# set the github runner version
ARG RUNNER_VERSION=2.317.0

# prevents installdependencies.sh from prompting the user and blocking the image creation
ARG DEBIAN_FRONTEND=noninteractive

LABEL Author="Eskil Uhlving Larsen"
LABEL GitHub="https://github.com/picccard"
LABEL BaseImage="mcr.microsoft.com/powershell:7.3-ubuntu-22.04"
LABEL RunnerVersion=${RUNNER_VERSION}

# update the base packages and add a non-sudo user
RUN apt-get update -y && apt-get upgrade -y && useradd -m docker

# install python and the packages the your code depends on along with jq so we can parse JSON
# add additional packages as necessary
RUN apt-get install -y --no-install-recommends \
    apt-utils curl nodejs wget unzip vim git jq build-essential libssl-dev libffi-dev python3 python3-venv python3-dev python3-pip

# install the azure cli
RUN curl -sL https://aka.ms/InstallAzureCLIDeb | bash

# install the az module for powershell
RUN ["pwsh", "-c", "Install-Module -Name Az -RequiredVersion 12.1.0 -Scope AllUsers -Force"]

# install bicep
RUN curl -Lo bicep https://github.com/Azure/bicep/releases/latest/download/bicep-linux-x64 \
    && chmod +x ./bicep && mv ./bicep /usr/local/bin/bicep

# cd into the user directory, download and unzip the github actions runner
RUN cd /home/docker && mkdir actions-runner && cd actions-runner \
    && curl -O -L https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz \
    && tar xzf ./actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz

# install some additional dependencies
RUN chown -R docker /home/docker && /home/docker/actions-runner/bin/installdependencies.sh

# copy over the start.sh script
COPY start.sh start.sh

# make the script executable
RUN chmod +x start.sh

# since the config and run script for actions are not allowed to be run by root,
# set the user to "docker" so all subsequent commands are run as the docker user
USER docker

# set the entrypoint to the start.sh script
ENTRYPOINT ["./start.sh"]