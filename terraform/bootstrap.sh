#!/bin/bash
set -euxo pipefail

exec > /var/log/bootstrap.log 2>&1

export DEBIAN_FRONTEND=noninteractive
apt-get update -y
apt-get install -y curl ca-certificates

curl -sfL https://get.k3s.io | sh -

export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
export PATH=$PATH:/usr/local/bin

echo "Waiting for k3s API..."
until /usr/local/bin/kubectl get nodes; do
  sleep 5
done

for ns in argocd dev test staging prod; do
  /usr/local/bin/kubectl create namespace "$ns" --dry-run=client -o yaml | /usr/local/bin/kubectl apply -f -
done

/usr/local/bin/kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

echo "Waiting for ArgoCD pods..."
until /usr/local/bin/kubectl get pods -n argocd; do
  sleep 5
done

/usr/local/bin/kubectl create secret docker-registry ghcr-secret \
  --docker-server=ghcr.io \
  --docker-username='${github_username}' \
  --docker-password='${ghcr_token}' \
  --docker-email=no-reply@example.com \
  -n staging \
  --dry-run=client -o yaml | /usr/local/bin/kubectl apply -f -

curl -L -o /tmp/staging-app.yaml https://raw.githubusercontent.com/CHR-DevOps/app-infrastructure/${git_branch}/argocd/staging-app.yaml

/usr/local/bin/kubectl apply -f /tmp/staging-app.yaml

echo "Bootstrap complete"