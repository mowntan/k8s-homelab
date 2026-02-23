# Sonarr

Self-hosted Docker image and Helm chart for [Sonarr](https://sonarr.tv/), a TV series collection manager for Usenet and BitTorrent users.

The image is published to the GitHub Container Registry and automatically updated when new upstream Sonarr releases are detected.

## Image

```
ghcr.io/mowntan/sonarr:latest
ghcr.io/mowntan/sonarr:<version>   # e.g. 4.0.11.2680
```

### Quick start

```bash
docker run -d \
  --name sonarr \
  -p 8989:8989 \
  -v /path/to/config:/config \
  -v /path/to/tv:/tv \
  -v /path/to/downloads:/downloads \
  ghcr.io/mowntan/sonarr:latest
```

Then open `http://localhost:8989` in your browser.

### Volumes

| Path | Description |
|------|-------------|
| `/config` | Sonarr configuration and database |
| `/tv` | TV series library location |
| `/downloads` | Download client output directory |

### Ports

| Port | Description |
|------|-------------|
| `8989` | Sonarr web UI and API |

### User and permissions

The container runs as a dedicated `sonarr` user with UID/GID `6547`. Ensure your host paths are owned or accessible by this UID:

```bash
chown -R 6547:6547 /path/to/config /path/to/tv /path/to/downloads
```

### Docker Compose example

```yaml
services:
  sonarr:
    image: ghcr.io/mowntan/sonarr:latest
    container_name: sonarr
    restart: unless-stopped
    ports:
      - "8989:8989"
    volumes:
      - ./config:/config
      - /path/to/tv:/tv
      - /path/to/downloads:/downloads
    environment:
      - TZ=UTC
```

---

## Helm chart

A Helm chart is included under `chart/` for deploying to Kubernetes. See [`chart/README.md`](chart/README.md) for the full configuration reference.

### Install

```bash
helm install sonarr ./chart
```

### Install with custom values

```bash
helm install sonarr ./chart -f my-values.yaml
```

---

## CI/CD

### Automated release tracking

A scheduled workflow runs daily at 06:00 UTC and checks the [Sonarr releases page](https://github.com/Sonarr/Sonarr/releases) for new versions. When a new release is found, it automatically opens a pull request that bumps the `VERSION` file. Merging the PR triggers the build workflow.

### Docker build and push

The build workflow runs on:
- Push to `main` when `VERSION`, `docker/Dockerfile`, or `.github/workflows/sonarr-build.yml` changes
- Manual trigger via **Actions → Build and push Docker image → Run workflow**

Or via CLI (requires [`gh`](https://cli.github.com/)):

```bash
gh workflow run sonarr-build.yml
```

The workflow builds the image and pushes it to `ghcr.io/mowntan/sonarr` tagged with the version from `VERSION` and `latest`.

---

## Local development

Build the image locally:

```bash
docker build -t sonarr:local -f docker/Dockerfile docker/
```

Build a specific Sonarr version:

```bash
docker build \
  --build-arg SONARR_VERSION=4.0.11.2680 \
  -t sonarr:local \
  -f docker/Dockerfile docker/
```
