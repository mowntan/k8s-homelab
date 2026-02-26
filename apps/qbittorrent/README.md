# qBittorrent

Self-hosted Docker image and Helm chart for [qBittorrent](https://www.qbittorrent.org/), a free and open-source BitTorrent client.

The image is published to the GitHub Container Registry and automatically updated when new upstream qBittorrent releases are detected.

## Image

```
ghcr.io/mowntan/qbittorrent:latest
ghcr.io/mowntan/qbittorrent:<version>   # e.g. 4.6.3
```

### Quick start

```bash
docker run -d \
  --name qbittorrent \
  -p 8080:8080 \
  -p 6881:6881 \
  -p 6881:6881/udp \
  -v /path/to/config:/config \
  -v /path/to/downloads:/downloads \
  ghcr.io/mowntan/qbittorrent:latest
```

Then open `http://localhost:8080` in your browser.

**Default credentials:** username `admin`, password `adminadmin` (change immediately!)

### Volumes

| Path | Description |
|------|-------------|
| `/config` | qBittorrent configuration |
| `/downloads` | Downloaded torrents |

### Ports

| Port | Description |
|------|-------------|
| `8080` | qBittorrent web UI |
| `6881` | BitTorrent TCP/UDP port for incoming connections |

### User and permissions

The container runs as a dedicated `qbittorrent` user with UID/GID `6545`. Ensure your host paths are owned or accessible by this UID:

```bash
chown -R 6545:6545 /path/to/config /path/to/downloads
```

### Docker Compose example

```yaml
services:
  qbittorrent:
    image: ghcr.io/mowntan/qbittorrent:latest
    container_name: qbittorrent
    restart: unless-stopped
    ports:
      - "8080:8080"
      - "6881:6881"
      - "6881:6881/udp"
    volumes:
      - ./config:/config
      - ./downloads:/downloads
    environment:
      - TZ=UTC
```

---

## Helm chart

A Helm chart is included under `chart/` for deploying to Kubernetes. See [`chart/README.md`](chart/README.md) for the full configuration reference.

### Install

```bash
helm install qbittorrent ./chart
```

### Install with custom values

```bash
helm install qbittorrent ./chart -f my-values.yaml
```

---

## CI/CD

### Automated release tracking

A scheduled workflow runs daily at 06:00 UTC and checks the [qBittorrent releases page](https://github.com/qbittorrent/qBittorrent/releases) for new versions. When a new release is found, it automatically opens a pull request that bumps the `VERSION` file. Merging the PR triggers the build workflow.

### Docker build and push

The build workflow runs on:
- Push to `main` when `VERSION`, `docker/Dockerfile`, or `.github/workflows/qbittorrent-build.yml` changes
- Manual trigger via **Actions → Build and push Docker image → Run workflow**

Or via CLI (requires [`gh`](https://cli.github.com/)):

```bash
gh workflow run qbittorrent-build.yml
```

The workflow builds the image and pushes it to `ghcr.io/mowntan/qbittorrent` tagged with the version from `VERSION` and `latest`.

---

## Local development

Build the image locally:

```bash
docker build -t qbittorrent:local -f docker/Dockerfile docker/
```

Build a specific qBittorrent version:

```bash
docker build \
  --build-arg QBITTORRENT_VERSION=4.6.3 \
  -t qbittorrent:local \
  -f docker/Dockerfile docker/
```
