#!/usr/bin/env bash

TEMPLATEURL="https://github.com/k8s-at-home/template-cluster-k3s"

git remote add --track main template $TEMPLATEURL
git remote set-url template $TEMPLATEURL
git remote set-url --push template no_push
git remote -v
git pull template main # --allow-unrelated-histories