
#encoding:utf-8
$: << "." << "./rake"
require "mytask"
require "utils"

class Vim < MyTask
    extend Utils
    
    ALL = [:simple]
    HELP = [:simple, :spf13]
    PACKAGES = { :ubuntu => "vim", :fedora => "vim" }
    
    def simple
         package
         c "cp misc/simple.vimrc ~/.vimrc"
    end
    
    def spf13
        Dir.chdir "src" do
            c "git clone https://github.com/spf13/spf13-vim"
            Dir.chdir "spf13-vim" do
                c "./bootstrap.sh"
            end
        end
    end
end
