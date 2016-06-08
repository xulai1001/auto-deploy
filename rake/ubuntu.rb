#!/usr/bin/env ruby
#encoding:utf-8
$: << "."
require "utils"

module Ubuntu
    extend Utils
    
    # register to utils
    ID = :ubuntu
    Utils.distro_module self

    GRUB_PATH = "/boot/grub"
    GRUB_CMD = "grub-mkconfig"
    GRUB_CFG = "/boot/grub/grub.cfg"
  
    module_function
    def update_grub
        puts "重新生成grub设置 ...".green.bold
        cs "#{GRUB_CMD} -o #{GRUB_CFG}"
        with_cmdsu { edit_config GRUB_CFG }
    end

    def update_ramdisk
        puts "更新initrd ..."
        kernel=`uname -r`
        cs "mkinitramfs -o initrd.img-#{kernel}"
    end

    def add_to_rclocal(str)
        must_root
        puts "添加启动项: #{str}"
        
        pass_if_dry do
            with_cmdsu { insert_config "/etc/rc.local", :before, /^exit 0/, str }
        end
    end
    
    def install_package(packages)
        cs "apt-get install #{packages[ID]}" 
    end

end

if __FILE__ == $0
    Utils.dry_run do
        Ubuntu.update_grub
        Ubuntu.update_ramdisk
        Ubuntu.add_to_rclocal("1111111")
        Ubuntu.add_to_rclocal("2222222")
    end
end

