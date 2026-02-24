FROM debian:bookworm-slim

ARG JACKETT_VERSION=0.22.1051
ARG TARGETARCH

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    ca-certificates \
    libicu72 \
    && rm -rf /var/lib/apt/lists/*

# Create user and group
RUN groupadd -g 6544 jackett && \
    useradd -u 6544 -g jackett -m -d /app -s /bin/sh jackett

# Download and extract Jackett (arch-specific binary)
RUN ARCH_SUFFIX=""; \
    case "${TARGETARCH}" in \
        amd64) ARCH_SUFFIX="LinuxAMDx64" ;; \
        arm64) ARCH_SUFFIX="LinuxARM64" ;; \
        *) echo "Unsupported architecture: ${TARGETARCH}" && exit 1 ;; \
    esac && \
    curl -fsSL "https://github.com/Jackett/Jackett/releases/download/v${JACKETT_VERSION}/Jackett.Binaries.${ARCH_SUFFIX}.tar.gz" \
    | tar xz -C /opt && \
    chown -R jackett:jackett /opt/Jackett

# Create data directories
RUN mkdir -p /config /downloads && \
    chown -R jackett:jackett /config /downloads

USER jackett
WORKDIR /opt/Jackett

VOLUME ["/config", "/downloads"]

EXPOSE 9117

CMD ["./jackett", "--NoUpdates", "--DataFolder=/config", "--ListenPublic"]
