#encoding:utf-8
$: << "." << "./rake"
require "term/ansicolor"
require "mytask"
require "utils"

# 定义基本操作类型
class Common < MyTask

    PACKAGES = <<EOL
vim git gcc g++ default-jdk openssh-server curl build-essential firefox vncviewer kvm 
automake autogen flex bison libvirt-dev python-dev r-base r-base-dev nodejs npm php5-fpm emacs gparted traceroute bridge-utils
EOL
    
end
