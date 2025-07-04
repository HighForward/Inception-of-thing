#!/bin/bash
# Install K3s on the master node
curl -sfL https://get.k3s.io | sh -
sudo chown -R vagrant:vagrant /etc/rancher/k3s/

# Apply every pods in the cluster and the Ingress Controller
kubectl apply -f /vagrant/confs/config-map.yml
kubectl apply -f /vagrant/confs/app-one.yml
kubectl apply -f /vagrant/confs/app-two.yml
kubectl apply -f /vagrant/confs/app-three.yml
kubectl apply -f /vagrant/confs/ingress.yml