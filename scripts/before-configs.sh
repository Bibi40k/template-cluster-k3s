#!/usr/bin/env bash

export PROJECT_DIR=$(git rev-parse --show-toplevel)

source "${PROJECT_DIR}/scripts/functions.inc"

OS=$(checkOS)

# pre-commit
# https://github.com/k8s-at-home/template-cluster-k3s#%EF%B8%8F-pre-commit
task pre-commit:init
pre-commit install --install-hooks
pre-commit autoupdate

# Setting up Age
# https://github.com/k8s-at-home/template-cluster-k3s#-setting-up-age
if [ "$OS" == "MacOS" ]; then
    SOPS_AGE_DIR="${HOME}/Library/Application Support/sops/age"
elif [ "$OS" == "Linux" ]; then
    SOPS_AGE_DIR="${HOME}/.config/sops/age"
fi

if [[ ! -f "${SOPS_AGE_DIR}/keys.txt" ]]; then
    age-keygen -o age.agekey
    mkdir -p "${SOPS_AGE_DIR}"
    mv age.agekey "${SOPS_AGE_DIR}/keys.txt"
fi

export SOPS_AGE_KEY_FILE="${SOPS_AGE_DIR}/keys.txt"
if [ "$OS" == "MacOS" ]; then
    source ~/.profile
elif [ "$OS" == "Linux" ]; then
    source ~/.bashrc
fi

if [[ ! -f ${PROJECT_DIR}/.config.env ]]; then
    cp ${PROJECT_DIR}/.config.sample.env ${PROJECT_DIR}/.config.env
fi
AGE_PUBLIC_KEY=$(cat "${SOPS_AGE_KEY_FILE}" | grep 'public key' | awk '{print $4}')

if [ "$OS" == "MacOS" ]; then
    sed -i '' -e "s/BOOTSTRAP_AGE_PUBLIC_KEY.*/BOOTSTRAP_AGE_PUBLIC_KEY=\"${AGE_PUBLIC_KEY}\"/" ${PROJECT_DIR}/.config.env
elif [ "$OS" == "Linux" ]; then
    sed -i "s/BOOTSTRAP_AGE_PUBLIC_KEY.*/BOOTSTRAP_AGE_PUBLIC_KEY=\"${AGE_PUBLIC_KEY}\"/g" "${PROJECT_DIR}/.config.env"
fi
