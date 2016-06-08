#!/bin/bash
# include check
check_bootstrap
if [ $? -ne 0 ]; then
    echo "载入bootstrap.sh ..."
    . bootstrap.sh
fi

set_repo()
{
    echo "设置ubuntu软件源(hust)..."
    wget http://codepad.org/ZnBWV1kO/raw.txt -O ubuntu.repo
    sudo cp ubuntu.repo /etc/apt/sources.list
    sudo apt-get update
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

confirm "设置软件源"
if [ $? -eq 0 ]; then set_repo; fi

confirm "安装基础依赖包"
if [ $? -eq 0 ]; then 
    # keep trying
    packages="vim git openssh-server ruby python-pip"

    sudo apt-get install -y $packages
    while [ $? -ne 0 ]; do
        sudo apt-get install -y $packages
    done
fi

confirm "更新系统"
if [ $? -eq 0 ]; then keep_trying "sudo apt-get upgrade"; fi

confirm "设置ruby软件源"
if [ $? -eq 0 ]; then set_ruby; fi

confirm "下载auto-deploy..."
if [ $? -eq 0 ]; then keep_trying download; fi

# misc operations

cd ~/.autodep
if [ ! -d packages ]; then mkdir packages src; fi
echo "auto-deploy 已经安装在 ~/.autodep. 进入该目录进行后续操作. gg gl!"
