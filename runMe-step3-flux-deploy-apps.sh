#!/usr/bin/env bash

# shellcheck disable=SC2155
export PROJECT_DIR=$(git rev-parse --show-toplevel)

KUBECONFIG_FILE="${PROJECT_DIR}/provision/kubeconfig"

if [[ ! -f "${KUBECONFIG_FILE}" ]]; then
    talosctl kubeconfig "${KUBECONFIG_FILE}"
fi

# Install Flux
# https://github.com/k8s-at-home/template-cluster-k3s#-gitops-with-flux
kubectl --kubeconfig="${KUBECONFIG_FILE}" apply --kustomize=${PROJECT_DIR}/cluster/base/flux-system
kubectl --kubeconfig="${KUBECONFIG_FILE}" apply --kustomize=${PROJECT_DIR}/cluster/base/flux-system

# Verify Flux components are running in the cluster
watch kubectl --kubeconfig="${KUBECONFIG_FILE}" get pods -n flux-system
