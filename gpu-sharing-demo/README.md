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

## 들쭉날쭉(Bursty) Run:ai 데모 — Deployment / Job / CronJob + HPA

Pod 단발 데모(`runai-fractional.yaml`)와 달리, **워크로드가 시간에 따라 출렁이는** 현실 시나리오:

```bash
kubectl apply -f runai-hpa-demo.yaml

# 상태 관찰
kubectl get hpa runai-inference-hpa -w
kubectl get pods -l mode=runai-fractional -w
kubectl get jobs,cronjobs
```

| 리소스 | 패턴 | 어노테이션 |
|--------|------|-----------|
| Deployment `runai-inference` + HPA | 30s burst / 30s idle 반복 → CPU 50% 기준 1~8 replica 오토스케일 | util 30~90% |
| Job `runai-train-burst` | parallelism=4, ~2분 학습 burst | util 70~100% |
| CronJob `runai-batch-inference` | 2분마다 45s batch | util 50~80% |

Grafana `DCGM_FI_DEV_GPU_UTIL` 그래프가 **계단/톱니 형태**로 흔들리는 게 핵심.

### GPU util 기반 HPA로 바꾸기 (옵션)

CPU 대신 실제 GPU util로 스케일하려면 `prometheus-adapter` 설치 후
`runai-hpa-demo.yaml` 안의 주석 처리된 `runai-inference-gpu-hpa` 블록 활성화.
설치 명령은 같은 파일 주석 참고.

### 정리
```bash
kubectl delete -f runai-hpa-demo.yaml
```

## 비교 포인트

- **Run:ai fractional**: 같은 GPU에 여러 Pod가 util 합산되는 것 확인
- **MIG**: 각 슬라이스가 독립된 GPU로 보임 (A100 있을 때)
