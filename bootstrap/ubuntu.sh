#!/bin/bash
# include check
check_bootstrap
if [ $? -ne 0 ]; then
    echo "载入bootstrap.sh ..."
    . bootstrap.sh
fi

set_repo()
{
    url="mirrors.aliyun.com"
    if [ $1 = "16.04" ]; then
        ver="xenial"
    else
        if [ $1 = "14.04" ]; then ver="trusty"; fi
    fi
    echo "设置ubuntu软件源..." $1 $ver
    wget http://raw.githubusercontent.com/xulai1001/auto-deploy/master1/bootstrap/ubuntu-template.repo -O ubuntu.repo
#    sed -ie "s/{url}/${url}/;s/{version}/${ver}/" ubuntu.repo
    sed -ie "s/{version}/${ver}/" ubuntu.repo
    sudo cp ubuntu.repo /etc/apt/sources.list
    cat /etc/apt/sources.list
    sudo apt-get -y update
}

set_ruby()
{
    # use rvm to install from ruby-china
    # fixme: need sudo or not?
    sudo gem sources --add https://gems.ruby-china.org/ --remove https://rubygems.org/
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
if [ $? -eq 0 ]; then set_repo $1; fi

confirm "安装基础依赖包"
if [ $? -eq 0 ]; then 
    # keep trying
    packages="vim git openssh-server ruby python-pip tightvncserver xrdp bridge-utils ntp ntpdate"

    sudo apt-get install -y $packages
    while [ $? -ne 0 ]; do
        sudo apt-get install -y $packages
    done
#    echo "xfce4-session" > ~/.xsession
fi

confirm "设置ruby软件源"
if [ $? -eq 0 ]; then set_ruby; fi

confirm "下载auto-deploy..."
if [ $? -eq 0 ]; then keep_trying download; fi

# misc operations

cd ~/.autodep
if [ ! -d packages ]; then mkdir packages src; fi
echo "auto-deploy 已经安装在 ~/.autodep. 进入该目录进行后续操作. gg gl!"

confirm "是否更新系统?"
if [ $? -eq 0 ]; then keep_trying "sudo apt-get -y upgrade"; fi

