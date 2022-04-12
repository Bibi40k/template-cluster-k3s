#!/usr/bin/env bash

GITHUB_USER="Bibi40k"
REPONAME="template-cluster-k3s"
FLUXWATCHDIR="./cluster/test"

flux bootstrap github \
  --owner=$GITHUB_USER \
  --repository=$REPONAME \
  --branch=main \
  --path=$FLUXWATCHDIR \
  --personal

flux create source git podinfo \
  --url=https://github.com/stefanprodan/podinfo \
  --branch=master \
  --interval=30s \
  --export > $FLUXWATCHDIR/podinfo-source.yaml

git add -A && git commit -m "Add podinfo GitRepository"
git push

flux create kustomization podinfo \
  --target-namespace=default \
  --source=podinfo \
  --path="./kustomize" \
  --prune=true \
  --interval=5m \
  --export > $FLUXWATCHDIR/podinfo-kustomization.yaml

git add -A && git commit -m "Add podinfo Kustomization"
git push

flux get kustomizations --watch
