#!/bin/bash
echo "安装基础依赖包"
sudo dnf install '@Development Tools'
echo "运行ruby-init.sh"
./ruby-init.sh

