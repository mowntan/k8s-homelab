FROM debian:bookworm-slim

ARG RUNNER_VERSION=2.332.0
ARG TARGETARCH

# Install runtime dependencies
# docker-ce-cli is installed so workflow steps can invoke docker commands
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    ca-certificates \
    jq \
    git \
    unzip \
    libicu72 \
    libssl3 \
    && rm -rf /var/lib/apt/lists/*

# Create runner user (runner must be able to run as root for job setup,
# but we create a dedicated user and grant sudo for workflow steps)
RUN groupadd -g 1001 runner && \
    useradd -u 1001 -g runner -m -d /home/runner -s /bin/bash runner

# Download and extract the GitHub Actions runner
RUN ARCH=""; \
    case "${TARGETARCH}" in \
        amd64) ARCH="x64" ;; \
        arm64) ARCH="arm64" ;; \
    esac && \
    curl -fsSL "https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-${ARCH}-${RUNNER_VERSION}.tar.gz" \
    | tar xz -C /home/runner && \
    chown -R runner:runner /home/runner

# Install runner dependencies (script provided by GitHub)
RUN /home/runner/bin/installdependencies.sh

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Work directory for job execution
RUN mkdir -p /work && chown runner:runner /work

USER runner
WORKDIR /home/runner

ENTRYPOINT ["/entrypoint.sh"]
