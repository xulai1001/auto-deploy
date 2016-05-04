#!/bin/bash
# common utilities for bootstrap shell scripts.

to_lower()
{
    echo $1 | tr "[:upper:]" "[:lower:]"
}

confirm_and_run()
{
    echo "命令: ${*}"
    read -n1 -p "回车:执行，N/A/Ctrl-C:取消，S-跳过" ch
    echo
    ch=$(to_lower $ch)
    # echo $ch $1
    if [[ $ch == n || $ch == a ]]; then
        echo "取消操作."
        echo "----"
        exit 130
    fi
    if [[ $ch == s ]]; then
        echo "跳过命令."
        echo "----"
        return 1
    else
        eval $*
        echo "----"
    fi
}

# unit test
utest()
{
    to_lower Ab123BA
    confirm_and_run ls -l /var/run
}
# utest
