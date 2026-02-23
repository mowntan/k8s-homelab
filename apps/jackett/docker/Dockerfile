FROM debian:bookworm-slim

ARG JACKETT_VERSION=0.22.1051

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    ca-certificates \
    libicu72 \
    && rm -rf /var/lib/apt/lists/*

# Create user and group
RUN groupadd -g 6544 jackett && \
    useradd -u 6544 -g jackett -m -d /app -s /bin/sh jackett

# Download and extract Jackett
RUN curl -fsSL "https://github.com/Jackett/Jackett/releases/download/v${JACKETT_VERSION}/Jackett.Binaries.LinuxAMDx64.tar.gz" \
    | tar xz -C /opt && \
    chown -R jackett:jackett /opt/Jackett

# Create data directories
RUN mkdir -p /config /downloads && \
    chown -R jackett:jackett /config /downloads

USER jackett
WORKDIR /opt/Jackett

VOLUME ["/config", "/downloads"]

EXPOSE 9117

CMD ["./jackett", "--NoUpdates", "--DataFolder=/config"]
