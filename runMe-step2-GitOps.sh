#!/usr/bin/env bash


# shellcheck disable=SC2155
export PROJECT_DIR=$(git rev-parse --show-toplevel)

source "${PROJECT_DIR}/scripts/functions.inc"

OS=$(checkOS)

if [ "$OS" == "MacOS" ]; then
    # shellcheck disable=SC2155
    export SOPS_AGE_KEY_FILE="$HOME/Library/Application Support/sops/age/keys.txt"
elif [ "$OS" == "Linux" ]; then
    # shellcheck disable=SC2155
    export SOPS_AGE_KEY_FILE=~/.config/sops/age/keys.txt
fi

KUBECONFIG=~/.kube/config

flux --kubeconfig=$KUBECONFIG check --pre

kubectl --kubeconfig=$KUBECONFIG \
    create namespace flux-system \
    --dry-run=client -o yaml | kubectl \
    --kubeconfig=$KUBECONFIG apply -f -

# Delete old secret
kubectl --kubeconfig=$KUBECONFIG \
    -n flux-system \
    delete secret sops-age \
    --ignore-not-found

cat "$SOPS_AGE_KEY_FILE" |
    kubectl --kubeconfig=$KUBECONFIG \
    -n flux-system \
    create secret generic sops-age \
    --from-file=age.agekey=/dev/stdin

git add -A
git commit -m "push from step2-GitOps"
git push

# Install Flux
kubectl --kubeconfig=$KUBECONFIG apply --kustomize=${PROJECT_DIR}/cluster/base/flux-system
kubectl --kubeconfig=$KUBECONFIG apply --kustomize=${PROJECT_DIR}/cluster/base/flux-system

# Verify Flux components are running in the cluster
watch kubectl --kubeconfig=$KUBECONFIG get pods -n flux-system
