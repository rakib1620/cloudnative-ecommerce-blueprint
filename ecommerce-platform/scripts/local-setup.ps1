# PowerShell script for local Kind cluster setup on Windows
$ErrorActionPreference = "Stop"

$ClusterName = "ecommerce-local"

Write-Host "=== [1/4] Checking Prerequisites ===" -ForegroundColor Cyan
$required = @("docker", "kind", "kubectl", "helm")
foreach ($cmd in $required) {
    if (-not (Get-Command $cmd -ErrorAction SilentlyContinue)) {
        Write-Warning "$cmd is not installed or not in PATH."
    } else {
        Write-Host " [x] $cmd found" -ForegroundColor Green
    }
}

Write-Host "=== [2/4] Creating Kind Cluster with Ingress Ports (80, 443) ===" -ForegroundColor Cyan
$config = @"
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
"@

$config | kind create cluster --name $ClusterName --config=-

Write-Host "=== [3/4] Installing Ingress Nginx Controller ===" -ForegroundColor Cyan
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml

Write-Host "Waiting for Ingress Nginx controller to become ready..." -ForegroundColor Yellow
kubectl wait --namespace ingress-nginx --for=condition=ready pod --selector=app.kubernetes.io/component=controller --timeout=180s

Write-Host "=== [4/4] Setting Up Core Namespaces ===" -ForegroundColor Cyan
kubectl create namespace ecommerce --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace monitoring --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -

Write-Host "==========================================================" -ForegroundColor Green
Write-Host " Kind cluster '$ClusterName' is successfully running!" -ForegroundColor Green
Write-Host "==========================================================" -ForegroundColor Green
