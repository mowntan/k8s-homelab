#!/bin/bash
set -e

echo "🚀 K8s Homelab Repository Setup"
echo "================================"
echo ""

# Check if gh is installed
if ! command -v gh &> /dev/null; then
    echo "❌ Error: GitHub CLI (gh) is not installed."
    echo "   Install it from: https://cli.github.com/"
    exit 1
fi

# Check if user is authenticated
if ! gh auth status &> /dev/null; then
    echo "❌ Error: Not authenticated with GitHub CLI."
    echo "   Run: gh auth login"
    exit 1
fi

echo "✅ GitHub CLI is installed and authenticated"
echo ""

# Get repository name
read -p "📝 Repository name (default: k8s-homelab): " REPO_NAME
REPO_NAME=${REPO_NAME:-k8s-homelab}

# Get visibility
echo ""
echo "Repository visibility:"
echo "  1) Public (recommended for GitHub Pages)"
echo "  2) Private"
read -p "Choose [1/2] (default: 1): " VISIBILITY_CHOICE
VISIBILITY_CHOICE=${VISIBILITY_CHOICE:-1}

if [ "$VISIBILITY_CHOICE" = "2" ]; then
    VISIBILITY="--private"
else
    VISIBILITY="--public"
fi

echo ""
echo "📦 Creating repository: $REPO_NAME ($VISIBILITY)"

# Initialize git if not already
if [ ! -d .git ]; then
    echo "   Initializing git repository..."
    git init
    git branch -M main
fi

# Create .gitignore if it doesn't exist
if [ ! -f .gitignore ]; then
    echo "   Creating .gitignore..."
    cat > .gitignore << 'EOF'
# IDE
.vscode/
.idea/
*.swp
*.swo
*~

# OS
.DS_Store
Thumbs.db

# Helm
*.tgz
charts/index.yaml

# Build artifacts
dist/
build/
*.log
EOF
fi

# Stage all files
echo "   Staging files..."
git add .

# Create initial commit
if ! git rev-parse HEAD &> /dev/null; then
    echo "   Creating initial commit..."
    git commit -m "Initial commit: Setup homelab apps infrastructure

- Docker images for: jackett, qbittorrent, radarr, sabnzbd, sonarr
- Helm charts for each application
- Automated CI/CD for version tracking and releases
- GitHub Pages setup for Helm chart repository"
fi

# Create GitHub repository
echo "   Creating GitHub repository..."
if gh repo create "$REPO_NAME" $VISIBILITY --source=. --remote=origin --push 2>&1 | grep -q "already exists"; then
    echo "   Repository already exists, adding remote..."
    git remote add origin "https://github.com/$(gh api user --jq .login)/${REPO_NAME}.git" 2>/dev/null || true
    git push -u origin main
else
    echo "   ✅ Repository created and pushed"
fi

echo ""
echo "🎉 Repository setup complete!"
echo ""
echo "📋 Next steps:"
echo ""
echo "1. Enable GitHub Actions permissions:"
echo "   → https://github.com/$(gh api user --jq .login)/${REPO_NAME}/settings/actions"
echo "   → Set 'Read and write permissions'"
echo "   → Allow creating pull requests"
echo ""
echo "2. Wait for first workflow run to create gh-pages branch"
echo ""
echo "3. Enable GitHub Pages:"
echo "   → https://github.com/$(gh api user --jq .login)/${REPO_NAME}/settings/pages"
echo "   → Source: Deploy from branch 'gh-pages' / '/charts'"
echo ""
echo "4. Add Helm repository (after GitHub Pages is configured):"
echo "   helm repo add mowntan https://$(gh api user --jq .login).github.io/${REPO_NAME}/charts"
echo ""
echo "📖 See SETUP.md for detailed configuration and usage instructions"
echo ""
