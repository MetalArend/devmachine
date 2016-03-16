# todo https://github.com/ailispaw/rancheros-lite
# https://www.snip2code.com/Snippet/374178/Vagrantfile-including-patches-for-Ranche

# TODO composer create-project phpmyadmin/phpmyadmin --repository-url=https://www.phpmyadmin.net/packages.json
# docker exec -it $(docker inspect --format="{{.Id}}" "$(docker-compose ps -q "php")") /bin/bash

# $stdout.sync = true

# Check vagrant version
Vagrant.require_version '>= 1.6.0'

# Load dependencies
require 'rbconfig'
require 'yaml'
require 'fileutils'
require_relative 'core/vagrant/plugins/vagrant_rancheros_guest_plugin.rb'

# Detect platform
platforms = [:windows, :mac, :linux, :unix, :unknown, :all]
platform ||= (
    host_os = RbConfig::CONFIG['host_os']
    case
    when ENV['OS'] == 'Windows_NT'
        :windows
    when host_os =~ /mswin|msys|mingw|cygwin|bccwin|wince|emc/
        :windows
    when host_os =~ /darwin|mac os/
        :mac
    when host_os =~ /linux/
        :linux
    when host_os =~ /solaris|bsd/
        :unix
    else
        :unknown
    end
)

# Detect cwd
cwd = File.dirname(File.expand_path(__FILE__))

# Load configuration
merger = proc { |_,x,y| x.is_a?(Hash) && y.is_a?(Hash) ? x.merge(y, &merger) : y }
default_config = (YAML::load_file(File.expand_path('core/vagrant/default.yml', cwd)) rescue {}) || {}
user_config = (YAML::load_file(File.expand_path('devmachine.yml', cwd)) rescue {}) || {}
yaml_config = default_config.merge(user_config, &merger)

# Optimize configuration
yaml_config['devmachine'] = !yaml_config['devmachine'].nil? ? yaml_config['devmachine'] : default_config['devmachine']
## Hostname
if yaml_config['devmachine']['hostname'].nil?
    yaml_config['devmachine']['hostname'] = "#{`hostname`[0..-2]}".sub(/\..*$/,'')+"-devmachine" rescue "devmachine"
end
## Plugins
plugins = (yaml_config['devmachine']['plugins'] rescue {}) || {}
plugins_to_install = plugins.select { |plugin, desired_platform| platforms.include? desired_platform.to_sym and (desired_platform.to_sym == platform or desired_platform.to_sym == :all) }
yaml_config['devmachine']['plugins'] = plugins_to_install
## Vagrant Home
if yaml_config['devmachine']['directories']['home'].nil?
    yaml_config['devmachine']['directories']['home'] = yaml_config['devmachine']['directories']['cache']
elsif false == yaml_config['devmachine']['directories']['home']
    # Taken from the Vagrant source: check for USERPROFILE on Windows, for compatibility
    if ENV["USERPROFILE"]
        yaml_config['devmachine']['directories']['home'] = "#{ENV["USERPROFILE"]}/.vagrant.d"
    else
        yaml_config['devmachine']['directories']['home'] = '~/.vagrant.d'
    end
end
## Vagrant Dotfile Path
if yaml_config['devmachine']['directories']['dotfile_path'].nil?
    yaml_config['devmachine']['directories']['dotfile_path'] = yaml_config['devmachine']['directories']['cache']
elsif false == yaml_config['devmachine']['directories']['dotfile_path']
    yaml_config['devmachine']['directories']['dotfile_path'] = '.vagrant'
end

# If you find that your VirtualBox VMs seem slow when you try to SSH into them or when you point a web browser at them, then try adding these lines to your Vagrantfile:
#
# Vagrant.configure("2") do |config|
#   config.vm.provider :virtualbox do |vb|
#
#     # change the network card hardware for better performance
#     vb.customize ["modifyvm", :id, "--nictype1", "virtio" ]
#     vb.customize ["modifyvm", :id, "--nictype2", "virtio" ]
#
#     # suggested fix for slow network performance
#     # see https://github.com/mitchellh/vagrant/issues/1807
#     vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
#     vb.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
#   end
# end

# config.vm.provider "virtualbox" do |v|
#   host = RbConfig::CONFIG['host_os']
#
#   # Give VM 1/4 system memory
#   if host =~ /darwin/
#     # sysctl returns Bytes and we need to convert to MB
#     mem = `sysctl -n hw.memsize`.to_i / 1024
#   elsif host =~ /linux/
#     # meminfo shows KB and we need to convert to MB
#     mem = `grep 'MemTotal' /proc/meminfo | sed -e 's/MemTotal://' -e 's/ kB//'`.to_i
#   elsif host =~ /mswin|mingw|cygwin/
#     # Windows code via https://github.com/rdsubhas/vagrant-faster
#     mem = `wmic computersystem Get TotalPhysicalMemory`.split[1].to_i / 1024
#   end
#
#   mem = mem / 1024 / 4
#   v.customize ["modifyvm", :id, "--memory", mem]
# end

# Add workspaces
# if !yaml_config['workspace'].nil?
#     yaml_config['workspace'].each do |workspace_name, workspace_config|
#         if yaml_config['vm']['provision']["workspace:#{workspace_name}"].nil?
#             yaml_config['vm']['provision']["workspace:#{workspace_name}"] = {}
#         end
#         yaml_config['vm']['provision']["workspace:#{workspace_name}"] = add_defaults(
#             yaml_config['workspace']["#{workspace_name}"],
#             yaml_config['vm']['provision']["workspace:#{workspace_name}"]
#         )
#     end
#     yaml_config['devmachine'].delete('workspace')
# end
# Dir.glob('./workspace/*').select {|f| File.directory? f}.each do |file|
#     if File.exist?("#{file}/devmachine.yml")
#         workspace_name = File.basename(file)
#         if yaml_config['vm']['provision']["workspace:#{workspace_name}"].nil?
#             yaml_config['vm']['provision']["workspace:#{workspace_name}"] = {}
#         end
#         yaml_config['vm']['provision']["workspace:#{workspace_name}"] = add_defaults(
#             yaml_config['vm']['provision']["workspace:#{workspace_name}"],
#             add_defaults(
#                 YAML.load_file("#{file}/devmachine.yml"),
#                 {
#                     "type"=>"shell",
#                     "directory"=>"workspace/#{workspace_name}",
#                     "keep_color"=>true
#                 }
#             )
#         )
#     end
# end

#             # Add once to run provision
#             ARGV.each_with_index do |argument, index|
#                 if "--provision-with" == argument
#                     provision_with_array = ARGV[index+1].split(',')
#                     provision_with_array.each do |provision_with|
#                         if provision_with.include?(':') && !provision_with.start_with?('workspace:')
#                             provision_with_arguments = provision_with.split(':')
#
#                             # Initialize variables
#                             inline = "cd \"/env\""
#                             dos2unix = []
#
#                             while provision_with_arguments.any? do
#                                 # Get type
#                                 type = provision_with_arguments.first
#                                 provision_with_arguments = provision_with_arguments.drop(1)
#
#                                 # Run docker-compose
#                                 if "docker-compose" == type || "compose" == type
#                                     inline += %~
#                                         echo -e "\e[93mRun docker-compose\e[0m"
#                                     ~
#                                     container = provision_with_arguments.at(0)
#                                     entrypoint = !provision_with_arguments.at(1).empty? ? provision_with_arguments.at(1) : "/bin/bash"
#                                     command = provision_with_arguments.drop(2).join(':')
#                                     provision_with_arguments = []
#                                     inline += %~
#                                         echo -e "container: \\\"#{container}\\\", entrypoint: \\\"#{entrypoint}\\\", command: \\\"#{command}\\\""
#                                         docker-compose run --rm --entrypoint "#{entrypoint}" "#{container}" -c "#{command}"
#                                     ~
#
#                                 # Run ansible-playbook
#                                 elsif "ansible-playbook" == type || "playbook" == type
#                                     playbook = !provision_with_arguments.at(0).nil? ? provision_with_arguments.at(0) : "playbook.yml"
#                                     provision_with_arguments = provision_with_arguments.drop(1)
#                                     inline += %~
#                                         echo -e "\e[93mRun ansible-playbook\e[0m"
#                                         export PYTHONUNBUFFERED=1
#                                         export ANSIBLE_INVENTORY=/etc/ansible/local-hosts
#                                         export ANSIBLE_FORCE_COLOR=1
#                                         echo "playbook: \\\"#{playbook}\\\""
#                                         ansible-playbook "#{playbook}" --connection=local
#                                     ~
#
#                                 # Run bash with dos2unix
#                                 elsif "#{yaml_config['devmachine']['shell']}" == type || "script" == type
#                                     command = provision_with_arguments.at(0)
#                                     provision_with_arguments = provision_with_arguments.drop(1)
#                                     inline += %~
#                                         echo -e "\e[93mRun command (dos2unix)\e[0m"
#                                         echo "command: \\\"#{yaml_config['devmachine']['shell']} \\\"#{command}\\\"\\\""
#                                         #{yaml_config['devmachine']['shell']} "#{command}"
#                                     ~
#                                     dos2unix.push("echo \\\"#{command}\\\"")
#
#                                 # Run command
#                                 elsif "run" == type || "command" == type
#                                     command = provision_with_arguments.at(0)
#                                     provision_with_arguments = provision_with_arguments.drop(1)
#                                     inline += %~
#                                         echo -e "\e[93mRun command\e[0m"
#                                         echo "command: \\\"#{command}\\\""
#                                         #{command}
#                                     ~
#
#                                 # Run anything
#                                 else
#                                     command = provision_with_arguments.at(0)
#                                     provision_with_arguments = provision_with_arguments.drop(1)
#                                     inline += %~
#                                         echo -e "\e[93mRun command\e[0m"
#                                         echo "command: \\\"#{type} #{command}\\\""
#                                         #{type} #{command}
#                                     ~
#
#                                 end
#
#                             end
#
#                             # Add once to run provision
#                             yaml_config['vm']['provision'][provision_with] = {
#                                 "type"=>"shell",
#                                 "keep_color"=>true,
#                                 "inline"=>inline,
#                                 "dos2unix"=>dos2unix
#                             }
#                         end
#                     end
#                     break
#                 end
#             end

# Save optimized configuration (for inspection)
File.open(File.expand_path('devmachine.opt.yml', cwd),'w') do |file| # set perm too
    file.write yaml_config.to_yaml
end

# Assure environment variables are set
## puts File.expand_path('~')
## require 'etc'
## puts Etc.getpwuid.dir
# TODO this makes vagrant behave strangely during vagrant version
log = yaml_config['devmachine']['log']
cache = File.expand_path(yaml_config['devmachine']['directories']['cache'], cwd)
home = (! ENV['VAGRANT_HOME'].nil? ? ENV['VAGRANT_HOME'] : File.expand_path(yaml_config['devmachine']['directories']['home'], cwd))
dotfile_path = (! ENV['VAGRANT_DOTFILE_PATH'].nil? ? ENV['VAGRANT_DOTFILE_PATH'] : File.expand_path(yaml_config['devmachine']['directories']['dotfile_path'], cwd))
if dotfile_path != ENV['VAGRANT_DOTFILE_PATH'] or home != ENV['VAGRANT_HOME']
    if ENV['VAGRANT_DOTFILE_PATH'].nil?
        Dir.rmdir(File.expand_path('.vagrant', cwd))
    end
    ENV['VAGRANT_HOME'] = home
    ENV['VAGRANT_DOTFILE_PATH'] = dotfile_path
    if platform == :windows
        # TODO test this on windows
	    # TODO VAGRANT_LOG may not be empty on windows
        exec "SET \"VAGRANT_HOME=#{home}\" && SET \"VAGRANT_DOTFILE_PATH=#{dotfile_path}\" && vagrant #{ARGV.join' '}"
    else
        exec "export VAGRANT_LOG=#{log} && export VAGRANT_HOME=#{home} && export VAGRANT_DOTFILE_PATH=#{dotfile_path} && vagrant #{ARGV.join' '}"
    end
end

# Trying to cleanup within the official Vagrant boundaries
module VagrantPlugins
    module DevMachine
        class GatherPaths
            def initialize(app, env)
                @app = app
            end
            def call(env)
                # Adding to a cleanup "namespace"
                env[:cleanup_home_path] = env[:home_path]
                # As the environment will always be the same for the whole Vagrantfile, this is okay for multiple vms
                env[:machine_index].each do |entry|
                    # Why is local_data_path not a symbol?
                    env[:cleanup_local_data_path] = entry.local_data_path
                end
                @app.call(env)
            end
        end
        class CleanupPaths
            def initialize(app, env)
                @app = app
            end
            def call(env)
                # List all directories, including the root folder: {.,**/*}
                # Avoid problems with special characters in path by using chdir and expand_path
                # Use reverse_each to start in the deepest directory, and cleanup empty directories recursively going up
                # Don't check . or .. directories
                # Default settings will have same path for home and local_data, but we'll ignore that for now
                Dir.chdir(env[:cleanup_home_path]) { Dir.glob('{.,**/*}').map {|path| File.expand_path(path) }.select { |dir| File.directory? dir }.reverse_each { |dir| Dir.rmdir dir if (Dir.entries(dir) - %w[ . .. ]).empty? } }
                Dir.chdir(env[:cleanup_local_data_path]) { Dir.glob('{.,**/*}').map {|path| File.expand_path(path) }.select { |dir| File.directory? dir }.reverse_each { |dir| Dir.rmdir dir if (Dir.entries(dir) - %w[ . .. ]).empty? } }
                @app.call(env)
            end
        end
        # Creating a plugin only for the cleanup - extending this for the rest?
        class Plugin < Vagrant.plugin('2')
            name "cleanup"
            description <<-DESC
                Cleanup after destroy
            DESC
            # https://www.vagrantup.com/docs/plugins/action-hooks.html
            action_hook(:remove_empty_directories, :machine_action_destroy) do |hook|
                # First gather the paths, as after the destroy the machine will not be listed anymore
                hook.before(VagrantPlugins::ProviderVirtualBox::Action::Destroy, DevMachine::GatherPaths)
                # Cleanup with the cached paths - the most interesting is actually the local_data_path, as it is empty
                hook.append(DevMachine::CleanupPaths)
                # Why can't we use one class instance with two methods here?
            end
        end
    end
end

# Install plugins
if ['provision', 'reload', 'resume', 'up'].include? ARGV[0]
    plugins = yaml_config['devmachine']['plugins'] rescue {}
    plugins_to_install = plugins.select { |plugin, desired_platform| not Vagrant.has_plugin? plugin }
    restart = false
    if not plugins_to_install.empty?
        $stdout.send(:puts, "Installing missing plugins...")
        plugins_to_install.each do |plugin, desired_platform|
            if system "vagrant plugin install #{plugin}"
                restart = true
            else
                abort "Installation has failed."
            end
        end
        if true === restart
            $stdout.send(:puts, "Running \"vagrant #{ARGV.join' '}\" again...")
            exec "vagrant #{ARGV.join' '}"
        end
    end
end

# Print branding
if ['provision', 'reload', 'resume', 'up'].include? ARGV[0]
    branding = (yaml_config['devmachine']['branding'] + "\n" rescue "") + "DevMachine (CC BY-SA 4.0) 2016 MetalArend"
    $stdout.send(:puts, "\n\e[92m" + branding + "\e[0m\n")
    version = ("v" + yaml_config['devmachine']['version'] rescue "version unknown") + " | " + platform.to_s
    $stdout.send(:puts, "\e[2m" + version + "\e[0m")
end

# Print information
if ['provision', 'reload', 'resume', 'up'].include? ARGV[0]
    if File.expand_path('cache', $cwd) != cache
        $stdout.send(:puts, "\e[2mcache: " + Pathname.new(cache).relative_path_from(Pathname.new(cwd)).to_s + "\e[0m")
    end
    if home != cache
        $stdout.send(:puts, "\e[2mhome: " + Pathname.new(home).relative_path_from(Pathname.new(cwd)).to_s + "\e[0m")
    end
    if dotfile_path != cache
        $stdout.send(:puts, "\e[2mdotfile_path: " + Pathname.new(dotfile_path).relative_path_from(Pathname.new(cwd)).to_s + "\e[0m")
    end
    $stdout.send(:puts, "\n")
end

# TODO Auto-update DevMachine (only when internet is available)

# Build configuration
Vagrant.configure(yaml_config['vagrant']['api_version']) do |config|
    (1..yaml_config['devmachine']['nodes']).each do |i|
        node_hostname = yaml_config['devmachine']['hostname'] + ((yaml_config['devmachine']['node_suffix'] % i) rescue (yaml_config['devmachine']['node_suffix'] + i.to_s))

        config.vm.define node_hostname do |node|

            # Host
#             node.vm.network :private_network, ip: "192.168.100.100"
#             ip = "172.20.100.#{i+99}" # TODO use yaml_config['vm']['ip']?
#             node.vm.network :private_network, ip: ip # TODO this triggers configure_networks
#             node.vm.hostname = node_hostname # TODO use yaml_config['vm']['hostname']? # TODO this triggers change_host_name

            # Disable auto mounting vagrant directory
            node.vm.synced_folder ".", "/vagrant", disabled: true

#             # Having the /env folder with the same group setting as that
#             # of the apache2 process' group ensures that Apache2 can access and modify
#             # files under it, without explicitly chmod-ing them to 777
#             # This only works for the default provider
#             # - With nfs we cannot set the group for the directory
#             # - With rsync two-way sync is not possible
#             # Check http://jeremykendall.net/2013/08/09/vagrant-synced-folders-permissions/
#             # Check http://www.sebastien-han.fr/blog/2012/12/18/noac-performance-impact-on-web-applications/
#             node.vm.synced_folder ".", "/env", type: "nfs"
#
#             # Add ssh keys
#             node.vm.synced_folder "~/.ssh", "/ssh", type: "nfs"

            # Set the host if given
            if !yaml_config['vagrant']['host'].nil?
                node.vagrant.host = yaml_config['vagrant']['host'].gsub(":", "").intern
            end

            # Disabling compression because OS X has an ancient version of rsync installed.
            # Add -z or remove rsync__args below if you have a newer version of rsync on your machine.
#            node.vm.synced_folder "./core/docker", "/home/rancher/docker", type: :rsync,
##                 rsync__exclude: [".git/", ".gitignore", ".idea/", "cache/", "core/", "workspace/", "devmachine.opt.yml", "devmachine.yml", "README.md", "Vagrantfile"],
#                rsync__args: ["--verbose", "--archive", "--delete", "--copy-links"],
#                rsync__auto: true,
#                rsync__verbose: true,
#                disabled: false

#             config.vm.provision :docker do |docker|
#                 docker.pull_images "busybox"
#                 docker.run "simple-echo",
#                     image: "busybox",
#                     args: "-p 8080:8080 --restart=always",
#                     cmd: "nc -p 8080 -l -l -e echo hello world!"
#             end

#             node.vm.provider "virtualbox" do |vb|
#                 config.vm.network "private_network", :type => 'dhcp', :name => 'vboxnet0', :adapter => 2
#             end
#
#             node.vm.synced_folder ".", "/test", type: "nfs"

            vagrant_version = Vagrant::VERSION
            node.vm.provision "shell", inline: %~
                # Exit on error
                set -e

#                 # Download docker-compose
#                 mkdir -p /opt/bin/
#                 DOCKER_COMPOSE_FILENAME="docker-compose-`uname -s`-`uname -m`"
#                 DOCKER_COMPOSE_VERSION="1.6.0"
#                 DOCKER_COMPOSE_PATH="/opt/bin/docker-compose/${DOCKER_COMPOSE_VERSION}/docker-compose"
#                 if test ! -f ${DOCKER_COMPOSE_PATH}; then
#                     mkdir -p "$(dirname "${DOCKER_COMPOSE_PATH}")"
#                     wget -O ${DOCKER_COMPOSE_PATH} https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/${DOCKER_COMPOSE_FILENAME}
#                 fi
#                 chmod +x ${DOCKER_COMPOSE_PATH}
#                 sudo ln -sfn /${DOCKER_COMPOSE_PATH} /usr/bin/docker-compose
#
#                 # Run docker-compose
# #                 echo -e "\e[33mRun docker-compose\e[0m"
# #                 cd "/opt/devmachine/gui"
# #                 docker-compose stop && docker-compose rm -f && docker-compose build && docker-compose up -d
#
                # Logs
                echo -e "\e[0m\e[92mVagrant version #{vagrant_version}\e[0m"
                echo -e "\e[0m\e[92m$(docker --version)\e[0m"
#                 docker-compose --version
#                 docker-compose ps
            ~

            # Load vm configuration
            if !yaml_config['vm'].nil? && !yaml_config['vm'].empty?

                yaml_config['vm'].each do |vm_name, vm_value|

                    if !vm_value.nil?

                        if 'usable_port_range' == vm_name
                            if !vm_value[/^[0-9]+\.\.[0-9]+$/].nil?
                                borders = vm_value.split('..').map{|d| Integer(d)}
                                vm_value = borders[0]..borders[1]
                            end
                            node.vm.send("#{vm_name}=", vm_value)

                        # Resolve a "code NS_ERROR_FAILURE (0x80004005)" with the following commands on a host machine:
                        # Mac OS X: sudo /Library/StartupItems/VirtualBox/VirtualBox restart
                        # Linux: sudo modprobe vboxnetadp
                        # Read more: https://coderwall.com/p/ydma0q
                        elsif 'network' == vm_name
                            if vm_value['private_network'].to_s != ''
                                # TIP Sometimes Windows gives problems with the private network
                                if Vagrant::Util::Platform.windows?
                                    node.vm.network "private_network", ip: "#{vm_value['private_network']}", type: "dhcp" # TODO test
                                else
                                    node.vm.network "private_network", ip: "#{vm_value['private_network']}"
                                end
                            end
                            if vm_value.has_key?('forwarded_ports') && !vm_value['forwarded_ports'].empty?
                                vm_value['forwarded_ports'].each do |port_id, port_config|
                                    auto_correct = !port_config['auto_correct'].nil? ? port_config['auto_correct'] : false
                                    if port_config['guest'] != '' && port_config['host'] != ''
                                        node.vm.network :forwarded_port, guest: port_config['guest'].to_i, host: port_config['host'].to_i, id: port_id, auto_correct: auto_correct
                                    end
                                end
                            end

                        elsif 'synced_folder' == vm_name
                            vm_value.each do |folder_id, folder_config|
                                if folder_config['source'] != '' && folder_config['target'] != ''
                                    owner = !folder_config['owner'].nil? && !folder_config['owner'].empty? ? folder_config['owner'] : nil
                                    group = !folder_config['group'].nil? && !folder_config['group'].empty? ? folder_config['group'] : nil
                                    type = !folder_config['type'].nil? && !folder_config['type'].empty? ? folder_config['type'] : nil
                                    node.vm.synced_folder "#{folder_config['source']}", "#{folder_config['target']}", id: folder_id, owner: owner, group: group, type: type
                                    node.vm.provider "virtualbox" do |provider|
                                        provider.customize ["setextradata", :id, "VBoxInternal2/SharedFoldersEnableSymlinksCreate/#{folder_id}", "1"]
                                    end
                                end
                            end

                        elsif 'provider' == vm_name
                            vm_value.each do |provider_name, provider_config|
                                node.vm.provider "#{provider_name}" do |provider|
                                    provider_config.each do |provider_config_key, provider_config_value|
                                        if 'modifyvm' == provider_config_key
                                            provider_config['modifyvm'].each do |modifyvm_name, modifyvm_value|
                                                if modifyvm_name == "natdnshostresolver1"
                                                    modifyvm_value = modifyvm_value ? "on" : "off"
                                                end
                                                provider.customize ["modifyvm", :id, "--#{modifyvm_name}", "#{modifyvm_value}"]
                                            end
                                        elsif 'setextradata' == provider_config_key
                                            provider_config['setextradata'].each do |setextradata_name, setextradata_value|
                                                provider.customize ["setextradata", :id, "--#{setextradata_name}", "#{setextradata_value}"]
                                            end
                                        else
                                            provider.send("#{provider_config_key}=", provider_config_value)
                                        end
                                    end
                                end
                            end

                        elsif 'provision' == vm_name # TODO retest the dos2unix stuff - common.sh can be injected?
                            vm_value.each do |provision_name, provision_config|
                                provision_config = add_defaults(provision_config, {
                                    "directory"=>"",
                                    "dos2unix"=>[]
                                })
                                directory = provision_config.delete('directory')
                                directory << '/' unless directory.end_with?('/') || directory.empty?
                                dos2unix = provision_config.delete('dos2unix')
                                if "shell" == provision_config['type'] && !provision_config['path'].nil?
                                    if !File.exist?("#{directory}#{provision_config['path']}")
                                        if File.exist?("workspace/#{provision_name}/#{directory}#{provision_config['path']}")
                                            directory = "workspace/#{provision_name}/#{directory}"
                                        end
                                    end
                                    if File.exist?("#{directory}#{provision_config['path']}")
                                        dos2unix.push("echo #{provision_config['path']}")
                                    end
                                end
                                dos2unix.unshift("echo \"/env/shell/common.sh\"")
                                inline = %~
                                    cd "/env/#{directory}"
                                ~
                                if !dos2unix.nil? && dos2unix.any?
                                    dos2unix.each do |dos2unix_item|
                                        inline += %~
                                            FILES=$(echo -e "${FILES}\n$(#{dos2unix_item} | xargs --no-run-if-empty file | grep CRLF | sed -E 's/:.*$//')")
                                        ~
                                    end
                                end
                                inline += %~
                                    if test -n "${FILES}"; then
                                        FILES=$(echo -e "${FILES}" | sort -u)
                                        if [ $(dpkg-query -W -f='${Status}' dos2unix 2>/dev/null | grep -c "ok installed") -eq 0 ]; then
                                            echo -e "\e[93mInstall dos2unix\e[0m"
                                            apt-get install -y dos2unix
                                        fi
                                        echo -e "\e[93mConvert line endings from dos to unix\e[0m"
                                        SAVEIFS=$IFS
                                        IFS=$(echo -en "\n\b")
                                        for FILE in ${FILES}; do
                                            dos2unix --keepdate \"${FILE}\" 2>&1 | tr -d "\n"
                                        done
                                        IFS=$SAVEIFS
                                    fi
                                ~
                                if !provision_config['path'].nil?
                                    inline += %~
                                        bash "#{provision_config['path']}"
                                    ~
                                    provision_config.delete('path')
                                else
                                    inline += %~
                                        bash -c 'cd "/env/#{directory}"; source "/env/shell/common.sh"; #{provision_config['inline']}'
                                    ~
                                end
                                inline += %~
                                    if test -n "${FILES}"; then
                                        echo -e "\e[93mConvert line endings from unix to dos\e[0m"
                                        SAVEIFS=$IFS
                                        IFS=$(echo -en "\n\b")
                                        for FILE in ${FILES}; do
                                            unix2dos --keepdate \"${FILE}\" 2>&1 | tr -d "\n"
                                        done
                                        IFS=$SAVEIFS
                                    fi
                                ~
                                provision_config['inline'] = inline

                                disable = provision_config.delete('disable')
                                windows_only = provision_config.delete('windows_only')
                                if (disable.nil? || !disable) && (windows_only.nil? || !windows_only || (windows_only && Vagrant::Util::Platform.windows?))
                                    node.vm.provision "#{provision_name}", type: provision_config.delete('type'), run: provision_config.delete('run') do |provision|
                                        provision_config.each do |provision_config_key, provision_config_value|
                                            provision.send("#{provision_config_key}=", provision_config_value)
                                        end
                                    end
                                end
                            end

                        else
                            node.vm.send("#{vm_name}=", vm_value)
                        end

                    end

                end

            end

            # Load ssh configuration
            if yaml_config.has_key?('ssh') && !yaml_config['ssh'].nil? && !yaml_config['ssh'].empty?
                yaml_config['ssh'].each do |ssh_name, ssh_value|
                    if !ssh_value.nil?
                        node.ssh.send("#{ssh_name}=", "#{ssh_value}")
                    end
                end
            end

        end
    end
#     puts config.inspect
end

# if ['provision', 'reload', 'resume', 'up'].include? ARGV[0]
#     rsync = fork do
#         exec "vagrant rsync-auto"
#     end
#     Process.detach(rsync)
# end