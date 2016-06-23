require 'yaml'

# Require latest vagrant version
Vagrant.require_version '>= 1.6.0'

# Check command
if (['provision', 'reload', 'resume', 'up'].include? ARGV[0])

    # Print branding
    $stdout.send(:puts, " ")
    $stdout.send(:puts, "\e[92;40m                                                                    \e[0m")
    $stdout.send(:puts, "\e[92;40m________            ______  ___            ______ _____             \e[0m")
    $stdout.send(:puts, "\e[92;40m___  __ \\_______   ____   |/  /_____ _________  /____(_)___________ \e[0m")
    $stdout.send(:puts, "\e[92;40m__  / / /  _ \\_ | / /_  /|_/ /_  __ `/  ___/_  __ \\_  /__  __ \\  _ \\\e[0m")
    $stdout.send(:puts, "\e[92;40m_  /_/ //  __/_ |/ /_  /  / / / /_/ // /__ _  / / /  / _  / / /  __/\e[0m")
    $stdout.send(:puts, "\e[92;40m/_____/ \\___/_____/ /_/  /_/  \\__,_/ \\___/ /_/ /_//_/  /_/ /_/\\___/ \e[0m")
    $stdout.send(:puts, "\e[92;40m                    DevMachine (CC BY-SA 4.0) 2014-2015 MetalArend  \e[0m")
    $stdout.send(:puts, "\e[92;40m                                                                    \e[0m")
    $stdout.send(:puts, " ")

    # Check required plugins
    plugins_required = []
    if (Vagrant::Util::Platform.windows?)
        plugins_required << 'vagrant-winnfsd'
    end

    plugins_to_install = plugins_required.select { |plugin| not Vagrant.has_plugin? plugin }
    has_new_plugin = false
    if not plugins_to_install.empty?
        plugins_to_install.each do |plugin|
            if system "vagrant plugin install #{plugin}"
                has_new_plugin = true
            else
                abort "Installation has failed."
            end
        end
        if true === has_new_plugin
            exec "vagrant #{ARGV.join' '}"
        end
    end

end

# Define recursive replace function
def add_defaults(a,b)
    a.merge(b) do |_,x,y|
        (x.is_a?(Hash) && y.is_a?(Hash)) ? add_defaults(x,y) : x
    end
end

# Load yaml configuration
yaml_config = File.exist?('./devmachine.yml') ? YAML.load_file('./devmachine.yml') : {}
yaml_config = add_defaults(yaml_config, YAML.load_file('./vagrant/default.yml'))
if !yaml_config['workspace'].nil?
    yaml_config['workspace'].each do |workspace_name, workspace_config|
        if yaml_config['vm']['provision']["workspace:#{workspace_name}"].nil?
            yaml_config['vm']['provision']["workspace:#{workspace_name}"] = {}
        end
        yaml_config['vm']['provision']["workspace:#{workspace_name}"] = add_defaults(
            yaml_config['workspace']["#{workspace_name}"],
            yaml_config['vm']['provision']["workspace:#{workspace_name}"]
        )
    end
    yaml_config['devmachine'].delete('workspace')
end
Dir.glob('./workspace/*').select {|f| File.directory? f}.each do |file|
    if File.exist?("#{file}/devmachine.yml")
        workspace_name = File.basename(file)
        if yaml_config['vm']['provision']["workspace:#{workspace_name}"].nil?
            yaml_config['vm']['provision']["workspace:#{workspace_name}"] = {}
        end
        yaml_config['vm']['provision']["workspace:#{workspace_name}"] = add_defaults(
            yaml_config['vm']['provision']["workspace:#{workspace_name}"],
            add_defaults(
                YAML.load_file("#{file}/devmachine.yml"),
                {
                    "type"=>"shell",
                    "directory"=>"workspace/#{workspace_name}",
                    "keep_color"=>true
                }
            )
        )
    end
end

# Build Vagrant configuration
Vagrant.configure(yaml_config['vagrant']['api_version']) do |vagrant_config|

    # Disable auto mounting vagrant directory
    vagrant_config.vm.synced_folder ".", "/vagrant", disabled: true

    # Having the /env folder with the same group setting as that
    # of the apache2 process' group ensures that Apache2 can access and modify
    # files under it, without explicitly chmod-ing them to 777
    # This only works for the default provider
    # - With nfs we cannot set the group for the directory
    # - With rsync two-way sync is not possible
    # Check http://jeremykendall.net/2013/08/09/vagrant-synced-folders-permissions/
    # Check http://www.sebastien-han.fr/blog/2012/12/18/noac-performance-impact-on-web-applications/
    vagrant_config.vm.synced_folder ".", "/env", type: "nfs"

    # Add ssh keys
    vagrant_config.vm.synced_folder "~/.ssh", "/ssh", type: "nfs"

    # Set the host if given
    if !yaml_config['vagrant']['host'].nil?
        vagrant_config.vagrant.host = yaml_config['vagrant']['host'].gsub(":", "").intern
    end

    # Add provision "bashrc": add default login location
    bashrc = yaml_config['devmachine']['bashrc']
    vagrant_config.vm.provision "bashrc", type: "shell", keep_color: true, inline: %~
        (grep -q -F "#{bashrc}" "/home/vagrant/.bashrc" || echo -e "\n#{bashrc}" >> "/home/vagrant/.bashrc")
    ~

    # Add provision "docker": install docker and docker-compose
    vagrant_config.vm.provision "docker", type: "shell", keep_color: true, inline: %~
        sudo apt-get update && sudo apt-get install apt-transport-https ca-certificates
        sudo apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
        sudo touch "/etc/apt/sources.list.d/docker.list"
        echo "deb https://apt.dockerproject.org/repo ubuntu-trusty main" | sudo tee "/etc/apt/sources.list.d/docker.list"
        sudo apt-get update
        sudo apt-get purge lxc-docker
        sudo apt-get install -y linux-image-extra-$(uname -r)
        apt-cache policy docker-engine
        sudo apt-get install -y docker-engine
        sudo service docker start
        sudo groupadd docker
        sudo usermod -aG docker vagrant
        curl -L https://github.com/docker/compose/releases/download/1.8.0-rc1/docker-compose-`uname -s`-`uname -m` > /tmp/docker-compose
        #curl -L https://github.com/docker/compose/releases/download/1.8.0-rc1/run.sh > /tmp/docker-compose
        sudo cp /tmp/docker-compose /usr/local/bin/docker-compose
        sudo chmod +x /usr/local/bin/docker-compose
    ~

    # Add provision "cleanup": add shell script to cleanup docker containers
    vagrant_config.vm.provision "cleanup", type: "shell", keep_color: true, run: "always", path: "./shell/cleanup-docker.sh"

    # Load vm configuration
    if !yaml_config['vm'].empty?

        yaml_config['vm'].each do |vm_name, vm_value|

            if !vm_value.nil? && !vm_value.empty?

                if 'usable_port_range' == vm_name
                    if !vm_value[/^[0-9]+\.\.[0-9]+$/].nil?
                        borders = vm_value.split('..').map{|d| Integer(d)}
                        vm_value = borders[0]..borders[1]
                    end
                    vagrant_config.vm.send("#{vm_name}=", vm_value)

                # Resolve a "code NS_ERROR_FAILURE (0x80004005)" with the following commands on a host machine:
                # Mac OS X: sudo /Library/StartupItems/VirtualBox/VirtualBox restart
                # Linux: sudo modprobe vboxnetadp
                # Read more: https://coderwall.com/p/ydma0q
                elsif 'network' == vm_name
                    if vm_value['private_network'].to_s != ''
                        # TIP Sometimes Windows gives problems with the private network
                        # if Vagrant::Util::Platform.windows?
                        #     vagrant_config.vm.network "private_network", ip: "#{vm_value['private_network']}", type: "dhcp"
                        # else
                            vagrant_config.vm.network "private_network", ip: "#{vm_value['private_network']}"
                        # end
                    end
                    if !vm_value['forwarded_ports'].empty?
                        vm_value['forwarded_ports'].each do |port_id, port_config|
                            auto_correct = !port_config['auto_correct'].nil? ? port_config['auto_correct'] : false
                            if port_config['guest'] != '' && port_config['host'] != ''
                                vagrant_config.vm.network :forwarded_port, guest: port_config['guest'].to_i, host: port_config['host'].to_i, id: port_id, auto_correct: auto_correct
                            end
                        end
                    end

                elsif 'synced_folder' == vm_name
                    vm_value.each do |folder_id, folder_config|
                        if folder_config['source'] != '' && folder_config['target'] != ''
                            owner = !folder_config['owner'].nil? && !folder_config['owner'].empty? ? folder_config['owner'] : nil
                            group = !folder_config['group'].nil? && !folder_config['group'].empty? ? folder_config['group'] : nil
                            type = !folder_config['type'].nil? && !folder_config['type'].empty? ? folder_config['type'] : nil
                            vagrant_config.vm.synced_folder "#{folder_config['source']}", "#{folder_config['target']}", id: folder_id, owner: owner, group: group, type: type
                            vagrant_config.vm.provider "virtualbox" do |provider|
                                provider.customize ["setextradata", :id, "VBoxInternal2/SharedFoldersEnableSymlinksCreate/#{folder_id}", "1"]
                            end
                        end
                    end

                elsif 'provider' == vm_name
                    vm_value.each do |provider_name, provider_config|
                        vagrant_config.vm.provider "#{provider_name}" do |provider|
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

                elsif 'provision' == vm_name
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
                            vagrant_config.vm.provision "#{provision_name}", type: provision_config.delete('type'), run: provision_config.delete('run') do |provision|
                                provision_config.each do |provision_config_key, provision_config_value|
                                    provision.send("#{provision_config_key}=", provision_config_value)
                                end
                            end
                        end
                    end

                else
                    vagrant_config.vm.send("#{vm_name}=", vm_value)
                end

            end

        end

    end

    # Load ssh configuration
    if !yaml_config['ssh'].empty?
        yaml_config['ssh'].each do |ssh_name, ssh_value|
            if !ssh_value.nil?
                vagrant_config.ssh.send("#{ssh_name}=", "#{ssh_value}")
            end
        end
    end

    # Add provision "report": report versions of installed programs
    vagrant_config.vm.provision "report", type: "shell", keep_color: true, run: "always", inline: %~
        # Detect OS
        OS=$(uname)
        ID='unknown'
        CODENAME='unknown'
        RELEASE='unknown'
        ARCH='unknown'

        # detect centos
        grep 'centos' /etc/issue -i -q
        if [ $? = '0' ]; then
            ID='centos'
            RELEASE=$(cat /etc/redhat-release | grep -o 'release [0-9]' | cut -d " " -f2)
        elif [ -f '/etc/redhat-release' ]; then
            ID='centos'
            RELEASE=$(cat /etc/redhat-release | grep -o 'release [0-9]' | cut -d " " -f2)
        # could be debian or ubuntu
        elif [ $(which lsb_release) ]; then
            ID=$(lsb_release -i | cut -f2)
            CODENAME=$(lsb_release -c | cut -f2)
            RELEASE=$(lsb_release -r | cut -f2)
        elif [ -f '/etc/lsb-release' ]; then
            ID=$(cat /etc/lsb-release | grep DISTRIB_ID | cut -d "=" -f2)
            CODENAME=$(cat /etc/lsb-release | grep DISTRIB_CODENAME | cut -d "=" -f2)
            RELEASE=$(cat /etc/lsb-release | grep DISTRIB_RELEASE | cut -d "=" -f2)
        elif [ -f '/etc/issue' ]; then
            ID=$(head -1 /etc/issue | cut -d " " -f1)
            if [ -f '/etc/debian_version' ]; then
              RELEASE=$(</etc/debian_version)
            else
              RELEASE=$(head -1 /etc/issue | cut -d " " -f2)
            fi
        fi

        ID=$(echo "${ID}" | tr '[A-Z]' '[a-z]')
        CODENAME=$(echo "${CODENAME}" | tr '[A-Z]' '[a-z]')
        RELEASE=$(echo "${RELEASE}" | tr '[A-Z]' '[a-z]')
        ARCH=$(uname -m)

        #IP=$(ifconfig eth1 | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p')
        IP=$(ip addr show | grep "state UP" -A2 | grep "scope global" | grep -v "docker" | awk '{print $2}' | cut -f1 -d'/' | tr '\n' ' ')

        echo -e "\e[92m$(date +"%d/%m/%Y %H:%M:%S")\e[0m"
        echo -e "\e[92m${ID} ${RELEASE} (${CODENAME}) on ${IP}\e[0m"

        # Detect programs
        if which docker &> /dev/null; then
          echo -e "\e[92m- $(docker --version)\e[0m";
        else
          echo -e "\e[91m- docker not found\e[0m";
        fi
        if which docker-compose &> /dev/null; then
          echo -e "\e[92m- $(docker-compose --version)\e[0m";
        else
          echo -e "\e[91m- docker-compose not found\e[0m";
        fi
    ~

end