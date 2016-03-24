# TODO https://github.com/ailispaw/rancheros-lite
# TODO https://www.snip2code.com/Snippet/374178/Vagrantfile-including-patches-for-Ranche

# TODO composer create-project phpmyadmin/phpmyadmin --repository-url=https://www.phpmyadmin.net/packages.json

# $stdout.sync = true

# Check vagrant version
Vagrant.require_version '>= 1.6.0'

# Load dependencies
require 'rbconfig'
require 'yaml'
require 'fileutils'
require_relative 'core/vagrant/plugins/vagrant_devmachine.rb'

yaml_config = VagrantPlugins::DevMachine::LoadYamlConfig::load()

# # Assure environment variables are set
# ## File.expand_path('~')
# ## require 'etc'
# ## puts Etc.getpwuid.dir
# # TODO this makes vagrant behave strangely during vagrant version
# cwd = File.dirname(File.expand_path(__FILE__))
# home_path = (! ENV['VAGRANT_HOME'].nil? ? ENV['VAGRANT_HOME'] : File.expand_path(yaml_config['devmachine']['directories']['home_path'], cwd))
# local_data_path = (! ENV['VAGRANT_DOTFILE_PATH'].nil? ? ENV['VAGRANT_DOTFILE_PATH'] : File.expand_path(yaml_config['devmachine']['directories']['local_data_path'], cwd))
# if home_path != ENV['VAGRANT_HOME'] or local_data_path != ENV['VAGRANT_DOTFILE_PATH']
#     if ENV['VAGRANT_DOTFILE_PATH'].nil?
#         Dir.rmdir(File.expand_path('.vagrant', cwd))
#     end
#     ENV['VAGRANT_HOME'] = home_path
#     ENV['VAGRANT_DOTFILE_PATH'] = local_data_path
#     if VagrantPlugins::DevMachine::PLATFORM == :windows
#         exec "SET \"VAGRANT_HOME=#{home_path}\" && SET \"VAGRANT_DOTFILE_PATH=#{local_data_path}\" && vagrant #{ARGV.join' '}"
#     else
#         exec "export VAGRANT_HOME=#{home_path} && export VAGRANT_DOTFILE_PATH=#{local_data_path} && vagrant #{ARGV.join' '}"
#     end
# end

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
end