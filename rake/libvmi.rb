#encoding:utf-8
$: << "." << "./rake"
$:.uniq!
require "mytask"

# 定义基本操作类型
class LibVMI < MyTask
    
    PACKAGES = "libtool zlib1g-dev texinfo libjansson-dev libfuse-dev automake autogen flex bison";
    
    # 下载源码，放在src文件夹中
    def source
        super
        Dir.chdir "src" do
            if !FileTest.exist? "libvmi"
                cmd "git clone https://github.com/libvmi/libvmi"
            end
        end
    end
    
    # 配置源码并编译
    def compile
        super
        Dir.chdir "src/libvmi" do
            cmd "git pull",
                "./autogen.sh",
                "./configure --enable-xen-events --enable-shm-snapshot",
                "make"
        end
    end
    
    # 安装，需要管理权限
    def install
        super
        Dir.chdir "src/libvmi" do
            cmdsu "make install"
        end
    end
end
