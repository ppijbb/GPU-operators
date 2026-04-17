# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This repository contains Kubernetes manifests for deploying applications to a Kubernetes cluster.

## Common Commands

```bash
# Apply manifests to the cluster
kubectl apply -f <file>.yaml

# Delete resources defined in a manifest
kubectl delete -f <file>.yaml

# Check deployment status
kubectl get deployments -n <namespace>
kubectl rollout status deployment/<name> -n <namespace>

# View running pods
kubectl get pods -n <namespace>

# View logs
kubectl logs -l app=<app-label> -n <namespace>

# Validate a manifest without applying it
kubectl apply --dry-run=client -f <file>.yaml

# Lint/validate YAML with kubeval or kubeconform (if available)
kubeconform <file>.yaml
```

## Structure

Currently contains:
- `test-app.yaml` — A Deployment (3 replicas, nginx:alpine) and NodePort Service exposing port 30080 in the `default` namespace.
