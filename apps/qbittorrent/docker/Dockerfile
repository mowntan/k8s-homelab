FROM debian:bookworm-slim

ARG QBITTORRENT_VERSION=5.0.2
ARG LIBTORRENT_VERSION=2.0.10

# Install runtime and build dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    ca-certificates \
    python3 \
    build-essential \
    libboost-dev \
    libboost-system-dev \
    libssl-dev \
    qtbase5-dev \
    qttools5-dev \
    zlib1g-dev \
    cmake \
    ninja-build \
    git \
    && rm -rf /var/lib/apt/lists/*

# Build libtorrent-rasterbar from source (Debian's version is too old)
RUN curl -fsSL "https://github.com/arvidn/libtorrent/releases/download/v${LIBTORRENT_VERSION}/libtorrent-rasterbar-${LIBTORRENT_VERSION}.tar.gz" \
    | tar xz -C /tmp \
    && cd /tmp/libtorrent-rasterbar-${LIBTORRENT_VERSION} \
    && cmake -G "Ninja" -B build \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX=/usr \
        -DCMAKE_INSTALL_LIBDIR=lib \
    && cmake --build build \
    && cmake --install build \
    && cd / \
    && rm -rf /tmp/libtorrent-rasterbar-${LIBTORRENT_VERSION} \
    && ldconfig

# Build qBittorrent from source
RUN curl -fsSL "https://github.com/qbittorrent/qBittorrent/archive/refs/tags/release-${QBITTORRENT_VERSION}.tar.gz" \
    | tar xz -C /tmp \
    && cd /tmp/qBittorrent-release-${QBITTORRENT_VERSION} \
    && cmake -G "Ninja" -B build \
        -DCMAKE_BUILD_TYPE=Release \
        -DGUI=OFF \
        -DCMAKE_INSTALL_PREFIX=/usr \
    && cmake --build build \
    && cmake --install build \
    && cd / \
    && rm -rf /tmp/qBittorrent-release-${QBITTORRENT_VERSION} \
    && apt-get purge -y build-essential cmake ninja-build git \
    && apt-get autoremove -y \
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
