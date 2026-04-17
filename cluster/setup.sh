#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "=== 1. kind 클러스터 생성 ==="
~/bin/kind create cluster --config "$SCRIPT_DIR/kind-cluster.yaml" --wait 60s

echo "=== 2. kubectl context 확인 ==="
kubectl config use-context kind-gpu-lab
kubectl get nodes

echo "=== 3. fake-gpu-operator 설치 ==="
helm upgrade -i gpu-operator \
  oci://ghcr.io/run-ai/fake-gpu-operator/fake-gpu-operator \
  --namespace gpu-operator \
  --create-namespace \
  -f "$SCRIPT_DIR/fake-gpu-values.yaml" \
  --wait

echo "=== 4. KWOK controller 설치 (H100 시뮬레이션 노드용) ==="
KWOK_VERSION=v0.7.0
kubectl apply -f "https://github.com/kubernetes-sigs/kwok/releases/download/${KWOK_VERSION}/kwok.yaml"
kubectl apply -f "https://github.com/kubernetes-sigs/kwok/releases/download/${KWOK_VERSION}/stage-fast.yaml"
kubectl rollout status deployment/kwok-controller -n kube-system --timeout=60s

echo ""
echo "=== 완료 ==="
kubectl get nodes -o wide
