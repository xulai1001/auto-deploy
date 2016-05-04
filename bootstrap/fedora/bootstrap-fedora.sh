#!/bin/bash
# include
. ../common.sh
# utest

echo "设置软件源 /etc/yum.repos.d/"
confirm_and_run ./set-repo.sh

echo "安装基础依赖包"
confirm_and_run "sudo dnf install \"@Development Tools\" ruby"

echo "更新系统"
confirm_and_run sudo dnf update

echo "设置ruby软件源"
confirm_and_run ./set-ruby.sh

echo "下载auto-deploy..."
confirm_and_run ./download.sh
