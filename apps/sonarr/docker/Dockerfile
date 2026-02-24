FROM debian:bookworm-slim

ARG SONARR_VERSION=4.0.11.2680
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
RUN groupadd -g 6547 sonarr && \
    useradd -u 6547 -g sonarr -m -d /app -s /bin/sh sonarr

# Download and extract Sonarr (arch-specific binary)
RUN ARCH_SUFFIX=""; \
    case "${TARGETARCH}" in \
        amd64) ARCH_SUFFIX="x64" ;; \
        arm64) ARCH_SUFFIX="arm64" ;; \
        *) echo "Unsupported architecture: ${TARGETARCH}" && exit 1 ;; \
    esac && \
    curl -fsSL "https://github.com/Sonarr/Sonarr/releases/download/v${SONARR_VERSION}/Sonarr.main.${SONARR_VERSION}.linux-${ARCH_SUFFIX}.tar.gz" \
    | tar xz -C /opt && \
    chown -R sonarr:sonarr /opt/Sonarr

# Create data directories
RUN mkdir -p /config /tv && \
    chown -R sonarr:sonarr /config /tv

USER sonarr
WORKDIR /opt/Sonarr

VOLUME ["/config", "/tv"]

EXPOSE 8989

CMD ["./Sonarr", "-nobrowser", "-data=/config"]
