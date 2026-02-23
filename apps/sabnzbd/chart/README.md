# SABnzbd Helm Chart

Helm chart for deploying SABnzbd to Kubernetes.

## Install

```bash
helm install sabnzbd ./chart
```

## Uninstall

```bash
helm uninstall sabnzbd
```

> **Note:** The config PVC is retained on uninstall by default (`persistence.config.skipUninstall: true`). Delete it manually if no longer needed.

## Values

### Image

| Key | Default | Description |
|-----|---------|-------------|
| `image.repository` | `ghcr.io/mowntan/sabnzbd` | Image repository |
| `image.tag` | `""` | Image tag. Defaults to chart `appVersion` |
| `image.pullPolicy` | `IfNotPresent` | Image pull policy |

### Pod

| Key | Default | Description |
|-----|---------|-------------|
| `replicaCount` | `1` | Number of replicas |
| `nameOverride` | `""` | Override the chart name |
| `fullnameOverride` | `""` | Override the full release name |

### Security context

| Key | Default | Description |
|-----|---------|-------------|
| `podSecurityContext.runAsUser` | `6543` | UID to run the container as |
| `podSecurityContext.runAsGroup` | `6543` | GID to run the container as |
| `podSecurityContext.fsGroup` | `6543` | GID for volume ownership |
| `securityContext` | `{}` | Container-level security context |

### Environment variables

| Key | Default | Description |
|-----|---------|-------------|
| `env` | `[{name: TZ, value: UTC}]` | List of environment variables passed to the container |

Example:
```yaml
env:
  - name: TZ
    value: "America/New_York"
```

### Service

| Key | Default | Description |
|-----|---------|-------------|
| `service.type` | `ClusterIP` | Kubernetes service type |
| `service.port` | `8080` | Service port |

### Ingress

| Key | Default | Description |
|-----|---------|-------------|
| `ingress.enabled` | `false` | Enable ingress |
| `ingress.className` | `""` | Ingress class name |
| `ingress.annotations` | `{}` | Ingress annotations |
| `ingress.hosts` | `[{host: sabnzbd.example.com, ...}]` | Ingress host rules |
| `ingress.tls` | `[]` | TLS configuration |

Example:
```yaml
ingress:
  enabled: true
  className: nginx
  hosts:
    - host: sabnzbd.your-domain.com
      paths:
        - path: /
          pathType: Prefix
  tls:
    - secretName: sabnzbd-tls
      hosts:
        - sabnzbd.your-domain.com
```

### Persistence — config

Stores SABnzbd configuration and state.

| Key | Default | Description |
|-----|---------|-------------|
| `persistence.config.enabled` | `true` | Enable config volume |
| `persistence.config.mountPath` | `/config` | Mount path inside the container |
| `persistence.config.storageClass` | `""` | Storage class for the PVC |
| `persistence.config.existingClaim` | `""` | Use an existing PVC instead of creating one |
| `persistence.config.size` | `1Gi` | PVC size (ignored when using an existing claim) |
| `persistence.config.skipUninstall` | `true` | Retain the PVC when the chart is uninstalled |

### Persistence — downloads

Optionally mounts a downloads directory via NFS.

| Key | Default | Description |
|-----|---------|-------------|
| `persistence.downloads.enabled` | `false` | Enable downloads volume |
| `persistence.downloads.mountPath` | `/downloads` | Mount path inside the container |
| `persistence.downloads.nfs.server` | `""` | NFS server hostname or IP |
| `persistence.downloads.nfs.path` | `""` | NFS export path |

Example:
```yaml
persistence:
  downloads:
    enabled: true
    nfs:
      server: nas.local
      path: /volume1/downloads
```

### Resources

| Key | Default | Description |
|-----|---------|-------------|
| `resources` | `{}` | CPU/memory requests and limits |

Example:
```yaml
resources:
  requests:
    cpu: 100m
    memory: 256Mi
  limits:
    cpu: 2
    memory: 2Gi
```

### Scheduling

| Key | Default | Description |
|-----|---------|-------------|
| `nodeSelector` | `{}` | Node selector labels |
| `tolerations` | `[]` | Pod tolerations |
| `affinity` | `{}` | Pod affinity rules |
