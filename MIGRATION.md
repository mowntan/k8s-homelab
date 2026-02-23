# Migration from k8s-at-home Charts

This guide helps users migrating from the archived [k8s-at-home/charts](https://github.com/k8s-at-home/charts) repository.

## Key Differences

### Repository Structure

**k8s-at-home (old):**
```
charts/
└── stable/
    ├── app1/
    ├── app2/
    └── ...
```

**This repository (new):**
```
apps/
├── app1/
│   ├── docker/          # NEW: Custom Docker images
│   └── chart/           # Helm chart
└── app2/
```

### What's Changed

| Aspect | k8s-at-home | This Repo |
|--------|-------------|-----------|
| **Docker Images** | Used community images | Custom-built, maintained images |
| **Image Registry** | Various (LSCR, official, etc.) | GitHub Container Registry (ghcr.io/mowntan) |
| **Updates** | Manual chart updates | Automated daily upstream checks |
| **CI/CD** | Centralized workflows | Per-app workflows |
| **Chart Repository** | GitHub Pages | GitHub Pages (same) |
| **Apps Maintained** | 100+ apps | 5 curated apps (jackett, qbittorrent, radarr, sabnzbd, sonarr) |

## Migration Guide

### If you're using k8s-at-home Helm charts

1. **Remove old repository:**
```bash
helm repo remove k8s-at-home
```

2. **Add new repository:**
```bash
helm repo add mowntan https://mowntan.github.io/k8s-homelab/charts
helm repo update
```

3. **Export your current values:**
```bash
helm get values <release-name> > my-values.yaml
```

4. **Review value changes** (see below for breaking changes)

5. **Upgrade or reinstall:**
```bash
# Option 1: Upgrade in place (preserves PVCs if skipUninstall: true)
helm upgrade <release-name> mowntan/<app> -f my-values.yaml

# Option 2: Fresh install (recommended)
helm uninstall <release-name>
helm install <release-name> mowntan/<app> -f my-values.yaml
```

### Breaking Changes

#### Image Repository

**Old:**
```yaml
image:
  repository: ghcr.io/k8s-at-home/sabnzbd
  tag: v3.5.0
```

**New:**
```yaml
image:
  repository: ghcr.io/mowntan/sabnzbd
  tag: ""  # Uses chart appVersion by default
```

#### User IDs

The new images use different UIDs for security:

| App | k8s-at-home UID | New UID |
|-----|-----------------|---------|
| SABnzbd | 568 | 6543 |
| Jackett | 568 | 6544 |
| qBittorrent | 568 | 6545 |
| Radarr | 568 | 6546 |
| Sonarr | 568 | 6547 |

**Action required:** Update file permissions on persistent volumes:

```bash
# SABnzbd
chown -R 6543:6543 /path/to/sabnzbd/config

# Jackett
chown -R 6544:6544 /path/to/jackett/config

# qBittorrent
chown -R 6545:6545 /path/to/qbittorrent/config

# Radarr
chown -R 6546:6546 /path/to/radarr/config

# Sonarr
chown -R 6547:6547 /path/to/sonarr/config
```

Or in Kubernetes using an init container:

```yaml
initContainers:
  - name: fix-permissions
    image: busybox
    command: ['sh', '-c', 'chown -R 6543:6543 /config']
    volumeMounts:
      - name: config
        mountPath: /config
    securityContext:
      runAsUser: 0
```

#### Values Schema

Most values remain compatible, but some changes:

**Persistence:**

Old:
```yaml
persistence:
  config:
    enabled: true
    type: pvc
    accessMode: ReadWriteOnce
```

New:
```yaml
persistence:
  config:
    enabled: true
    mountPath: /config
    storageClass: ""
    existingClaim: ""
    size: 1Gi
    skipUninstall: true  # Keeps PVC on helm uninstall
```

**Environment Variables:**

Old (via common library):
```yaml
env:
  TZ: UTC
  PUID: 1000
  PGID: 1000
```

New (standard Kubernetes format):
```yaml
env:
  - name: TZ
    value: "UTC"
# PUID/PGID not needed - containers run as fixed UIDs
```

### Feature Comparison

| Feature | k8s-at-home | This Repo |
|---------|-------------|-----------|
| **Common library chart** | ✅ | ❌ (simplified, app-specific) |
| **Code server sidecar** | ✅ | ❌ |
| **VPN sidecar** | ✅ | ❌ (use network policies) |
| **Automatic updates** | ❌ | ✅ |
| **Custom images** | ❌ | ✅ |
| **Per-app CI/CD** | ❌ | ✅ |
| **Ingress** | ✅ | ✅ |
| **Service monitors** | ✅ | ❌ (add if needed) |
| **Pod security contexts** | ✅ | ✅ |

### Apps Not Included

If you need an app not in this repository:

1. **Check if it's essential** - This repo focuses on core media management
2. **Use original k8s-at-home charts** - They still work, just unmaintained
3. **Use official charts** - Many apps have official Helm charts now
4. **Create your own** - Follow the pattern in this repo

Popular apps from k8s-at-home and alternatives:

| App | Alternative |
|-----|-------------|
| Plex | [Official chart](https://github.com/plexinc/pms-docker) or Docker |
| Jellyfin | [Official chart](https://github.com/jellyfin/jellyfin-helm) |
| Home Assistant | [Official chart](https://github.com/pajikos/home-assistant-helm-chart) |
| Nextcloud | [Official chart](https://github.com/nextcloud/helm) |
| Calibre | Use k8s-at-home chart (unmaintained but works) |

## Docker Migration

If you were using k8s-at-home recommended images directly:

**Old:**
```bash
docker run -d \
  -e PUID=1000 \
  -e PGID=1000 \
  ghcr.io/k8s-at-home/sabnzbd:latest
```

**New:**
```bash
docker run -d \
  ghcr.io/mowntan/sabnzbd:latest
# No PUID/PGID - runs as 6543:6543
# Fix permissions: chown -R 6543:6543 /path/to/config
```

## Support

### Getting Help

- Check app README: `apps/<app>/README.md`
- Review [SETUP.md](SETUP.md) for configuration
- Check [QUICKSTART.md](QUICKSTART.md) for common tasks
- Open an issue on GitHub

### Reporting Issues

When reporting issues, include:
- Which app (jackett, qbittorrent, radarr, sabnzbd, sonarr)
- Deployment method (Docker, Helm, docker-compose)
- Error messages or logs
- Your values.yaml (sanitize sensitive data)

## Why This Fork?

k8s-at-home was an amazing project, but:

1. **Archived** - No longer maintained
2. **Complexity** - Common library was powerful but complex
3. **Image sources** - Used various third-party images
4. **Scale** - 100+ charts hard to maintain

This fork:

1. **Maintained** - Active maintenance for core apps
2. **Simplified** - App-specific charts, easier to understand
3. **Controlled** - Custom images built from source
4. **Focused** - Only essential media management apps
5. **Automated** - Daily checks for upstream updates

## Acknowledgments

Huge thanks to the k8s-at-home community for pioneering home Kubernetes deployments. This project builds on their excellent foundation while taking a more focused, maintainable approach.
