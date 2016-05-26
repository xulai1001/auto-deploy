#encoding:utf-8
$: << "." << "./rake"
require "mytask"
require "utils"

# 定义基本操作类型
class Xen < MyTask

    PACKAGES = {
    :ubuntu => """
python-dev gcc-multilib bin86 iasl bcc uuid-dev ncurses-dev libglib2.0-dev libaio-dev liblzma-dev libssl-dev libyajl-dev seabios libpixman-1-dev libtool zlib1g-dev texinfo
""",
    :fedora => """
python-devel acpica-tools uuid-devel ncurses-devel glib2-devel libaio-devel yajl-devel seabios-bin pixman-devel libtool zlib-devel lzma-sdk-devel texinfo bridge-utils gcc-c++ pcre-devel dev86 glibc-devel.i686 libgcc.i686 SDL-devel libgnomeui-devel xen-devel patch
"""
    }
    
    VER = "4.6.1"
    VE  = VER[/\d+\.\d+/]
    V   = VER[/\d+/]
    PKGNAME = "xen-#{VER}"
    CONFIG = <<EOL
--disable-blktap1 --disable-qemu-traditional --disable-rombios --with-system-seabios=/usr/share/seabios/bios-256k.bin --with-extra-qemu-configure-args="--enable-spice --enable-usb-redir"
EOL

    # 下载源码，放在src文件夹中
    def source
        super
        pname = "#{PKGNAME}.tar.gz"
        
        Dir.chdir "packages" do
        begin
            ret = download_and_verify "http://bits.xensource.com/oss-xen/release/#{VER}/#{PKGNAME}.tar.gz",
                        			  "http://bits.xensource.com/oss-xen/release/#{VER}/#{PKGNAME}.tar.gz.sig",
                        			  method:"gpg", keyserver:"pgp.mit.edu", key:"57e82bd9"
            raise RuntimeError if not ret and not dry?
        rescue RuntimeError
            puts "验证错误，重新下载xen源码".red.bold
            File.delete pname if FileTest.exists? pname
            retry
        end
        end
        
        Dir.chdir "src" do
            puts "解压至 src/#{PKGNAME} ...".green.bold
            unpack "../packages/#{PKGNAME}.tar.gz"
            
            # patch
            puts "应用补丁 misc/block-log.patch ...".green.bold
            c "patch -d #{PKGNAME} -p1 < ../misc/block-log.patch"
        end
            
    end
    
    # 配置源码并编译
    def compile
        super
        Dir.chdir "src/#{PKGNAME}" do
            puts "编译xen...".green.bold
            cmd "./configure #{CONFIG.tr("\n", "")}",
                "make -j8 xen",
                "make -j8 tools",
                "make -j8 stubdom"
        end
    end
    
    # 安装，需要管理权限
    def install
        must_root
        super
        Dir.chdir "src/#{PKGNAME}" do
            cmdsu "make install"
        end
        
        Dir.chdir "/boot" do
            cmdsu "rm xen.gz xen-#{V}.gz xen-#{VE}.gz"
            Utils.distro.update_grub
            Utils.distro.update_ramdisk
            puts "添加运行库引用 ...".green.bold
            cmdsu "echo /usr/local/lib > /etc/ld.so.conf.d/local.conf"
            cmdsu "ldconfig"
        end
        
        Dir.chdir "/etc" do
            puts "设置xencommons启动项".green.bold
            Utils.distro.add_to_rclocal "service xencommons start"
           # Utils.distro.add_to_rclocal "export PATH=$PATH:/usr/local/sbin"
        end
        puts "Xen安装完成，需要重新启动......".green.bold

        # todo: 加入网络设置脚本
    end
end
