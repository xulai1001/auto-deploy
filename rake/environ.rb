#!/usr/bin/env ruby
#encoding:utf-8

require "pp"

env = {
    fedora: {
        grubdir: "/boot/grub2",
        grubcfg_cmd: "grub2-mkconfig",
        initramfs_cmd: "dracut --force"
    },
    ubuntu: {
        grubdir: "/boot/grub",
        grubcfg_cmd: "grub-mkconfig",
        initramfs_cmd: "mkinitramfs"
    }
}

if __FILE__ == $0
    require "pp"
    pp env
end

