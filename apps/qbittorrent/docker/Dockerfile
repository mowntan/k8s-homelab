FROM ubuntu:24.04

# Install qBittorrent from Ubuntu repositories
RUN apt-get update && apt-get install -y --no-install-recommends \
    qbittorrent-nox \
    python3 \
    && rm -rf /var/lib/apt/lists/*

# Create user and group
RUN groupadd -g 6545 qbittorrent && \
    useradd -u 6545 -g qbittorrent -m -d /app -s /bin/sh qbittorrent

# Create data directories
RUN mkdir -p /config /downloads && \
    chown -R qbittorrent:qbittorrent /config /downloads

USER qbittorrent
WORKDIR /app

VOLUME ["/config", "/downloads"]

EXPOSE 8080 6881 6881/udp

CMD ["qbittorrent-nox", "--webui-port=8080", "--profile=/config"]
