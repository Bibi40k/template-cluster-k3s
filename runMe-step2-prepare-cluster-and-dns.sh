#!/usr/bin/env bash

# shellcheck disable=SC2155
export PROJECT_DIR=$(git rev-parse --show-toplevel)

source "${PROJECT_DIR}/scripts/functions.inc"

OS=$(checkOS)

if [ "$OS" == "MacOS" ]; then
    SOPS_AGE_KEY_FILE="${HOME}/Library/Application Support/sops/age/keys.txt"
elif [ "$OS" == "Linux" ]; then
    SOPS_AGE_KEY_FILE="${HOME}/.config/sops/age/keys.txt"
fi

KUBECONFIG_FILE="${PROJECT_DIR}/provision/kubeconfig"
talosctl kubeconfig "${KUBECONFIG_FILE}"

# Verify the nodes are online
# https://github.com/k8s-at-home/template-cluster-k3s#-installing-k3s-with-ansible
kubectl --kubeconfig="${KUBECONFIG_FILE}" get nodes

# Configuring Cloudflare DNS with Terraform
# https://github.com/k8s-at-home/template-cluster-k3s#%EF%B8%8F-configuring-cloudflare-dns-with-terraform
task terraform:init:cloudflare
task terraform:plan:cloudflare
task terraform:apply:cloudflare

# GitOps with Flux
# https://github.com/k8s-at-home/template-cluster-k3s#-gitops-with-flux

# Verify Flux can be installed
flux --kubeconfig="${KUBECONFIG_FILE}" check --pre

# Pre-create the flux-system namespace
kubectl --kubeconfig="${KUBECONFIG_FILE}" \
    create namespace flux-system \
    --dry-run=client -o yaml | kubectl --kubeconfig="${KUBECONFIG_FILE}" apply -f -

# Add the Age key in-order for Flux to decrypt SOPS secrets
# Delete old secret
kubectl --kubeconfig="${KUBECONFIG_FILE}" \
    -n flux-system \
    delete secret sops-age \
    --ignore-not-found

cat "${SOPS_AGE_KEY_FILE}" |
    kubectl --kubeconfig="${KUBECONFIG_FILE}" \
    -n flux-system create secret generic sops-age \
    --from-file=age.agekey=/dev/stdin

git add -A
git commit -m "push from step2-GitOps"
git push
