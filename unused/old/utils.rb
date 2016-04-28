#encoding:utf-8

require "term/ansicolor"

class String
    include Term::ANSIColor
end

class Color
    extend Term::ANSIColor
end

module Utils
    def root?
        `whoami`.chomp == "root"
    end

    def must_root
        if !root?
            raise "操作需要root权限，请使用sudo rake".red.bold
        end
    end

    def must_not_root
        if root?
            raise "操作不需要root权限，请使用rake".red.bold
        end
    end

    def run_cmd(*cmd)
        ret = nil
        cmd.each do |c|
            puts c.blue.bold
            ret = system c if !$dry
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
