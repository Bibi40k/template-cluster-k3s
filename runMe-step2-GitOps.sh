#!/usr/bin/env bash

set -o errexit
set -o pipefail

# shellcheck disable=SC2155
export PROJECT_DIR=$(git rev-parse --show-toplevel)

# shellcheck disable=SC2155
export SOPS_AGE_KEY_FILE=~/.config/sops/age/keys.txt

KUBECONFIG=~/.kube/config

main() {
    flux --kubeconfig=$KUBECONFIG check --pre
    kubectl --kubeconfig=$KUBECONFIG create namespace flux-system --dry-run=client -o yaml | kubectl --kubeconfig=$KUBECONFIG apply -f -

    # Delete old secret
    kubectl --kubeconfig=$KUBECONFIG \
        -n flux-system delete secret sops-age \
        --ignore-not-found

    cat $SOPS_AGE_KEY_FILE |
        kubectl --kubeconfig=$KUBECONFIG \
        -n flux-system create secret generic sops-age \
        --from-file=age.agekey=/dev/stdin

    git add -A
    git commit -m "push from step2-GitOps"
    git push
}

_log() {
    local type="${1}"
    local msg="${2}"
    printf "[%s] [%s] %s\n" "$(date -u)" "${type}" "${msg}"
}

main "$@"
