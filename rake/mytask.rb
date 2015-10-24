#encoding:utf-8
$: << "." << "./rake"
$:.uniq!

require "utils"
include Utils

# 定义基本操作类型
class MyTask
    include Singleton
    # apt-get 下载依赖软件包，需要管理权限
    
    PACKAGES = "";
    def apt
        puts "apt-get安装#{self.class}的依赖包...".green
        Utils.cmdsu "apt-get install #{self.class::PACKAGES}"
    end
    alias package apt
    
    # 下载源码，放在src文件夹中
    def source
        Utils.must_not_root
        puts "下载#{self.class}的源码...".green
    end
    
    # 配置源码并编译
    def compile
        Utils.must_not_root
        puts "配置并编译#{self.class}...".green
    end
    
    # 安装，需要管理权限
    def install
        puts "安装#{self.class}...".green
    end

    def help
        puts [self.class, "动作："].join("\n")
        (self.methods - Object.methods - [:_dump, :help, :all]).each do |sym|
            puts "------------ rake #{self.class}:#{sym} -----------".yellow.bold
            send sym
        end
    end
    
    # 进行所有操作
    def all
        apt
        source
        compile
        install
    end
end
