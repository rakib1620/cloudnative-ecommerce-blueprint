#!/usr/bin/env bash
set -euo pipefail

CLUSTER_NAME="ecommerce-local"

echo "=== [1/4] Checking Prerequisites ==="
for cmd in docker kind kubectl helm; do
  if ! command -v "$cmd" &> /dev/null; then
    echo "ERROR: $cmd is not installed. Please install it first."
    exit 1
  fi
done

echo "=== [2/4] Creating Kind Cluster with Ingress Ports (80, 443) ==="
cat <<EOF | kind create cluster --name "${CLUSTER_NAME}" --config=-
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
  kubeadmConfigPatches:
  - |
    kind: InitConfiguration
    nodeRegistration:
      kubeletExtraArgs:
        node-labels: "ingress-ready=true"
  extraPortMappings:
  - containerPort: 80
    hostPort: 80
    protocol: TCP
  - containerPort: 443
    hostPort: 443
    protocol: TCP
EOF

echo "=== [3/4] Installing Ingress Nginx Controller ==="
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml

echo "Waiting for Ingress Nginx pods to be ready..."
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=120s

echo "=== [4/4] Creating Namespaces ==="
kubectl create namespace ecommerce || true
kubectl create namespace monitoring || true
kubectl create namespace argocd || true

echo "=========================================================="
echo " Kind cluster '${CLUSTER_NAME}' is ready!"
echo " Use: kubectl get nodes"
echo "=========================================================="
