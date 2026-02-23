# SABnzbd

Self-hosted Docker image and Helm chart for [SABnzbd](https://sabnzbd.org/), an open-source Usenet downloader.

The image is published to the GitHub Container Registry and automatically updated when new upstream SABnzbd releases are detected.

## Image

```
ghcr.io/mowntan/sabnzbd:latest
ghcr.io/mowntan/sabnzbd:<version>   # e.g. 4.5.5
```

### Quick start

```bash
docker run -d \
  --name sabnzbd \
  -p 8080:8080 \
  -v /path/to/config:/config \
  -v /path/to/downloads:/downloads \
  ghcr.io/mowntan/sabnzbd:latest
```

Then open `http://localhost:8080` in your browser.

### Volumes

| Path | Description |
|------|-------------|
| `/config` | SABnzbd configuration and database |
| `/downloads` | Completed and incomplete downloads |

### Ports

| Port | Description |
|------|-------------|
| `8080` | SABnzbd web UI |

### User and permissions

The container runs as a dedicated `sabnzbd` user with UID/GID `6543`. Ensure your host paths are owned or accessible by this UID:

```bash
chown -R 6543:6543 /path/to/config /path/to/downloads
```

### Docker Compose example

```yaml
services:
  sabnzbd:
    image: ghcr.io/mowntan/sabnzbd:latest
    container_name: sabnzbd
    restart: unless-stopped
    ports:
      - "8080:8080"
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
helm install sabnzbd ./chart
```

### Install with custom values

```bash
helm install sabnzbd ./chart -f my-values.yaml
```

---

## CI/CD

### Automated release tracking

A scheduled workflow runs daily at 06:00 UTC and checks the [SABnzbd releases page](https://github.com/sabnzbd/sabnzbd/releases) for new versions. When a new release is found, it automatically opens a pull request that bumps the `VERSION` file. Merging the PR triggers the build workflow.

### Docker build and push

The build workflow runs on:
- Push to `main` when `VERSION`, `docker/Dockerfile`, or `.github/workflows/build.yml` changes
- Manual trigger via **Actions → Build and push Docker image → Run workflow**

Or via CLI (requires [`gh`](https://cli.github.com/)):

```bash
gh workflow run build.yml
```

The workflow builds the image and pushes it to `ghcr.io/mowntan/sabnzbd` tagged with the version from `VERSION` and `latest`.

---

## Local development

Build the image locally:

```bash
docker build -t sabnzbd:local -f docker/Dockerfile docker/
```

Build a specific SABnzbd version:

```bash
docker build \
  --build-arg SABNZBD_VERSION=4.5.5 \
  -t sabnzbd:local \
  -f docker/Dockerfile docker/
```
