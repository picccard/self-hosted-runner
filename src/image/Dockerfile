FROM mcr.microsoft.com/powershell:7.3-ubuntu-22.04

# set the github runner version
ARG RUNNER_VERSION=2.317.0

# prevents installdependencies.sh from prompting the user and blocking the image creation
ARG DEBIAN_FRONTEND=noninteractive

LABEL Author="Eskil Uhlving Larsen"
LABEL GitHub="https://github.com/picccard"
LABEL BaseImage="mcr.microsoft.com/powershell:7.3-ubuntu-22.04"
LABEL RunnerVersion=${RUNNER_VERSION}

# Official Debian and Ubuntu images automatically run apt-get clean, so explicit invocation is not required.

# SKIP update the base packages
# RUN apt-get update -y && apt-get upgrade -y && apt-get clean && rm -rf /var/lib/apt/lists/*

# install the packages the your code depends
# install curl and jq for fetching registration-token for the runner
# install sudo for sudo usage from inside actions workflow as non-root user
# add additional packages as necessary
RUN apt-get update -y && \
    apt-get install -y --no-install-recommends \
    curl \
    jq \
sudo \
    unzip \
    git \
    wget && \
    apt-get clean &&  rm -rf /var/lib/apt/lists/*
# nodejs build-essential libssl-dev libffi-dev python3 python3-venv python3-dev python3-pip && \

# SKIP install the azure cli
# RUN curl -sL https://aka.ms/InstallAzureCLIDeb | bash && apt-get clean && rm -rf /var/lib/apt/lists/*
# SKIP install the az module for powershell
# RUN ["pwsh", "-c", "Install-Module -Name Az -RequiredVersion 12.1.0 -Scope AllUsers -Force"]

# SKIP install bicep
# RUN curl -Lo bicep https://github.com/Azure/bicep/releases/latest/download/bicep-linux-x64 && chmod +x ./bicep && mv ./bicep /usr/local/bin/bicep

# add a non-sudo user
# RUN useradd -m docker

# add a user and add to the sudo group
RUN newuser=docker && \
		adduser --disabled-password --gecos "" $newuser && \
		usermod -aG sudo $newuser && \
		echo "$newuser ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# set the working directory to the user directory
WORKDIR /home/docker/actions-runner

# download and unzip the github actions runner
RUN curl -f -L -o runner.tar.gz https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz && \
    tar xzf ./runner.tar.gz && \
    rm runner.tar.gz && \
    chown -R docker /home/docker

# install runner dependencies
RUN ./bin/installdependencies.sh && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# copy over the start.sh script
COPY start.sh start.sh

# make the script executable
RUN chmod +x start.sh

# since the config and run script for actions are not allowed to be run by root,
# set the user to "docker" so all subsequent commands are run as the docker user
USER docker

# set the entrypoint to the start.sh script
ENTRYPOINT ["./start.sh"]