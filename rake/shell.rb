
#encoding:utf-8
$: << "." << "./rake"
require "mytask"
require "utils"

class Shell < MyTask
    extend Utils
    
    ALL = [:simple]
    HELP = [:simple, :zsh, :zshconfig]
    PACKAGES = { :ubuntu => "zsh", :fedora => "zsh" }
    
    def simple
        # echo export PS1=\"\\n\${PS1}\" | tee -a .bashrc
        Dir.chdir ENV["HOME"] do
            Utils.append_config ".bashrc", 'export PS1="\n${PS1}"'
        end
    end
    
    def zsh
        package
        c "pip install powerline-status",
          "chsh -s /bin/zsh"
        puts "请重新登陆，并在zsh下运行rake shell:zshconfig"
    end
    
    def zshconfig
        puts "安装命令行字体 ..."
        Dir.chdir "src" do
            c "git clone https://github.com/powerline/fonts"
            Dir.chdir "fonts" do
                c "./install.sh"
            end
        end
        puts "安装 oh-my-zsh ..."
        c 'sh -c "$(wget https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O -)"'
        Dir.chdir ENV["HOME"] do
            c 'sed -ir "s/^ZSH_THEME=.*/ZSH_THEME=\"agnoster\"/" .zshrc'
        end
        puts "在终端配置中，手动将控制台字体改为其中之一: "
        puts "meslo lg s dz regular/12".yellow.bold
        puts "ubuntu mono derivative powerline regular/13".yellow.bold
        puts "开启新的终端窗口完成安装."
    end
end
