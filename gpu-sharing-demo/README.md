# GPU Sharing Demo

fake-gpu-operator에서 Run:ai fractional GPU vs MIG 비교 실습

## 순서

### 1. Grafana + Prometheus 배포
```bash
kubectl apply -f grafana.yaml
```

### 2. Run:ai fractional Pod 배포 (현재 T4 클러스터에서 동작)
```bash
kubectl apply -f runai-fractional.yaml
kubectl get pods -l mode=runai-fractional
```

### 3. MIG 데모 Pod (A100 전용 - 현재 클러스터에선 Pending이 정상)
```bash
kubectl apply -f mig-demo.yaml
kubectl get pods -l mode=mig   # T4라 Pending 상태
```

### 4. Grafana 접속
```bash
# 노드 IP 확인
kubectl get nodes -o wide

# NodePort 30300으로 접속
# http://<node-ip>:30300  (admin/admin)
```

### 5. DCGM 대시보드 임포트
Grafana UI → Dashboards → Import → **12239** 입력 → Prometheus 선택

## 확인할 메트릭

| 메트릭 | 설명 |
|--------|------|
| `DCGM_FI_DEV_GPU_UTIL` | GPU utilization (%) |
| `DCGM_FI_DEV_MEM_COPY_UTIL` | Memory bandwidth |
| `DCGM_FI_DEV_FB_USED` | Framebuffer (VRAM) used |
| `DCGM_FI_DEV_FB_FREE` | Framebuffer free |

## 비교 포인트

- **Run:ai fractional**: 같은 GPU에 여러 Pod가 util 합산되는 것 확인
- **MIG**: 각 슬라이스가 독립된 GPU로 보임 (A100 있을 때)
