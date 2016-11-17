#!/bin/bash
# find stdin
exec 3<&1

wget_args="-t0 --retry-connrefused -w3"
raw_url=https://raw.githubusercontent.com/xulai1001/auto-deploy/master1

# utilities for bootstrap shell scripts.
to_lower()
{
    echo $1 | tr "[:upper:]" "[:lower:]"
}

confirm()
{
    echo "确认执行:" $*
    read -u3 -n1 -p "回车:执行，N/A/Ctrl-C:取消，S-跳过" ch
    echo
    ch=$(to_lower $ch)

    if [[ $ch == n || $ch == a ]]; then
        echo "取消操作."
        echo "----"
        return 130
    fi
    if [[ $ch == s ]]; then
        echo "跳过命令."
        echo "----"
        return 1
    else
        return 0
    fi
}

confirm_and_run()
{   
    confirm $*
    res=$?
#    echo $res
    if [ $res -eq 130 ]; then exit 130; fi
    if [ $res -eq 0 ]; then eval $*; fi
}

keep_trying()
{
    $*
    while [ $? -ne 0 ]; do
        echo "--- retrying --- "
        $*
    done
}

# unit test
check_bootstrap()
{
    # set stdin same to stdout (pts)
    exec 3<&1
    echo "* bootstrap 已经载入."
    return 0
}

utest()
{
    check_bootstrap
    to_lower Ab123BA
    confirm_and_run ls -l /var/run
}

distro()
{
    cat /etc/os-release | sed -nr s/^ID=\(.*\)/\\1/p
}

version_id()
{
    cat /etc/os-release | sed -nr s/^VERSION_ID=\(.*\)/\\1/p
}

# install script
install()
{
    mkdir /tmp/autodep
    cd /tmp/autodep
    rm -f *
    echo "进入目录" `pwd`
    # Linux distrib detection
    dist=`distro`
    ver=`version_id`
    echo "检测Linux版本..." $dist $ver
    
    fname=${dist}.sh
    echo "使用${fname} ..."
    wget $wget_args ${raw_url}/bootstrap/${fname}
    chmod 777 $fname
    echo "----"
    . $fname $ver
    cd ~/.autodep
}

if [ ! $1 ]; then
    echo "使用 ./bootstrap.sh install 进行安装."
else
    $1
fi
