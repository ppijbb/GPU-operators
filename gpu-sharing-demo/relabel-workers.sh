#!/bin/bash
# 기존 워커 노드 풀 재분류

# T4 풀
kubectl label node desktop-worker  run.ai/simulated-gpu-node-pool=t4-pool --overwrite
kubectl label node desktop-worker3 run.ai/simulated-gpu-node-pool=t4-pool --overwrite
kubectl label node desktop-worker4 run.ai/simulated-gpu-node-pool=t4-pool --overwrite

# A100 풀
kubectl label node desktop-worker2 run.ai/simulated-gpu-node-pool=a100-pool --overwrite

echo "Done. Current labels:"
kubectl get nodes -l run.ai/fake.gpu=true --show-labels | grep -o 'simulated-gpu-node-pool=[^,]*'
