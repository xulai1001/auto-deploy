#encoding:utf-8
$: << "." << "./rake"
$:.uniq!
require "mytask"

# 定义基本操作类型
class Ambari < MyTask
    
    PACKAGES = "ambari-agent ntp";
    RELEASE = "ubuntu14";

    def add_repo
        Dir.chdir "/etc/apt/sources.list.d" do
           with_cmdsu { download "http://public-repo-1.hortonworks.com/ambari/#{RELEASE}/2.x/updates/2.1.2/ambari.list" }
        end
        cmdsu "apt-key adv --recv-keys --keyserver keyserver.ubuntu.com B9733A7A07513CAD"
        cmdsu "apt-get update"
    end

    def server
      cmdsu "apt-get install ambari-server"
    end

    def start
        cmdsu "ambari-server setup"
        cmd "ambari-server start"
    end

    def all
        add_repo
        super
        start
    end
end
