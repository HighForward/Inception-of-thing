#!/bin/bash

# Install K3s in server mode with readable kubeconfig
curl -sfL https://get.k3s.io | sh -s - --write-kubeconfig-mode 644 --node-ip=192.168.56.110

while [ ! -f /etc/rancher/k3s/k3s.yaml ] || [ ! -f /var/lib/rancher/k3s/server/node-token ]; do
  echo "Waiting for K3s to be ready..."
  sleep 2
done
echo "K3s is ready. Proceeding with config..."


mkdir -p /home/vagrant/.kube
cp /etc/rancher/k3s/k3s.yaml /home/vagrant/.kube/config
chown -R vagrant:vagrant /home/vagrant/.kube

mkdir -p /vagrant/confs
cat /var/lib/rancher/k3s/server/node-token > /vagrant/confs/token

