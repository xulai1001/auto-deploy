#!/bin/bash
echo "更新系统..."
sudo dnf update
echo "安装基础应用..."
sudo dnf install '@Development Tools' -y


