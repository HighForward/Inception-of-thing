#!/bin/bash

set -e

NODE_IP="192.168.56.110"

echo "🔧 Installing K3s on server node at $NODE_IP..."
curl -sfL https://get.k3s.io | sh -s - --write-kubeconfig-mode 644 --node-ip=$NODE_IP

while [ ! -f /etc/rancher/k3s/k3s.yaml ] || [ ! -f /var/lib/rancher/k3s/server/node-token ]; do
  echo "⏳ Waiting for K3s to be ready..."
  sleep 2
done
echo "✅ K3s is ready!"

mkdir -p /home/vagrant/.kube
cp /etc/rancher/k3s/k3s.yaml /home/vagrant/.kube/config
chown -R vagrant:vagrant /home/vagrant/.kube

mkdir -p /vagrant/confs
cat /var/lib/rancher/k3s/server/node-token > /vagrant/confs/token

MANIFEST_DIR="/vagrant/confs"
echo "📦 Looking for Kubernetes YAMLs in $MANIFEST_DIR"

if ls $MANIFEST_DIR/*.yml >/dev/null 2>&1; then
  echo "🚀 Applying Kubernetes manifests..."
  kubectl apply -f $MANIFEST_DIR/config-map.yml || true
  kubectl apply -f $MANIFEST_DIR/app-one.yml || true
  kubectl apply -f $MANIFEST_DIR/app-two.yml || true
  kubectl apply -f $MANIFEST_DIR/app-three.yml || true
  kubectl apply -f $MANIFEST_DIR/ingress.yml || true
else
  echo "⚠️ No YAML files found in $MANIFEST_DIR. Skipping kubectl apply."
fi

echo "✅ Script completed!"
