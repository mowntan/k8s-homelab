# Jackett

Self-hosted Docker image and Helm chart for [Jackett](https://github.com/Jackett/Jackett), a torrent tracker proxy supporting various indexers.

The image is published to the GitHub Container Registry and automatically updated when new upstream Jackett releases are detected.

## Image

```
ghcr.io/mowntan/jackett:latest
ghcr.io/mowntan/jackett:<version>   # e.g. 0.22.1051
```

### Quick start

```bash
docker run -d \
  --name jackett \
  -p 9117:9117 \
  -v /path/to/config:/config \
  ghcr.io/mowntan/jackett:latest
```

Then open `http://localhost:9117` in your browser.

### Volumes

| Path | Description |
|------|-------------|
| `/config` | Jackett configuration and database |
| `/downloads` | Optional downloads directory |

### Ports

| Port | Description |
|------|-------------|
| `9117` | Jackett web UI and API |

### User and permissions

The container runs as a dedicated `jackett` user with UID/GID `6544`. Ensure your host paths are owned or accessible by this UID:

```bash
chown -R 6544:6544 /path/to/config
```

### Docker Compose example

```yaml
services:
  jackett:
    image: ghcr.io/mowntan/jackett:latest
    container_name: jackett
    restart: unless-stopped
    ports:
      - "9117:9117"
    volumes:
      - ./config:/config
    environment:
      - TZ=UTC
```

---

## Helm chart

A Helm chart is included under `chart/` for deploying to Kubernetes. See [`chart/README.md`](chart/README.md) for the full configuration reference.

### Install

```bash
helm install jackett ./chart
```

### Install with custom values

```bash
helm install jackett ./chart -f my-values.yaml
```

---

## CI/CD

### Automated release tracking

A scheduled workflow runs daily at 06:00 UTC and checks the [Jackett releases page](https://github.com/Jackett/Jackett/releases) for new versions. When a new release is found, it automatically opens a pull request that bumps the `VERSION` file. Merging the PR triggers the build workflow.

### Docker build and push

The build workflow runs on:
- Push to `main` when `VERSION`, `docker/Dockerfile`, or `.github/workflows/build.yml` changes
- Manual trigger via **Actions → Build and push Docker image → Run workflow**

Or via CLI (requires [`gh`](https://cli.github.com/)):

```bash
gh workflow run build.yml
```

The workflow builds the image and pushes it to `ghcr.io/mowntan/jackett` tagged with the version from `VERSION` and `latest`.

---

## Local development

Build the image locally:

```bash
docker build -t jackett:local -f docker/Dockerfile docker/
```

Build a specific Jackett version:

```bash
docker build \
  --build-arg JACKETT_VERSION=0.22.1051 \
  -t jackett:local \
  -f docker/Dockerfile docker/
```
