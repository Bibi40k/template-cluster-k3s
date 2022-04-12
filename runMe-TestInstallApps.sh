#!/usr/bin/env bash

# shellcheck disable=SC2155
export PROJECT_DIR=$(git rev-parse --show-toplevel)

flux create source git podinfo \
  --url=https://github.com/stefanprodan/podinfo \
  --branch=master \
  --interval=30s \
  --export > ${PROJECT_DIR}/cluster/test/podinfo-source.yaml

git add -A && git commit -m "Add podinfo GitRepository"
git push

flux create kustomization podinfo \
  --target-namespace=default \
  --source=podinfo \
  --path="./kustomize" \
  --prune=true \
  --interval=5m \
  --export > ${PROJECT_DIR}/cluster/test/podinfo-kustomization.yaml

git add -A && git commit -m "Add podinfo Kustomization"
git push

flux get kustomizations --watch
