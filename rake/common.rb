#encoding:utf-8
$: << "." << "./rake"
require "term/ansicolor"
require "mytask"
require "utils"

# 定义基本操作类型
class Common < MyTask

    PACKAGES = { :ubuntu => """
default-jdk vncviewer kvm 
automake autogen flex bison libvirt-dev python-dev r-base r-base-dev nodejs npm php-fpm emacs gparted traceroute bridge-utils""",
                 :fedora => ""
               }
end
