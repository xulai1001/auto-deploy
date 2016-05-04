#!/bin/bash

echo "检测Linux版本..."
# Linux distrib detection
if [ -f /etc/redhat-release ]; then
    # redhat
    rh_release=`cat /etc/redhat-release`
    echo "检测到redhat: " $rh_release
    if [[ $rh_release == Fedora* ]]; then
        # fedora
        echo "检测到 Fedora 发行版, 使用fedora/bootstrap-fedora.sh"
        echo "----"
        cd fedora
        ./bootstrap-fedora.sh
    fi
fi

