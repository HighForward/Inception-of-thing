#!/bin/bash

set -e

echo "📦 Installing dependencies for K3d and Argo CD..."


sudo apt update && sudo apt install -y \
  curl wget apt-transport-https ca-certificates gnupg lsb-release software-properties-common

echo "🐳 Installing Docker..."

sudo apt remove -y docker docker-engine docker.io containerd runc || true

curl -fsSL https://get.docker.com | sudo bash

sudo usermod -aG docker $USER


echo "📦 Installing kubectl..."

KUBECTL_VERSION=$(curl -s https://dl.k8s.io/release/stable.txt)

if [[ ! "$KUBECTL_VERSION" =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "⚠️  Failed to fetch latest kubectl version, using fallback v1.30.1"
  KUBECTL_VERSION="v1.30.1"
fi

curl -LO "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/



echo "📦 Installing k3d..."

curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash


echo "📦 Installing Argo CD CLI..."

curl -sSL -o argocd https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
chmod +x argocd
sudo mv argocd /usr/local/bin/

echo "✅ All tools installed successfully!"
echo "⚠️  Please run 'newgrp docker' or restart your shell to use Docker without sudo."
