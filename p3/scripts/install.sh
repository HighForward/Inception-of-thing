#!/bin/bash

set -e

echo "📦 Installing dependencies for K3d and Argo CD..."

# -----------------------------
# Basic system dependencies
# -----------------------------
sudo apt update && sudo apt install -y \
  curl wget apt-transport-https ca-certificates gnupg lsb-release software-properties-common

# -----------------------------
# Docker
# -----------------------------
echo "🐳 Installing Docker..."

# Remove any old versions if they exist
sudo apt remove -y docker docker-engine docker.io containerd runc || true

# Install Docker using official install script
curl -fsSL https://get.docker.com | sudo bash

# Add user to docker group to avoid needing sudo
sudo usermod -aG docker $USER

# -----------------------------
# kubectl (official binary)
# -----------------------------
echo "📦 Installing kubectl..."

KUBECTL_VERSION=$(curl -s https://dl.k8s.io/release/stable.txt)

# Fallback if the version string is invalid
if [[ ! "$KUBECTL_VERSION" =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "⚠️  Failed to fetch latest kubectl version, using fallback v1.30.1"
  KUBECTL_VERSION="v1.30.1"
fi

curl -LO "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/


# -----------------------------
# k3d
# -----------------------------
echo "📦 Installing k3d..."

curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash

# -----------------------------
# Argo CD CLI
# -----------------------------
echo "📦 Installing Argo CD CLI..."

curl -sSL -o argocd https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
chmod +x argocd
sudo mv argocd /usr/local/bin/

echo "✅ All tools installed successfully!"
echo "⚠️  Please run 'newgrp docker' or restart your shell to use Docker without sudo."
