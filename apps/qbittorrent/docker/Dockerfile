FROM debian:bookworm-slim

ARG QBITTORRENT_VERSION=5.0.2

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    ca-certificates \
    python3 \
    qbittorrent-nox=${QBITTORRENT_VERSION}* \
    && rm -rf /var/lib/apt/lists/* \
    || (apt-get update && apt-get install -y --no-install-recommends \
        curl \
        ca-certificates \
        python3 \
        build-essential \
        libboost-dev \
        libssl-dev \
        libtorrent-rasterbar-dev \
        qtbase5-dev \
        qttools5-dev \
        zlib1g-dev \
        && curl -fsSL "https://github.com/qbittorrent/qBittorrent/archive/refs/tags/release-${QBITTORRENT_VERSION}.tar.gz" \
        | tar xz -C /tmp \
        && cd /tmp/qBittorrent-release-${QBITTORRENT_VERSION} \
        && ./configure --disable-gui --prefix=/usr \
        && make -j$(nproc) \
        && make install \
        && cd / \
        && rm -rf /tmp/qBittorrent-release-${QBITTORRENT_VERSION} \
        && apt-get purge -y build-essential libboost-dev qtbase5-dev qttools5-dev \
        && apt-get autoremove -y \
        && rm -rf /var/lib/apt/lists/*)

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
