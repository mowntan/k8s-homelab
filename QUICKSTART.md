# Quick Start Guide

Get up and running with your homelab apps in minutes.

## Initial Setup (One-time)

```bash
# 1. Run the initialization script
./scripts/init-repo.sh

# 2. Configure GitHub Actions (follow the prompts from script)
# 3. Enable GitHub Pages (follow the prompts from script)
```

## Using Docker Images

### Pull and run SABnzbd
```bash
docker run -d \
  --name sabnzbd \
  -p 8080:8080 \
  -v ./config:/config \
  -v ./downloads:/downloads \
  ghcr.io/mowntan/sabnzbd:latest
```

### Pull and run all apps with Docker Compose
```yaml
# docker-compose.yml
services:
  sabnzbd:
    image: ghcr.io/mowntan/sabnzbd:latest
    ports: ["8080:8080"]
    volumes: ["./sabnzbd-config:/config", "./downloads:/downloads"]
    environment: ["TZ=UTC"]

  radarr:
    image: ghcr.io/mowntan/radarr:latest
    ports: ["7878:7878"]
    volumes: ["./radarr-config:/config", "./movies:/movies", "./downloads:/downloads"]
    environment: ["TZ=UTC"]

  sonarr:
    image: ghcr.io/mowntan/sonarr:latest
    ports: ["8989:8989"]
    volumes: ["./sonarr-config:/config", "./tv:/tv", "./downloads:/downloads"]
    environment: ["TZ=UTC"]

  jackett:
    image: ghcr.io/mowntan/jackett:latest
    ports: ["9117:9117"]
    volumes: ["./jackett-config:/config"]
    environment: ["TZ=UTC"]

  qbittorrent:
    image: ghcr.io/mowntan/qbittorrent:latest
    ports: ["8081:8080", "6881:6881", "6881:6881/udp"]
    volumes: ["./qbittorrent-config:/config", "./downloads:/downloads"]
    environment: ["TZ=UTC"]
```

```bash
docker-compose up -d
```

## Using Helm Charts

### Add the Helm repository
```bash
helm repo add mowntan https://mowntan.github.io/k8s-homelab/charts
helm repo update
```

### Install an app
```bash
# Install SABnzbd
helm install sabnzbd mowntan/sabnzbd

# Install with custom values
helm install radarr mowntan/radarr -f my-values.yaml

# Install from local chart
helm install sonarr ./apps/images/sonarr/chart
```

### Example custom values
```yaml
# my-radarr-values.yaml
ingress:
  enabled: true
  className: nginx
  hosts:
    - host: radarr.homelab.local
      paths:
        - path: /
          pathType: Prefix

persistence:
  movies:
    enabled: true
    nfs:
      server: 192.168.1.100
      path: /mnt/media/movies
  downloads:
    enabled: true
    nfs:
      server: 192.168.1.100
      path: /mnt/media/downloads

resources:
  limits:
    memory: 512Mi
  requests:
    memory: 256Mi
```

## App Access URLs

After deployment:

| App | Docker Port | Description |
|-----|-------------|-------------|
| SABnzbd | http://localhost:8080 | Usenet downloader |
| Radarr | http://localhost:7878 | Movie manager |
| Sonarr | http://localhost:8989 | TV show manager |
| Jackett | http://localhost:9117 | Indexer proxy |
| qBittorrent | http://localhost:8081 | Torrent client |

## Common Tasks

### Check for updates
```bash
# Manually trigger version check for an app
cd apps/sabnzbd
gh workflow run check-release.yml
```

### Build image manually
```bash
cd apps/radarr
gh workflow run build.yml
```

### Update all charts
```bash
# Trigger chart republishing
gh workflow run release-charts.yml
```

### Local development
```bash
# Build Docker image locally
cd apps/sonarr
docker build -t sonarr:test -f docker/Dockerfile docker/

# Test Helm chart
cd apps/jackett
helm install jackett-test ./chart --dry-run --debug

# Lint chart
helm lint ./chart
```

## Troubleshooting

### Docker container won't start
```bash
# Check logs
docker logs <container-name>

# Verify permissions (containers run as specific UIDs)
chown -R 6543:6543 ./sabnzbd-config  # SABnzbd
chown -R 6544:6544 ./jackett-config  # Jackett
chown -R 6545:6545 ./qbittorrent-config  # qBittorrent
chown -R 6546:6546 ./radarr-config  # Radarr
chown -R 6547:6547 ./sonarr-config  # Sonarr
```

### Helm chart fails to install
```bash
# Check chart syntax
helm lint ./apps/<app>/chart

# Debug installation
helm install <app> ./apps/<app>/chart --dry-run --debug

# Check Kubernetes events
kubectl describe pod <pod-name>
kubectl logs <pod-name>
```

### Automated updates not working
- Check GitHub Actions permissions in repository settings
- Verify workflows are enabled
- Check workflow run logs in Actions tab

## Next Steps

- Read [SETUP.md](SETUP.md) for detailed configuration
- Check each app's README in `apps/<app>/README.md`
- Configure ingress for external access
- Set up persistent storage (NFS/local volumes)
- Configure monitoring and backups

## App-Specific Notes

**qBittorrent:** Default login is `admin` / `adminadmin` - change immediately!

**Radarr/Sonarr:** Configure indexers via Jackett or directly

**SABnzbd:** Requires Usenet provider configuration

**Jackett:** Add indexers and configure API keys for Radarr/Sonarr

For detailed app configuration, see the README in each app's directory.
