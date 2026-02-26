# K8s Homelab

Self-hosted Docker images and Helm charts for popular home server applications, maintained as a fork of the archived [k8s-at-home/charts](https://github.com/k8s-at-home/charts) project.

## Apps

This repository maintains the following applications:

| App | Description | Image | Chart | Version |
|-----|-------------|-------|-------|---------|
| [FlareSolverr](apps/flaresolverr) | Proxy to bypass Cloudflare protection | `ghcr.io/flaresolverr/flaresolverr` | ✅ | ![Version](https://img.shields.io/badge/version-v3.3.21-blue) |
| [GitHub Runner](apps/github-runner) | Self-hosted GitHub Actions runner | `ghcr.io/mowntan/github-runner` | ✅ | ![Version](https://img.shields.io/badge/dynamic/json?url=https://ghcr.io/v2/mowntan/github-runner/tags/list&query=$.tags[0]&label=version) |
| [Jackett](apps/jackett) | Torrent tracker proxy | `ghcr.io/mowntan/jackett` | ✅ | ![Version](https://img.shields.io/badge/dynamic/json?url=https://ghcr.io/v2/mowntan/jackett/tags/list&query=$.tags[0]&label=version) |
| [OpenVPN Client](apps/openvpn-client) | OpenVPN sidecar for VPN-routed containers | `ghcr.io/mowntan/openvpn-client` | — | ![Version](https://img.shields.io/badge/dynamic/json?url=https://ghcr.io/v2/mowntan/openvpn-client/tags/list&query=$.tags[0]&label=version) |
| [qBittorrent](apps/qbittorrent) | BitTorrent client | `ghcr.io/mowntan/qbittorrent` | ✅ | ![Version](https://img.shields.io/badge/dynamic/json?url=https://ghcr.io/v2/mowntan/qbittorrent/tags/list&query=$.tags[0]&label=version) |
| [Radarr](apps/radarr) | Movie collection manager | `ghcr.io/mowntan/radarr` | ✅ | ![Version](https://img.shields.io/badge/dynamic/json?url=https://ghcr.io/v2/mowntan/radarr/tags/list&query=$.tags[0]&label=version) |
| [SABnzbd](apps/sabnzbd) | Usenet download client | `ghcr.io/mowntan/sabnzbd` | ✅ | ![Version](https://img.shields.io/badge/dynamic/json?url=https://ghcr.io/v2/mowntan/sabnzbd/tags/list&query=$.tags[0]&label=version) |
| [Sonarr](apps/sonarr) | TV series collection manager | `ghcr.io/mowntan/sonarr` | ✅ | ![Version](https://img.shields.io/badge/dynamic/json?url=https://ghcr.io/v2/mowntan/sonarr/tags/list&query=$.tags[0]&label=version) |

## Repository Structure

```
k8s-homelab/
├── apps/
│   ├── flaresolverr/
│   │   ├── docker/Dockerfile       # Docker image definition
│   │   ├── chart/                  # Helm chart
│   │   ├── VERSION                 # Current version
│   │   └── README.md
│   ├── github-runner/
│   ├── jackett/
│   ├── openvpn-client/             # Sidecar image (no standalone chart)
│   ├── qbittorrent/                # Includes optional VPN sidecar support
│   ├── radarr/
│   ├── sabnzbd/
│   └── sonarr/
└── .github/workflows/              # CI/CD automation for all apps
```

Charts are published to GitHub Pages at `https://mowntan.github.io/k8s-homelab/charts` via the `release-charts.yml` workflow.

## Using the Docker Images

All images are published to the GitHub Container Registry and automatically updated when new upstream releases are detected.

**Supported Architectures:**
- `linux/amd64` (x86_64 - Intel/AMD processors)
- `linux/arm64` (ARM 64-bit - Raspberry Pi 4/5, Apple Silicon, AWS Graviton, etc.)

### Pull an image

```bash
docker pull ghcr.io/mowntan/<app>:latest
# or specific version
docker pull ghcr.io/mowntan/<app>:<version>
```

### Run with Docker

```bash
docker run -d \
  --name <app> \
  -p <port>:<port> \
  -v /path/to/config:/config \
  ghcr.io/mowntan/<app>:latest
```

See each app's README for specific configuration details.

## Using the Helm Charts

### Install from local chart

```bash
# Clone this repository
git clone https://github.com/mowntan/k8s-homelab.git
cd k8s-homelab

# Install a chart
helm install <app> ./apps/<app>/chart
```

### Install with custom values

```bash
helm install <app> ./apps/<app>/chart -f my-values.yaml
```

### Add the Helm repository

```bash
helm repo add mowntan https://mowntan.github.io/k8s-homelab/charts
helm repo update
helm install <app> mowntan/<app>
```

## Automated Updates

Each app includes automated CI/CD workflows:

1. **Daily Release Check** - Scheduled workflow runs at 06:00 UTC daily
   - Checks upstream repository for new releases
   - Opens a PR when a new version is detected
   - Updates the `VERSION` file and chart `appVersion`

2. **Docker Build & Push** - Triggered when:
   - `VERSION` file changes (e.g., after merging release PR)
   - `Dockerfile` is modified
   - Manually via GitHub Actions

3. **Version Tracking** - Each app has a `VERSION` file tracking the current release

## Development

### Building images locally

```bash
cd apps/<app>
docker build -t <app>:local -f docker/Dockerfile docker/
```

### Testing Helm charts

```bash
cd apps/<app>
helm install <app>-test ./chart --dry-run --debug
```

### Manual workflow triggers

Trigger builds manually using GitHub CLI:

```bash
# Trigger build for a specific app
gh workflow run <app>-build.yml

# Examples:
gh workflow run sabnzbd-build.yml
gh workflow run radarr-build.yml

# Trigger version check
gh workflow run <app>-check-release.yml
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test locally
5. Submit a pull request

## License

Each application maintains its own license. This repository structure and automation are provided as-is for homelab use.

## Acknowledgments

This project builds upon the excellent work of the [k8s-at-home](https://github.com/k8s-at-home) community. While that project has been archived, this fork continues to maintain a subset of applications for personal homelab use.
