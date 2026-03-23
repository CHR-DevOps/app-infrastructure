#!/bin/bash
set -euxo pipefail
exec > /var/log/bootstrap.log 2>&1

export DEBIAN_FRONTEND=noninteractive

apt-get update -y
apt-get install -y curl ca-certificates

echo "Creating swap..."

fallocate -l 4G /swapfile || dd if=/dev/zero of=/swapfile bs=1M count=4096

chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile

echo '/swapfile none swap sw 0 0' >> /etc/fstab

sysctl vm.swappiness=10
echo 'vm.swappiness=10' >> /etc/sysctl.conf

free -h

curl -sfL https://get.k3s.io | sh -

export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
export PATH=$PATH:/usr/local/bin

echo "Waiting for k3s API..."
until /usr/local/bin/kubectl get nodes; do
  sleep 5
done

for ns in argocd prod argo-rollouts; do
  /usr/local/bin/kubectl create namespace "$ns" --dry-run=client -o yaml | /usr/local/bin/kubectl apply -f -
done

curl -L -o /tmp/argocd-install.yaml https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
/usr/local/bin/kubectl apply --server-side -n argocd -f /tmp/argocd-install.yaml

echo "Waiting for ArgoCD pods..."
until /usr/local/bin/kubectl get pods -n argocd; do
  sleep 5
done

curl -L -o /tmp/argo-rollouts-install.yaml https://github.com/argoproj/argo-rollouts/releases/latest/download/install.yaml
/usr/local/bin/kubectl apply -n argo-rollouts -f /tmp/argo-rollouts-install.yaml

echo "Waiting for Argo Rollouts pods..."
until /usr/local/bin/kubectl get pods -n argo-rollouts; do
  sleep 5
done

curl -LO https://github.com/argoproj/argo-rollouts/releases/latest/download/kubectl-argo-rollouts-linux-amd64
install -m 555 kubectl-argo-rollouts-linux-amd64 /usr/local/bin/kubectl-argo-rollouts
rm -f kubectl-argo-rollouts-linux-amd64

echo "Creating GHCR pull secret in prod..."
/usr/local/bin/kubectl create secret docker-registry ghcr-secret \
  --docker-server=ghcr.io \
  --docker-username='${github_username}' \
  --docker-password='${ghcr_token}' \
  --docker-email='no-reply@example.com' \
  -n prod \
  --dry-run=client -o yaml | /usr/local/bin/kubectl apply -f -

cat <<EOF >/tmp/prod-app.yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: prod-app
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/CHR-DevOps/app-infrastructure.git
    targetRevision: main
    path: kubernetes/prod
  destination:
    server: https://kubernetes.default.svc
    namespace: prod
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
EOF

/usr/local/bin/kubectl apply -f /tmp/prod-app.yaml

echo "Prod bootstrap complete"