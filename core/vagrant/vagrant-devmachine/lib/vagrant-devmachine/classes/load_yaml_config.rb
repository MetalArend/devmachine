module VagrantPlugins::DevMachine
    class LoadYamlConfig

        def self.load(config_path)
            require 'yaml'

            # Load configuration
            merger = proc { |_,x,y| x.is_a?(Hash) && y.is_a?(Hash) ? x.merge(y, &merger) : y }
            default_config = (YAML::load_file(File.expand_path('defaults.yml', File.dirname(__FILE__))) rescue {}) || {}
            user_config = (YAML::load_file(config_path) rescue {}) || {}
            yaml_config = default_config.merge(user_config, &merger)

            # Save optimized configuration (for inspection)
            File.open(File.expand_path('devmachine.opt.yml', File.dirname(config_path)),'w') do |file| # TODO set perm too
                file.write yaml_config.to_yaml
            end

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

            return yaml_config
        end

    end
end