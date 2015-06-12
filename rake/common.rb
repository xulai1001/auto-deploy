#encoding:utf-8
$: << "." << "./rake"
require "term/ansicolor"
require "mytask"
require "utils"

# 定义基本操作类型
class Common < MyTask

    PACKAGES = <<EOL
vim git gcc g++ default-jdk openssh-server curl build-essential firefox adobe-flashplugin vncviewer kvm 
automake autogen flex bison libvirt-dev
EOL
    
end
