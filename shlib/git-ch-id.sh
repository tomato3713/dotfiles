#! /bin/bash

ch-git-name()
{
    # 変更後のアカウント ID
    oldID=$1
    newID=$2

    opt="s/${oldID}/${newID}/"

    git remote set-url origin `git config --get remote.origin.url | sed "${opt}"`
}
