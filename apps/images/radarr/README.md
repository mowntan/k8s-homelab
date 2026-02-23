# Radarr

Self-hosted Docker image and Helm chart for [Radarr](https://radarr.video/), a movie collection manager for Usenet and BitTorrent users.

The image is published to the GitHub Container Registry and automatically updated when new upstream Radarr releases are detected.

## Image

```
ghcr.io/mowntan/radarr:latest
ghcr.io/mowntan/radarr:<version>   # e.g. 5.16.3.9541
```

### Quick start

```bash
docker run -d \
  --name radarr \
  -p 7878:7878 \
  -v /path/to/config:/config \
  -v /path/to/movies:/movies \
  -v /path/to/downloads:/downloads \
  ghcr.io/mowntan/radarr:latest
```

Then open `http://localhost:7878` in your browser.

### Volumes

| Path | Description |
|------|-------------|
| `/config` | Radarr configuration and database |
| `/movies` | Movie library location |
| `/downloads` | Download client output directory |

### Ports

| Port | Description |
|------|-------------|
| `7878` | Radarr web UI and API |

### User and permissions

The container runs as a dedicated `radarr` user with UID/GID `6546`. Ensure your host paths are owned or accessible by this UID:

```bash
chown -R 6546:6546 /path/to/config /path/to/movies /path/to/downloads
```

### Docker Compose example

```yaml
services:
  radarr:
    image: ghcr.io/mowntan/radarr:latest
    container_name: radarr
    restart: unless-stopped
    ports:
      - "7878:7878"
    volumes:
      - ./config:/config
      - /path/to/movies:/movies
      - /path/to/downloads:/downloads
    environment:
      - TZ=UTC
```

---

## Helm chart

A Helm chart is included under `chart/` for deploying to Kubernetes. See [`chart/README.md`](chart/README.md) for the full configuration reference.

### Install

```bash
helm install radarr ./chart
```

### Install with custom values

```bash
helm install radarr ./chart -f my-values.yaml
```

---

## CI/CD

### Automated release tracking

A scheduled workflow runs daily at 06:00 UTC and checks the [Radarr releases page](https://github.com/Radarr/Radarr/releases) for new versions. When a new release is found, it automatically opens a pull request that bumps the `VERSION` file. Merging the PR triggers the build workflow.

### Docker build and push

The build workflow runs on:
- Push to `main` when `VERSION`, `docker/Dockerfile`, or `.github/workflows/build.yml` changes
- Manual trigger via **Actions → Build and push Docker image → Run workflow**

Or via CLI (requires [`gh`](https://cli.github.com/)):

```bash
gh workflow run build.yml
```

The workflow builds the image and pushes it to `ghcr.io/mowntan/radarr` tagged with the version from `VERSION` and `latest`.

---

## Local development

Build the image locally:

```bash
docker build -t radarr:local -f docker/Dockerfile docker/
```

Build a specific Radarr version:

```bash
docker build \
  --build-arg RADARR_VERSION=5.16.3.9541 \
  -t radarr:local \
  -f docker/Dockerfile docker/
```
