require 'yaml'

# Require latest vagrant version
Vagrant.require_version '>= 1.6.0'

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

# Load yaml configuration
yaml_config = YAML.load_file('./vagrant.yml')

# Read vagrant configuration
vagrant_options         = !yaml_config['vagrant'].nil?              ? yaml_config['vagrant']            : {}
api_version             = !vagrant_options['api_version'].nil?      ? vagrant_options['api_version']    : "2"
host                    = !vagrant_options['host'].nil?             ? vagrant_options['host']           : nil

# Read vm configuration
vm_options              = !yaml_config['vm'].nil?                   ? yaml_config['vm']                 : {}

# Read ssh configuration
ssh_options             = !yaml_config['ssh'].nil?                  ? yaml_config['ssh']                : {}

# Read devmachine configuration
devmachine_options      = !yaml_config['devmachine'].nil?           ? yaml_config['devmachine']         : {}
bashrc_start            = !devmachine_options['start'].nil?         ? devmachine_options['start']       : "/env"
timezone                = !devmachine_options['timezone'].nil?      ? devmachine_options['timezone']    : "Europe/Brussels"
locale                  = !devmachine_options['locale'].nil?        ? devmachine_options['locale']      : "en_US.UTF-8"

# Read docker configuration
docker_options          = !yaml_config['docker'].nil?               ? yaml_config['docker']             : {}
docker_version          = !docker_options['version'].nil?           ? docker_options['version']         : "1.7.1"
docker_group_members    = !docker_options['group_members'].nil?     ? docker_options['group_members']   : "vagrant"

# Read docker-compose configuration
docker_compose_options  = !yaml_config['docker_compose'].nil?       ? yaml_config['docker_compose']     : {}
docker_compose_version  = !docker_compose_options['version'].nil?   ? docker_compose_options['version'] : "1.3.3"

# Read ansible configuration
ansible_options         = !yaml_config['ansible'].nil?              ? yaml_config['ansible']            : {}
ansible_version         = !ansible_options['version'].nil?          ? ansible_options['version']        : "1.9.2"
ansible_playbook        = !ansible_options['playbook'].nil?         ? ansible_options['playbook']       : "/env/ansible.yml"
ansible_extra_vars      = !ansible_options['extra_vars'].nil?       ? ansible_options['extra_vars']     : {}
ansible_extra_vars = {
    "timezone"=>timezone,
    "locale"=>locale,
    "docker_version"=>docker_version,
    "docker_group_members"=>docker_group_members,
    "docker_compose_version"=>docker_compose_version
}.merge(ansible_extra_vars).map { |key| key * "=" } * " "

# Build Vagrant configuration
Vagrant.configure(api_version) do |vagrant_config|

    # Disable auto mounting vagrant directory # TODO use this instead of /env?
    vagrant_config.vm.synced_folder ".", "/vagrant", disabled: true

    # Set the host if given
    if !host.nil?
        vagrant_config.vagrant.host = host.gsub(":", "").intern
    end

    # Add provision "bashrc": add default login location
    vagrant_config.vm.provision "bashrc", type: "shell", keep_color: true, inline: %~
        (grep -q -F "cd #{bashrc_start}" "/home/vagrant/.bashrc" || echo -e "\ncd #{bashrc_start}" >> "/home/vagrant/.bashrc")
    ~

    # Add provision "system": install ansible and run playbook # TODO use ansible_version
    vagrant_config.vm.provision "system", type: "shell", keep_color: true, inline: %~
        if ! which pip &> /dev/null; then
            echo -e "\e[93mInstall pip\e[0m"
            export DEBIAN_FRONTEND=noninteractive
            apt-get -y update
            apt-get -y install python-pip python-dev build-essential
            pip install --upgrade pip
            pip install --upgrade distribute
            hash -r
        fi
        if test -z "$(pip list | grep "ansible" | grep "#{ansible_version}")"; then
            echo -e "\e[93mInstall ansible\e[0m"
            pip install ansible==#{ansible_version}
        fi
        sudo mkdir -p /etc/ansible/ /usr/share/ansible_plugins/callback_plugins/
        sudo cp /env/ansible/plugins/* /usr/share/ansible_plugins/callback_plugins/
        echo "localhost ansible_connection=local" > /etc/ansible/local-hosts

        PLAYBOOK_DIRECTORY=$(dirname "#{ansible_playbook}")
        PLAYBOOK_FILENAME=$(basename "#{ansible_playbook}")
        echo -e "\e[93mRun ansible playbook \"#{ansible_playbook}\" \e[0m"
        cd "${PLAYBOOK_DIRECTORY}"
        export PYTHONUNBUFFERED=1
        export ANSIBLE_INVENTORY=/etc/ansible/local-hosts
        export ANSIBLE_FORCE_COLOR=1
        ansible-playbook "${PLAYBOOK_FILENAME}" --connection=local --extra-vars "#{ansible_extra_vars}"
    ~

    # Add once to run provision
    ARGV.each_with_index do |argument, index|
        if "--provision-with" == argument
            provision_with_array = ARGV[index+1].split(',')
            provision_with_array.each do |provision_with|
                if provision_with.include? ':'
                    # Get type
                    type = provision_with.split(':').first
                    parts = provision_with.split(':').drop(1)
                    inline = "cd \"/env\""
                    dos2unix = []

                    # Shift to specific directory/project
                    if "cd" == type || "workspace" == type
                        directory = parts.at(0)
                        if "workspace" == type
                            if !directory.start_with?('/') \
                                    && !directory.start_with?('/env/workspace') \
                                    && File.directory?(File.expand_path('./workspace/' + directory))
                                directory = '/env/workspace/' + directory
                            end
                        end
                        inline += %~
                            echo -e "\e[93mChange directory\e[0m"
                            cd "#{directory}"
                            echo "#{directory}"
                        ~
                        type = parts.at(1)
                        parts = parts.drop(2)
                        if "bash" == type || "script" == type
                            dos2unix.push("echo \"/env/shell/common.sh\"")
                        end
                    end

                    # Add specific parts
                    if !parts.empty?

                        # Run docker-compose
                        if "docker-compose" == type || "compose" == type
                            inline += %~
                                echo -e "\e[93mRun docker-compose\e[0m"
                            ~
                            container = parts.at(0)
                            entrypoint = !parts.at(1).empty? ? parts.at(1) : "/bin/bash"
                            command = parts.drop(2).join(':')
                            inline += %~
                                echo -e "container: \\\"#{container}\\\", entrypoint: \\\"#{entrypoint}\\\", command: \\\"#{command}\\\""
                                docker-compose run --rm --entrypoint "#{entrypoint}" "#{container}" -c "#{command}"
                            ~

                        # Run ansible-playbook
                        elsif "ansible-playbook" == type || "playbook" == type
                            playbook = !parts.at(0).nil? ? parts.at(0) : "playbook.yml"
                            parts = parts.drop(1)
                            inline += %~
                                echo -e "\e[93mRun ansible-playbook\e[0m"
                                export PYTHONUNBUFFERED=1
                                export ANSIBLE_INVENTORY=/etc/ansible/local-hosts
                                export ANSIBLE_FORCE_COLOR=1
                            ~
                            parts.each do |part|
                                inline += %~
                                    echo "playbook: \\\"#{playbook}\\\""
                                    ansible-playbook "#{playbook}" --connection=local
                                ~
                            end

                        # Run bash with dos2unix
                        elsif "bash" == type || "script" == type
                            inline += %~
                                echo -e "\e[93mRun command (dos2unix)\e[0m"
                            ~
                            parts.each do |part|
                                inline += %~
                                    echo "command: \\\"bash \\\"#{part}\\\"\\\""
                                    bash "#{part}"
                                ~
                                dos2unix.push("echo \\\"#{part}\\\"")
                            end

                        # Run command
                        elsif "run" == type || "command" == type
                            inline += %~
                                echo -e "\e[93mRun command\e[0m"
                            ~
                            parts.each do |part|
                                inline += %~
                                    echo "command: \\\"#{part}\\\""
                                    #{part}
                                ~
                            end

                        # Run anything
                        else
                            inline += %~
                                echo -e "\e[93mRun command\e[0m"
                            ~
                            parts.each do |part|
                                inline += %~
                                    echo "command: \\\"#{type} #{part}\\\""
                                    #{type} #{part}
                                ~
                            end
                        end
                    end

                    # Add once to run provision
                    vm_options['provision'][provision_with] = {
                        "type"=>"shell",
                        "keep_color"=>true,
                        "inline"=>inline,
                        "dos2unix"=>dos2unix
                    }
                end
            end
            break
        end
    end

    # Add provision "report": report versions of installed programs
    vm_options['provision']['report'] = {
        "type"=>"shell",
        "keep_color"=>true,
        "inline"=>%~
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
            if which ansible &> /dev/null; then
              echo -e "\e[92m- $(ansible --version | grep 'ansible')\e[0m";
            else
              echo -e "\e[91m- ansible not found\e[0m";
            fi
            if which docker &> /dev/null; then
              echo -e "\e[92m- $(docker --version | sed 's/^Docker version /docker /g') ($(docker info 2>/dev/null | sed -n -e '/Containers:.*/,/Images:.*/p' | sed ':a;N;s/\\n/, /g'))\e[0m";
            else
              echo -e "\e[91m- docker not found\e[0m";
            fi
            if which docker-compose &> /dev/null; then
              echo -e "\e[92m- $(docker-compose --version | sed 's/OpenSSL version: //g' | sed 's/version: //g' | sed ':a;N;$!ba;s/\\n/, /g')\e[0m";
            else
              echo -e "\e[91m- docker-compose not found\e[0m";
            fi
            # TODO add docker report
        ~
    }

    # Load vm configuration
    if !vm_options.empty?

        vm_options.each do |vm_name, vm_value|

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
                            # TODO make it possible to use the nfs special options
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
                        if !provision_config['path'].nil? && !provision_config['dos2unix'].nil?
                            provision_config['inline'] = "bash " + provision_config['path'].sub!(/^\.\//, '\/env\/')
                            provision_config.delete('path')
                        end
                        if !provision_config['dos2unix'].nil? && provision_config['dos2unix'].any?
                            script = %~
                                if [ $(dpkg-query -W -f='${Status}' dos2unix 2>/dev/null | grep -c "ok installed") -eq 0 ]; then
                                    echo -e "\e[93mInstall dos2unix\e[0m"
                                    apt-get install -y dos2unix
                                fi
                                FILES=""
                            ~
                            provision_config['dos2unix'].each do |dos2unix_item|
                                script += %~
                                    FILES=$(echo -e "${FILES}\n$(#{dos2unix_item} | xargs --no-run-if-empty file | grep CRLF | sed -E 's/:.*$//')")
                                ~
                            end
                            script += %~
                                if test -n "${FILES}"; then
                                    echo -e "\e[93mConvert line endings from dos to unix\e[0m"
                                    SAVEIFS=$IFS
                                    IFS=$(echo -en "\n\b")
                                    for FILE in ${FILES}; do
                                        dos2unix --keepdate \"${FILE}\" 2>&1 | tr -d "\n"
                                    done
                                    IFS=$SAVEIFS
                                fi
                                #{provision_config['inline']}
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
                            provision_config['inline'] = script
                        end
                        if provision_config['windows_only'].nil? || !provision_config['windows_only'] || (provision_config['windows_only'] && Vagrant::Util::Platform.windows?)
                            run = !provision_config['run'].nil? && !provision_config['run'].empty? ? provision_config['run'] : nil
                            vagrant_config.vm.provision "#{provision_name}", type: "#{provision_config['type']}", run: run do |provision|
                                provision_config.each do |provision_config_key, provision_config_value|
                                    if 'type' == provision_config_key or 'windows_only' == provision_config_key or 'run' == provision_config_key or 'dos2unix' == provision_config_key
                                        next
                                    end
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
    if !ssh_options.empty?
        ssh_options.each do |ssh_name, ssh_value|
            if !ssh_value.nil?
                vagrant_config.ssh.send("#{ssh_name}=", "#{ssh_value}")
            end
        end
    end

end