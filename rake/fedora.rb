#!/usr/bin/env ruby
#encoding:utf-8
$: << "."
require "utils"

module Fedora
    extend Utils
    
    # register to utils
    ID = "fedora"
    Utils.distro_module self

    GRUB_PATH = "/boot/grub2"
    GRUB_CMD = "grub2-mkconfig"
    GRUB_CFG = "/boot/grub2/grub.cfg"
  
    module_function
    def update_grub
        cs "#{GRUB_CMD} -o #{GRUB_CFG}"
        puts "编辑grub.cfg ..."
        cs "gedit #{GRUB_CFG}"
    end

    def update_ramdisk
        cs "dracut --force"
    end

    def setup_rclocal
        must_root

        puts "创建rc.local ..."
        Dir.chdir "/etc/rc.d" do 
            pass_if_dry do
                if not FileTest.exists? "rc.local"
                    File.open "rc.local", "w+" do |f|
                        f.puts "#!/bin/bash"
                    end
                    cs "chmod +x rc.local"
                end
            end
        end
        Dir.chdir "/usr/lib/systemd/system" do
            pass_if_dry do
                conf = File.read "rc-local.service"
                if conf.lines.none? {|line| line["[Install]"]}
                    append_config "rc-local.service", <<EOL
[Install]
WantedBy=multi-user.target
EOL
                end
            end
        end
            
        cs "systemctl enable rc-local.service"
    end 

    def add_to_rclocal(str)
        must_root
        puts "添加启动项: #{str}"
        
        pass_if_dry do
            insert_config "/etc/rc.d/rc.local", :before, /^exit 0/, str
        end
    end 

end

if __FILE__ == $0
    Utils.dry_run do
        Fedora.update_grub
        Fedora.update_ramdisk
        Fedora.setup_rclocal
        Fedora.append_rclocal("1111111")
        Fedora.append_rclocal("2222222")
    end
end

