#!/usr/bin/env bash

set -o errexit
set -o pipefail

# shellcheck disable=SC2155
export PROJECT_DIR=$(git rev-parse --show-toplevel)

echo "PJDIR="${PROJECT_DIR}

# shellcheck disable=SC2155
export SOPS_AGE_KEY_FILE=~/.config/sops/age/keys.txt

# shellcheck disable=SC1091
source "${PROJECT_DIR}/.config.env"
source "${PROJECT_DIR}/scripts/functions.inc"

OS=$(checkOS)

verify_binaries() {
    _has_binary "pre-commit"
    _has_binary "age-keygen"
}

# pre-commit
# https://github.com/k8s-at-home/template-cluster-k3s#%EF%B8%8F-pre-commit
task pre-commit:init
pre-commit install --install-hooks
pre-commit autoupdate

# Setting up Age
# https://github.com/k8s-at-home/template-cluster-k3s#-setting-up-age
printf "\n * Creating a Age Private / Public Key\n"
age-keygen -o age.agekey

printf " * Setting up the directory for the Age key and move the Age file to it\n"
mkdir -p ~/.config/sops/age
mv age.agekey $SOPS_AGE_KEY_FILE

printf " * Exporting the SOPS_AGE_KEY_FILE variable in your bashrc, zshrc or config.fish and source it\n"
export SOPS_AGE_KEY_FILE=$SOPS_AGE_KEY_FILE

printf " * Filling out the Age public key in the .config.env under BOOTSTRAP_AGE_PUBLIC_KEY\n"
if [[ ! -f ${PROJECT_DIR}/.config.env ]]; then
    cp ${PROJECT_DIR}/.config.sample.env ${PROJECT_DIR}/.config.env
fi
AGE_PUBLIC_KEY=$(cat $SOPS_AGE_KEY_FILE | grep 'public key' | awk '{print $4}')

if [ "$OS" == "MacOS" ]; then
    source ~/.bash_profile
    sed -i -e "s/BOOTSTRAP_AGE_PUBLIC_KEY.*/BOOTSTRAP_AGE_PUBLIC_KEY=\"${AGE_PUBLIC_KEY}\"/" ${PROJECT_DIR}/.config.env
elif [ "$OS" == "Linux" ]; then
    source ~/.bashrc
    sed -i "s/BOOTSTRAP_AGE_PUBLIC_KEY.*/BOOTSTRAP_AGE_PUBLIC_KEY=\"${AGE_PUBLIC_KEY}\"/g" "${PROJECT_DIR}/.config.env"
fi
