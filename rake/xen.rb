#encoding:utf-8
$: << "." << "./rake"
require "mytask"

# 定义基本操作类型
class Xen < MyTask

    PACKAGES = <<EOL
python-dev gcc-multilib bin86 iasl bcc uuid-dev ncurses-dev libglib2.0-dev libaio-dev liblzma-dev libssl-dev libyajl-dev seabios libpixman-1-dev libtool zlib1g-dev texinfo
EOL
    VER = "4.5.0"
    VE  = VER[/\d+\.\d+/]
    V   = VER[/\d+/]
    PKGNAME = "xen-#{VER}"
    CONFIG = <<EOL
--disable-blktap1 --disable-qemu-traditional --disable-rombios --with-system-seabios=/usr/share/seabios/bios-256k.bin --with-extra-qemu-configure-args="--enable-spice --enable-usb-redir"
EOL

    # 下载源码，放在src文件夹中
    def source
        super
        Dir.chdir "packages" do
            ret = download_and_verify "http://bits.xensource.com/oss-xen/release/#{VER}/#{PKGNAME}.tar.gz",
                        "http://bits.xensource.com/oss-xen/release/#{VER}/#{PKGNAME}.tar.gz.sig",
                        :verify, "pgp.mit.edu", "57e82bd9"
            if !ret
                puts "验证错误，重新下载xen源码".red.bold
                File.delete "#{PKGNAME}.tar.gz"
                ret = download_and_verify "http://bits.xensource.com/oss-xen/release/#{VER}/#{PKGNAME}.tar.gz",
                                        "http://bits.xensource.com/oss-xen/release/#{VER}/#{PKGNAME}.tar.gz.sig",
                                        :verify, "pgp.mit.edu", "57e82bd9"
     		    end
        end
    end
    
    # 配置源码并编译
    def compile
        super
        Dir.chdir "src" do
            unpack "../packages/#{PKGNAME}.tar.gz"

            Dir.chdir PKGNAME do
                puts "编译xen...".green.bold
                cmd "./configure #{CONFIG.tr("\n", "")}",
                    "make -j8 xen",
                    "make -j8 tools",
                    "make -j8 stubdom"
            end
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
            Dir.chdir "grub" do
                cmdsu "grub-mkconfig -o grub.cfg"
                puts "开启gedit，手动修改grub.cfg...".green.bold
                cmdsu "gedit grub.cfg"
                puts "添加运行库引用...".green.bold
                cmdsu "ldconfig"
            end        
        end
        
        Dir.chdir "/etc" do
            puts "设置xencommons启动项".green.bold
            cmdline = "service xencommons start"

            rc = File.read "rc.local"
            rc.gsub! cmdline, ""
            rc.gsub!(/^exit 0/){cmdline + "\nexit 0" }
            File.open "rc.local", "w+" do |f|
                f.write rc
            end        
        end
        puts "Xen安装完成，需要重新启动......".green.bold

        # todo: 加入网络设置脚本
    end
end
