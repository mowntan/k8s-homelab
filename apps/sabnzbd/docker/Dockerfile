FROM debian:bookworm-slim

ARG SABNZBD_VERSION=4.5.5

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 \
    python3-pip \
    python3-dev \
    python3-cryptography \
    par2 \
    p7zip-full \
    curl \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install unrar from non-free repository
RUN echo "deb http://deb.debian.org/debian bookworm non-free non-free-firmware" > /etc/apt/sources.list.d/non-free.list && \
    apt-get update && \
    apt-get install -y --no-install-recommends unrar && \
    rm -rf /var/lib/apt/lists/* && \
    rm /etc/apt/sources.list.d/non-free.list

# Create user and group matching the expected UID/GID
RUN groupadd -g 6543 sabnzbd && \
    useradd -u 6543 -g sabnzbd -m -d /app -s /bin/sh sabnzbd

# Download and extract SABnzbd source release
RUN curl -fsSL "https://github.com/sabnzbd/sabnzbd/releases/download/${SABNZBD_VERSION}/SABnzbd-${SABNZBD_VERSION}-src.tar.gz" \
    | tar xz -C /opt && \
    mv /opt/SABnzbd-${SABNZBD_VERSION} /opt/sabnzbd

# Install Python dependencies from SABnzbd's requirements
RUN pip3 install --break-system-packages --no-cache-dir -r /opt/sabnzbd/requirements.txt

# Create data directories and set ownership
RUN mkdir -p /config /downloads && \
    chown -R sabnzbd:sabnzbd /config /downloads /opt/sabnzbd

USER sabnzbd
WORKDIR /opt/sabnzbd

VOLUME ["/config", "/downloads"]

EXPOSE 8080

CMD ["python3", "SABnzbd.py", "--server", "0.0.0.0:8080", "--config-file", "/config/sabnzbd.ini", "--browser", "0"]
