#encoding:utf-8
require "term/ansicolor"

class String
    include Term::ANSIColor
end

class Color
    extend Term::ANSIColor
end

class Dir
    class << self
        alias old_chdir chdir
        def chdir(str=nil, &block)
            @cdcount ||= 0
            if block
                @cdcount += 1
                puts "[#{@cdcount}] 进入目录 #{str}".blue.bold
                if !$dry
                    old_chdir str, &block
                else
                    yield block
                end
                puts "[#{@cdcount}] 离开目录 #{str}".blue.bold
                @cdcount -= 1
            else
                puts "[#{@cdcount}] 更改目录 #{str}".blue.bold
                old_chdir str if !$dry
            end
        end
    end
end

$cmdsu = false

module Utils

    module_function

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
            raise "操作需要root权限，请使用sudo rake".red.bold
        end
    end

    def must_not_root
        raise "操作无法在root用户(su)下执行，请使用sudo".red.bold if logname == "root"
        true
    end

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

	 def exists?(fname)
		FileTest.exists? fname
    end

	 def download(url)
      fname = url[/\/[^\/]*$/][1..-1]
		puts "downloading #{url} -> #{fname}".green.bold

		cmd "wget -c #{url}"
    end

	 def verify(filename, sigfile, keyserver, key)
    		puts "verify #{filename}".green.bold

    		cmd "gpg --keyserver #{keyserver} --recv-keys #{key}"
      cmd "gpg --verify #{sigfile} #{filename}"
    end

    def sha1(filename, sigfile)
        puts "verify #{filename}".green.bold
        cmd "sha1sum -c #{sigfile}"
    end

    def download_and_verify(url, sig_url, sym, *args)
      fname = url[/\/[^\/]*$/][1..-1]
      signame = sig_url[/\/[^\/]*$/][1..-1]

    		download(url) if !exists?(fname)
    		download(sig_url) if !exists?(signame)
    		return send(sym, fname, signame, *args)
	 end

    def unpack(filename, mode="xzf")
		puts "unpacking #{filename}...".green.bold

		cmd "tar #{mode} #{filename}"
    end

    def describe_task(tsk)
        puts ("-- " + (tsk.comment || "") + " --").green.bold
    end

    def confirm
        STDOUT.write "输入任意键执行，N/Q - 取消："; s = STDIN.gets.chomp
        return !(["N", "Q"].include?(s.upcase))
    end

    def mytask(*args)
        task *args do |t, *a|
#            describe_task t
            puts "命令行：".blue.bold
            $dry = true
            begin
                yield t, *a
            rescue => e
                puts e
            end
            if confirm
                $dry = false
                yield t, *a
            else
                puts "操作取消".red.bold
            end
        end
    end
        
end

