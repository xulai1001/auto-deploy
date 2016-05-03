#!/bin/bash
echo "设置fedora软件源..."
wget http://lug.ustc.edu.cn/wiki/_export/code/mirrors/help/fedora?codeblock=0 -O fedora.repo
sudo rm /etc/yum.repos.d/*
sudo cp fedora.repo /etc/yum.repos.d/fedora.repo
sudo dnf makecache

