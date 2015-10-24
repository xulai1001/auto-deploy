#encoding:utf-8
$: << "." << "./rake"
$:.uniq!
require "mytask"

# 定义基本操作类型
class Spark < MyTask
    
    PACKAGES = "scala";
    VER = "1.5.1";
    PKGNAME = "spark-#{VER}.tgz";
    
    # 下载源码，放在src文件夹中
    def source
        super
        Dir.chdir "packages" do
            download "http://apache.dataguru.cn/spark/spark-#{VER}/#{PKGNAME}"
        end
    end
    
    # 配置源码并编译
    def compile
        super
        Dir.chdir "src" do
            unpack "../packages/#{PKGNAME}"
        end
    end
    
    # 安装，需要管理权限
    def install
        super

    end
end
