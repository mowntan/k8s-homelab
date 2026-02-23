# Setup Guide

This guide will help you set up this repository under your GitHub account to maintain these homelab applications.

## Prerequisites

- GitHub account
- `git` and `gh` (GitHub CLI) installed
- Docker installed (for local testing)
- Helm installed (for chart testing)

## Initial Setup

### 1. Create GitHub Repository

```bash
# Initialize git repository (if not already done)
git init

# Create repository on GitHub
gh repo create k8s-homelab --public --source=. --remote=origin

# Push initial commit
git add .
git commit -m "Initial commit: Setup homelab apps infrastructure"
git push -u origin main
```

### 2. Enable GitHub Pages for Helm Charts

1. Go to your repository settings on GitHub
2. Navigate to **Settings → Pages**
3. Under **Source**, select **Deploy from a branch**
4. Select branch `gh-pages` and folder `/charts`
5. Click **Save**

After the first workflow run, your Helm charts will be available at:
```
https://mowntan.github.io/k8s-homelab/charts
```

### 3. Configure GitHub Actions Permissions

1. Go to **Settings → Actions → General**
2. Under **Workflow permissions**, select:
   - ✅ Read and write permissions
   - ✅ Allow GitHub Actions to create and approve pull requests
3. Click **Save**

This allows workflows to:
- Create pull requests for version bumps
- Push Docker images to GHCR
- Deploy Helm charts to GitHub Pages

## Workflow Overview

Each app has two GitHub Actions workflows:

### 1. Check for New Release (`check-release.yml`)

**Trigger:** Daily at 06:00 UTC or manual dispatch

**What it does:**
- Queries the upstream GitHub releases API
- Compares with the current `VERSION` file
- If newer version exists:
  - Updates `VERSION` file
  - Updates `Chart.yaml` appVersion
  - Opens a pull request

**Manual trigger:**
```bash
gh workflow run <app>-check-release.yml
```

### 2. Build and Push Docker Image (`build.yml`)

**Trigger:**
- Push to `main` when `VERSION`, `Dockerfile`, or workflow changes
- Manual dispatch

**What it does:**
- Reads version from `VERSION` file
- Builds Docker image with that version
- Pushes to `ghcr.io/mowntan/<app>:<version>` and `latest`
- Uses GitHub Actions cache for faster builds

**Manual trigger:**
```bash
gh workflow run <app>-build.yml
```

### 3. Release Helm Charts (`release-charts.yml`)

**Trigger:**
- Push to `main` when any chart changes
- Manual dispatch

**What it does:**
- Packages all Helm charts
- Generates Helm repository index
- Deploys to GitHub Pages (`gh-pages` branch)

## Using the Published Charts

After setup, add your Helm repository:

```bash
helm repo add mowntan https://mowntan.github.io/k8s-homelab/charts
helm repo update
helm search repo mowntan
```

Install a chart:

```bash
helm install sabnzbd mowntan/sabnzbd
```

## Local Development

### Build Docker image

```bash
cd apps/<app>
docker build -t <app>:local -f docker/Dockerfile docker/
```

### Test Docker image

```bash
docker run -it --rm \
  -p <port>:<port> \
  -v $(pwd)/test-config:/config \
  <app>:local
```

### Test Helm chart

```bash
cd apps/<app>
helm lint ./chart
helm install <app>-test ./chart --dry-run --debug
```

### Package Helm chart manually

```bash
cd apps/<app>
helm package ./chart -d /tmp/
```

## Maintenance

### Adding a New App

1. Create directory structure:
```bash
mkdir -p apps/<app>/{docker,chart/templates,.github/workflows}
```

2. Copy and modify files from an existing app:
   - `VERSION` - Set initial version
   - `docker/Dockerfile` - Adapt for the new app
   - `chart/` - Update Chart.yaml, values.yaml, templates
   - `.github/workflows/` - Update app name and version detection
   - `README.md` - Document the app

3. Update root `README.md` to include the new app in the table

4. Commit and push to trigger workflows

### Updating App Versions

**Automatic:** Merge the PR created by the check-release workflow

**Manual:**
1. Update `VERSION` file
2. Update `chart/Chart.yaml` appVersion
3. Commit and push to `main`
4. Build workflow will trigger automatically

### Troubleshooting

**Workflow fails with permission errors:**
- Check Actions permissions in repository settings
- Ensure GITHUB_TOKEN has write access

**Docker build fails:**
- Check Dockerfile syntax
- Verify upstream release URLs
- Test build locally first

**Chart deployment fails:**
- Ensure GitHub Pages is enabled
- Check `gh-pages` branch exists
- Verify chart lint passes: `helm lint ./chart`

**Version check creates duplicate PRs:**
- Close old PRs manually
- The workflow checks for existing PRs by branch name

## Repository Maintenance

### Keep Dependencies Updated

Periodically update GitHub Actions:
```bash
# Check for action updates
grep -r "uses:" .github/workflows/
```

Update action versions in workflow files as needed.

### Monitor Upstream Changes

Watch upstream repositories for:
- Breaking changes in new releases
- Changes to download URLs
- New dependencies

### Security

- Docker images run as non-root users (UIDs 6543-6547)
- Regular automated updates reduce security lag
- Review PRs before merging to catch issues

## Questions?

Check each app's README for app-specific details.

For repository structure questions, open an issue on GitHub.
