#!/bin/bash

set -e

echo "🚀 Launching Part 3 setup..."

# Run the install script if needed
if ! command -v k3d &> /dev/null || ! command -v kubectl &> /dev/null || ! command -v argocd &> /dev/null; then
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

echo "✅ Setup complete!"
echo "Access Argo CD: kubectl port-forward --address 192.168.56.120 svc/argocd-server 8080:80 -n argocd"
echo "Username: admin"
echo "Password: $ARGOCD_PASSWORD"
echo ""
echo "Your app should be deployed to 'dev' namespace"
echo "Check with: kubectl get pods -n dev"
