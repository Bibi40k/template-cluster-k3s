#!/usr/bin/env bash

# shellcheck disable=SC2155
export PROJECT_DIR=$(git rev-parse --show-toplevel)

KUBECONFIG_FILE="${PROJECT_DIR}/provision/kubeconfig"

if [[ ! -f "${KUBECONFIG_FILE}" ]]; then
    talosctl kubeconfig "${KUBECONFIG_FILE}"
fi
# Verify the nodes are online
# https://github.com/k8s-at-home/template-cluster-k3s#-installing-k3s-with-ansible
kubectl --kubeconfig="${KUBECONFIG_FILE}" get nodes

# Configuring Cloudflare DNS with Terraform
# https://github.com/k8s-at-home/template-cluster-k3s#%EF%B8%8F-configuring-cloudflare-dns-with-terraform
task terraform:init:cloudflare
task terraform:plan:cloudflare
task terraform:apply:cloudflare


# OS=$(checkOS)

# if [ "$OS" == "MacOS" ]; then
#     # shellcheck disable=SC2155
#     export SOPS_AGE_KEY_FILE="$HOME/Library/Application Support/sops/age/keys.txt"
# elif [ "$OS" == "Linux" ]; then
#     # shellcheck disable=SC2155
#     export SOPS_AGE_KEY_FILE=~/.config/sops/age/keys.txt
# fi

# KUBECONFIG=~/.kube/config

# flux --kubeconfig=$KUBECONFIG check --pre

# kubectl --kubeconfig=$KUBECONFIG \
#     create namespace flux-system \
#     --dry-run=client -o yaml | kubectl \
#     --kubeconfig=$KUBECONFIG apply -f -

# # Delete old secret
# kubectl --kubeconfig=$KUBECONFIG \
#     -n flux-system \
#     delete secret sops-age \
#     --ignore-not-found

# cat "$SOPS_AGE_KEY_FILE" |
#     kubectl --kubeconfig=$KUBECONFIG \
#     -n flux-system \
#     create secret generic sops-age \
#     --from-file=age.agekey=/dev/stdin

# git add -A
# git commit -m "push from step2-GitOps"
# git push

# # Install Flux
# kubectl --kubeconfig=$KUBECONFIG apply --kustomize=${PROJECT_DIR}/cluster/base/flux-system
# kubectl --kubeconfig=$KUBECONFIG apply --kustomize=${PROJECT_DIR}/cluster/base/flux-system

# # Verify Flux components are running in the cluster
# watch kubectl --kubeconfig=$KUBECONFIG get pods -n flux-system
