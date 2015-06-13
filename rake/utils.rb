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
                old_chdir str, &block
                puts "[#{@cdcount}] 离开目录 #{str}".blue.bold
                @cdcount -= 1
            else
                puts "[#{@cdcount}] 更改目录 #{str}".blue.bold
                old_chdir str
            end
        end
    end
end

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
        raise "操作无法在root用户下执行，请使用sudo".red.bold if logname == "root"
        true
    end
#
#    def run_cmd(*cmd)
#        ret = nil
#        cmd.each do |c|
#            puts c.blue.bold
#            ret = system c if !$dry
#        end
#        ret
#    end

    # unprivileged cmd
    def cmd(*args)
        ret = nil
        args.each do |c|
            c.tr! "\n", ""
            if root?
                cmdline = "su -c '" + c + "' - #{logname}"
                puts cmdline.blue.bold
                ret = system cmdline if !$dry
            else
                puts c.blue.bold
                ret = system c if !$dry
            end
#            break if ret
        end
        ret
    end
    
    # privileged cmd
    def cmdsu(*args)
        ret = nil
        args.each do |c|
            c.tr! "\n", ""
            if root?
                puts c.blue.bold
                ret = system c if !$dry
            else
                cmdline = "sudo " + c
                puts "[需要系统权限] #{cmdline}".blue.bold
                ret = system cmdline if !$dry
            end
#            break if ret
        end
        ret
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

