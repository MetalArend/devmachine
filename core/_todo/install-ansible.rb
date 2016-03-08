            # Add provision "system": install ansible and run playbook
            ansible_version = $yaml_config['devmachine']['ansible']['version']
            ansible_playbook = $yaml_config['devmachine']['ansible']['playbook']
            ansible_extra_vars = $yaml_config['devmachine']['ansible']['extra_vars'].map { |key, value| [key.to_sym, '\"' + value + '\"'] * "=" } * " "
            node.vm.provision "system", type: "shell", keep_color: true, run: "always", inline: %~
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