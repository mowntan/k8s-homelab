FROM debian:bookworm-slim

ARG RADARR_VERSION=5.16.3.9541
ARG TARGETARCH

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    ca-certificates \
    libicu72 \
    libsqlite3-0 \
    mediainfo \
    && rm -rf /var/lib/apt/lists/*

# Create user and group
RUN groupadd -g 6546 radarr && \
    useradd -u 6546 -g radarr -m -d /app -s /bin/sh radarr

# Download and extract Radarr
RUN ARCH_SUFFIX=""; \
    case "${TARGETARCH}" in \
        amd64) ARCH_SUFFIX="x64" ;; \
        arm64) ARCH_SUFFIX="arm64" ;; \
    esac && \
    curl -fsSL "https://github.com/Radarr/Radarr/releases/download/v${RADARR_VERSION}/Radarr.master.${RADARR_VERSION}.linux-core-${ARCH_SUFFIX}.tar.gz" \
    | tar xz -C /opt && \
    chown -R radarr:radarr /opt/Radarr

# Create data directories
RUN mkdir -p /config /movies && \
    chown -R radarr:radarr /config /movies

USER radarr
WORKDIR /opt/Radarr

VOLUME ["/config", "/movies"]

EXPOSE 7878

CMD ["./Radarr", "-nobrowser", "-data=/config"]
