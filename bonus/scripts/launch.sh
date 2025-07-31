#!/bin/bash

set -e

echo "🚀 Launching bonus setup..."

# Run the install script if needed
if ! command -v k3d &> /dev/null \
    || ! command -v kubectl &> /dev/null; then
    echo "Installing dependencies..."
    chmod +x install.sh
    ./install.sh
    echo "Please run 'newgrp docker' or restart shell, then run this script again"
    exit 1
fi

# Create k3d cluster
echo "Creating k3d cluster..."
k3d cluster create iot-cluster \
    -p "80:80@loadbalancer" \
    -p "8888:8080@loadbalancer" \
    --k3s-arg "--disable=traefik@server:0" || echo "Cluster might already exist"

# Create namespaces
echo "Creating namespaces..."
kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace dev --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace gitlab --dry-run=client -o yaml | kubectl apply -f -

echo "📦 Installing Helm..."
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash


# Install Argo CD
echo "Installing Argo CD..."
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Wait for Argo CD to be ready
echo "Waiting for Argo CD..."
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=argocd-server -n argocd --timeout=300s

# Apply your application
echo "Applying Argo CD application..."
kubectl apply -f ../confs/app.yaml

# Get Argo CD admin password
echo "Getting Argo CD admin password..."
ARGOCD_PASSWORD=$(kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath="{.data.password}" | base64 --decode)

##Nginx controller install
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update

helm install ingress-nginx ingress-nginx/ingress-nginx \
  --namespace ingress-nginx \
  --create-namespace

##Gitlab install with helm
echo "Adding GitLab Helm repository..."
helm repo add gitlab https://charts.gitlab.io/ || true
helm repo update

echo "Installing GitLab with Helm (this will take a while)..."
helm upgrade --install gitlab gitlab/gitlab \
  --namespace gitlab \
  -f /vagrant/confs/gitlab-values.yaml \
  --timeout 1200s

echo "Waiting for GitLab pods to be ready (this can take 5-15 minutes)..."
kubectl wait --for=condition=ready pod \
  --selector='!job-name' \
  -n gitlab \
  --timeout=1200s

echo "Applying GitLab ServiceAccount for cluster integration..."
kubectl apply -f ../confs/gitlab-sa.yaml

echo "Getting GitLab initial root password..."
GITLAB_PASSWORD=$(kubectl get secret gitlab-gitlab-initial-root-password -n gitlab -ojsonpath='{.data.password}' | base64 --decode)

echo "✅ Setup complete!"
echo "Access Argo CD: kubectl port-forward --address 192.168.56.130 svc/argocd-server 8080:80 -n argocd"
echo "Username: admin"
echo "Password: $ARGOCD_PASSWORD"
echo ""
echo "Access GitLab: http://gitlab.local"
echo "GitLab Username: root"
echo "GitLab Initial Password: $GITLAB_PASSWORD"
echo ""
echo "Your app should be deployed to 'dev' namespace"
echo "Check with: kubectl get pods -n dev"
