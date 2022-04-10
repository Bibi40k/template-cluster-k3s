#!/usr/bin/env bash

REPOURL="git@github.com:Bibi40k/template-cluster-k3s.git"
TEMPLATEURL="https://github.com/k8s-at-home/template-cluster-k3s"

# Check if template remote was already added
if ( ! git config --get remote.template.url | grep -q $TEMPLATEURL ); then
    git remote add --track main template $TEMPLATEURL
    git remote set-url template $TEMPLATEURL
    git remote set-url --push template no_push
    echo "Template remote added with no push access"
    git remote -v
else
    echo "Template remote already exists"
    git remote -v
fi

git pull template main # --allow-unrelated-histories

echo "Push changes to main remote"
git push