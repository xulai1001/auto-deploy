#encoding:utf-8
require "term/ansicolor"

class String
    include Term::ANSIColor
end

class Color
    extend Term::ANSIColor
end

class Dir
    @@cdstack = [`pwd`]
    
    class << self
        alias old_chdir chdir
        def chdir(str=nil, &block)
            if block
                @@cdstack.push str
                puts "[#{@@cdstack.size}] 进入目录 #{str}".blue.bold
                if !$dry
                    old_chdir str, &block
                else
                    yield block
                end
                puts "[#{@@cdstack.size}] 离开目录 #{str}".blue.bold
                @@cdstack.pop
            else
                puts "[#{@@cdstack.size}] 更改目录 #{str}".blue.bold
                @@cdstack[-1] = str
                old_chdir str if !$dry
            end
        end
    end
end

$cmdsu = false

module Utils

    module_function

#----------------------------------
# user manage

    def username
        `whoami`.chomp
    end
    
    def logname
        `logname`.chomp
    end
    
    def root?
        username == "root"
    end
    
    def must_root
        if !root?
            puts "操作需要root权限，请使用sudo rake".red.bold
            raise if not $dry
        end
        true
    end

    def must_not_root
        if logname == "root"
            puts "操作无法在root用户(su)下执行，请使用sudo".red.bold
            raise if not $dry
        end
        true
    end

#----------------------------------
# invoke shell commands

    # unprivileged cmd
    def cmd(*args)
        if $cmdsu
            return cmdsu(*args)
        else
            args.each do |c|
                c.tr! "\n", ""
                if root?
    #                cmdline = "su -c '" + c + "' - #{logname}"
                    cmdline = "su -c '" + c + "' #{logname}"
                    puts cmdline.blue.bold
                    ret = system cmdline if !$dry
                else
                    puts c.blue.bold
                    if !$dry
                        system c
                        raise "#{cmdline} -> #{$?}".red.bold if !$?.success?
                    end
                end
            end
        end
    end
    
    # privileged cmd
    def cmdsu(*args)
        args.each do |c|
            c.tr! "\n", ""
            if root?
                puts c.blue.bold
                system c if !$dry
            else
                cmdline = "sudo " + c
                puts "[需要系统权限] #{cmdline}".blue.bold
                if !$dry
                    system cmdline
                    raise "#{cmdline} -> #{$?}".red.bold if !$?.success?
                end
            end
        end
    end

    def with_cmdsu
        $cmdsu = true
        yield
        $cmdsu = false
    end

#----------------------------------
# file ops

    def exists?(fname)
        ret = FileTest.exists? fname
        p "文件 #{fname} 已存在." if ret
        ret
    end
    
    def local_fname(url); return url[/\/[^\/]*$/][1..-1]; end

#----------------------------------
# os distro detection

    # get info hash from /etc/os-release, @stackoverflow #32670458
    def distro_info
        @distro_info ||= File.read("/etc/os-release").lines.map {|l|
            l.chomp.split("=").tap {|x| x[0].downcase!; x[1].tr!("\"", "") }
        }.to_h
        @distro_info
    end
#   puts distro_info

#----------------------------------
# confirm helper

    def describe_task(tsk)
        puts ("-- " + (tsk.comment || "") + " --").green.bold
    end
    
    def dry_run(*args)
        $dry = true
        yield *args
        $dry = false
    end
    
    def confirm
        STDOUT.write "输入任意键执行，S - 跳过本步骤, N/X - 中止操作："; s = STDIN.gets.chomp
        case s.downcase
            when "s"
                return "skip"
            when "x", "n"
                return "cancel"
            else return true
        end
    end
    
    def confirm_and_run(*args, &block)
        dry_run *args, &block
        case confirm
            when true   # run
                return block.call t, *a
            when "skip"
                puts "跳过本步骤.".yellow.bold
                return "skip"
            when "cancel"
                puts "操作取消".red.bold
                return "cancel"
        end
    end        


#----------------------------------
# actions

    def download(url)
		puts "下载 #{url} -> #{local_fname(url)}".green.bold
		cmd "wget -c #{url}"
    end

    def verify(filename, sigfile, **kwargs)
        puts "验证 #{filename} (#{kwargs[:method]})".green.bold
        case kwargs[:method].to_sym
            when :gpg   # args: method=>:gpg, keyserver, key
                cmd "gpg --keyserver #{kwargs[:keyserver]} --recv-keys #{kwargs[:key]}"
                cmd "gpg --verify #{sigfile} #{filename}"
            when :sha1  # args: method=>:sha1
                cmd "sha1sum -c #{sigfile}"
        end
    end

    # if no need to verify, use download directly.
    def download_and_verify(url, sig_url, **kwargs)
        fname = local_fname(url)
        signame = local_fname(sig_url)

        download(url) if !exists?(fname)        
        download(sig_url) if !exists?(signame)
        verify fname, signame, **kwargs
	 end

    def unpack(filename, mode="xzf")
		puts "解压 #{filename}...".green.bold

		cmd "tar #{mode} #{filename}"
    end

#----------------------------------
# task wrapper

    def mytask(*args, &block)
        task *args do |t, *a|
#            describe_task t
            puts "命令行：".blue.bold
            confirm_and_run t, *a, &block
        end
    end
        
end

