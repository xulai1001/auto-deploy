#!/bin/bash
# include check
check_bootstrap
if [ $? -ne 0 ]; then
    echo "载入bootstrap.sh ..."
    . bootstrap.sh
fi

set_repo()
{
    echo "设置fedora软件源..."
    wget http://lug.ustc.edu.cn/wiki/_export/code/mirrors/help/fedora?codeblock=0 -O fedora.repo
    sudo rm /etc/yum.repos.d/*
    sudo cp fedora.repo /etc/yum.repos.d/fedora.repo
    sudo dnf makecache
}

set_ruby()
{
    # use rvm to install from ruby.taobao.org
    # fixme: need sudo or not?
    sudo gem sources --add https://ruby.taobao.org/ --remove https://rubygems.org/
    sudo gem sources -l
    sudo gem install require_all term-ansicolor

    # just also put python init here.
    sudo pip install --upgrade pip
}

download()
{
    cd ~
    if [ -d .autodep ]; then
        cd .autodep
        git pull
    else
        rm -rf .autodep
        mkdir ~/.autodep
        cd ~/.autodep
        echo "进入目录" `pwd`
        git clone https://github.com/xulai1001/auto-deploy .
        while [ $? -ne 0 ]; do
            rm -rf *
            git clone https://github.com/xulai1001/auto-deploy .
        done
    fi
#    cd -
}

confirm "设置软件源 /etc/yum.repos.d/"
if [ $? -eq 0 ]; then set_repo; fi

confirm "安装基础依赖包"
if [ $? -eq 0 ]; then 
    # keep trying
    packages="\"@Development Tools\" \"@xfce\" ruby tigervnc-server vim"
    sudo dnf install -y $packages
    while [ $? -ne 0 ]; do
        sudo dnf install -y $packages
    done
fi

confirm "设置ruby软件源"
if [ $? -eq 0 ]; then set_ruby; fi

confirm "下载auto-deploy..."
if [ $? -eq 0 ]; then keep_trying download; fi

# misc operations
sudo systemctl enable sshd.service

cd ~/.autodep
if [ ! -d packages ]; then mkdir packages src; fi
echo "auto-deploy 已经安装在 ~/.autodep. 进入该目录进行后续操作. gg gl!"

confirm "是否要更新系统?"
if [ $? -eq 0 ]; then keep_trying "sudo dnf update -y"; fi
