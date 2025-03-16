#!/usr/bin/env bash

set -euo pipefail

REMOTE_REPO_NAME=natgw_onoff
TARGET_REPO_PATH=~/natgw_onoff
DEFAULT_BRANCH_NAME=master

# このコマンド群では、あるリモートリポジトリの指定したブランチを、指定したディレクトリに取り込みます。
# git read-tree : 指定したリモートリポジトリの指定したブランチを、指定したディレクトリに取り込む
# git merge -s subtree : 指定したリモートリポジトリの指定したブランチを、指定したディレクトリに取り込む
git remote add $REMOTE_REPO_NAME $TARGET_REPO_PATH \
&& git fetch $REMOTE_REPO_NAME \
&& git read-tree --prefix=$REMOTE_REPO_NAME/ $REMOTE_REPO_NAME/$DEFAULT_BRANCH_NAME \
&& git checkout -- . \
&& git add . \
&& git commit -m "add $REMOTE_REPO_NAME" \
&& git merge -s subtree $REMOTE_REPO_NAME/$DEFAULT_BRANCH_NAME --allow-unrelated-histories \
&& git remote remove $REMOTE_REPO_NAME

exit 0

