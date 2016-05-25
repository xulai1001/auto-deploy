#encoding:utf-8
require "term/ansicolor"
require "require_all"
require_rel "rake/*.rb"

$dry ||= 0

include Utils

Rake::TaskManager.record_task_metadata = true

# find all methods of MyTask ( _dump is no use) as target list
$target_list = MyTask.instance.methods - MyTask.methods - [:_dump, :help]

# find all subclasses of MyTask as supported apps
$app_list = ObjectSpace.each_object(Class).select {|klass| klass < MyTask }

def tag(x); x.to_s.downcase.to_sym; end

def help_text
    (["可部署的应用："] + $app_list.map{|x|tag(x)} +
     ["动作："] + $target_list + 
     ["例子：rake xen:all, rake common:apt, rake common"] + 
     ["      rake all:xen, rake source:xen, rake all"]).join("\n")
end

# tasks for each app
# example: rake xen:all, rake common:apt, rake common
$app_list.each do |k|
    namespace tag(k) do
        targets = k.instance.methods - k.methods - [:_dump, :help]
        targets.each do |m|
            mytask tag(m) do
                k.instance.send m
            end
        end
        task :help do
            Utils.dry_run { k.instance.help }
        end
    end
    mytask tag(k) do
        k.instance.send :all
    end
end

# tasks for each target (reverse)
# example: rake all:xen, rake source:xen, rake all
$target_list.each do |m|
    namespace tag(m) do
        $app_list.each do |k|
            mytask tag(k) do
                k.instance.send m
            end
        end
    end
    mytask tag(m) do
        $app_list.each do |k|
            k.instance.send m
        end
    end
end

namespace :help do
    $app_list.each do |k|
        task tag(k) do
	    Utils.dry_run { k.instance.help }
        end
    end
end

# -------------------------

task :help do
    puts help_text
end

task default:[:help]

