FROM ubuntu:focal

# You would typically obtain this latest version from an API endpoint and use that for the runner version
# as the runner will self update to the latest version when it gets its first job.
# The reason this is specified is so that we can test the upgrade scenarios using this Dockerfile.
ARG GH_RUNNER_VERSION=2.285.1

ENV RUNNER_NAME=""
ENV GITHUB_SERVER=""
ENV GITHUB_TOKEN=""
ENV RUNNER_LABELS=""
ENV RUNNER_WORK_DIRECTORY="_work"
ENV RUNNER_ALLOW_RUNASROOT=false
ENV AGENT_TOOLS_DIRECTORY=/opt/hostedtoolcache

# Create a user for running actions
RUN useradd -m actions
RUN mkdir -p /home/actions ${AGENT_TOOLS_DIRECTORY}
WORKDIR /home/actions

# jq is used by the runner to extract the token when registering the runner
RUN export DEBIAN_FRONTEND=noninteractive \
    && apt-get update \
    && apt-get install curl jq git -y \
    && apt-get -y install sudo -y \
    && curl -L -O https://github.com/actions/runner/releases/download/v${GH_RUNNER_VERSION}/actions-runner-linux-x64-${GH_RUNNER_VERSION}.tar.gz \
    && tar -zxf actions-runner-linux-x64-${GH_RUNNER_VERSION}.tar.gz \
    && rm -f actions-runner-linux-x64-${GH_RUNNER_VERSION}.tar.gz \
    && ./bin/installdependencies.sh \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Copy out the runsvc.sh script to the root directory for running the service
RUN cp bin/runsvc.sh . && chmod +x ./runsvc.sh

COPY entrypoint.sh .
RUN chmod +x ./entrypoint.sh

# Now that the OS has been updated to include required packages, update ownership and then switch to actions user
RUN chown -R actions:actions /home/actions ${AGENT_TOOLS_DIRECTORY}

USER actions
CMD [ "./entrypoint.sh" ]
