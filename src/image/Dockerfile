FROM mcr.microsoft.com/powershell:7.3-ubuntu-22.04

ARG RUNNER_VERSION
ENV DEBIAN_FRONTEND=noninteractive

LABEL Author="Eskil Uhlving Larsen"
LABEL GitHub="https://github.com/picccard"
LABEL BaseImage="mcr.microsoft.com/powershell:7.3-ubuntu-22.04"
LABEL RunnerVersion=${RUNNER_VERSION}

RUN apt-get update -y && apt-get upgrade -y && useradd -m docker
RUN apt-get install -y --no-install-recommends \
    apt-utils curl nodejs wget unzip vim git jq build-essential libssl-dev libffi-dev python3 python3-venv python3-dev python3-pip

RUN curl -sL https://aka.ms/InstallAzureCLIDeb | bash

RUN ["pwsh", "-c", "Install-Module -Name Az -RequiredVersion 12.1.0 -Scope AllUsers -Force"]

RUN cd /home/docker && mkdir actions-runner && cd actions-runner \
    && curl -O -L https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz \
    && tar xzf ./actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz

RUN chown -R docker /home/docker && /home/docker/actions-runner/bin/installdependencies.sh

COPY start.sh start.sh
RUN chmod +x start.sh
# set the user to "docker" so all subsequent commands are run as the docker user
USER docker
ENTRYPOINT ["./start.sh"]