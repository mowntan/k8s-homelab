FROM debian:bookworm-slim

ARG RADARR_VERSION=5.16.3.9541

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
RUN curl -fsSL "https://github.com/Radarr/Radarr/releases/download/v${RADARR_VERSION}/Radarr.master.${RADARR_VERSION}.linux-core-x64.tar.gz" \
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
