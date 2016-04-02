# TODO auto-update DevMachine? (only when internet is available)
# https://www.vagrantup.com/docs/plugins/development-basics.html
# TODO nice errors

require 'rbconfig'
require 'yaml'
require 'fileutils'

module VagrantPlugins

    module DevMachine

        class LoadYamlConfig

            def self.load(config_path)

                # Load configuration
                merger = proc { |_,x,y| x.is_a?(Hash) && y.is_a?(Hash) ? x.merge(y, &merger) : y }
                default_config = (YAML::load_file(File.expand_path('default.yml', File.dirname(__FILE__))) rescue {}) || {}
                user_config = (YAML::load_file(config_path) rescue {}) || {}
                yaml_config = default_config.merge(user_config, &merger)

                # Optimize configuration
                yaml_config['devmachine'] = !yaml_config['devmachine'].nil? ? yaml_config['devmachine'] : default_config['devmachine']
                ## Hostname
                if yaml_config['devmachine']['hostname'].nil?
                    yaml_config['devmachine']['hostname'] = "#{`hostname`[0..-2]}".sub(/\..*$/,'')+"-devmachine" rescue "devmachine"
                end
                ## Plugins
                # TODO make it possible to have multiple platforms to install to
                plugins = (yaml_config['devmachine']['plugins'] rescue {}) || {}
                plugins_to_install = plugins.select { |plugin, desired_platform| AVAILABLE_PLATFORMS.include? desired_platform.to_sym and (desired_platform.to_sym == PLATFORM or desired_platform.to_sym == :all) }
                yaml_config['devmachine']['plugins'] = plugins_to_install
                ## Vagrant Home
                if yaml_config['devmachine']['directories']['home_path'].nil?
                    yaml_config['devmachine']['directories']['home_path'] = 'cache'
                elsif false == yaml_config['devmachine']['directories']['home_path']
                    # Taken from the Vagrant source: check for USERPROFILE on Windows, for compatibility
                    if ENV["USERPROFILE"]
                        yaml_config['devmachine']['directories']['home_path'] = "#{ENV["USERPROFILE"]}/.vagrant.d"
                    else
                        yaml_config['devmachine']['directories']['home_path'] = '~/.vagrant.d'
                    end
                end
                ## Vagrant Dotfile Path
                if yaml_config['devmachine']['directories']['local_data_path'].nil?
                    yaml_config['devmachine']['directories']['local_data_path'] = 'cache'
                elsif false == yaml_config['devmachine']['directories']['local_data_path']
                    yaml_config['devmachine']['directories']['local_data_path'] = '.vagrant'
                end

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

        class PrintHook

            def initialize(app, env)
                @app = app
            end

            def call(env)
                env[:ui].info("before hook #{env[:action_name]}")
                @app.call(env)
                env[:ui].info("after hook #{env[:action_name]}")
            end

        end

        class AssureEnvironment

            def initialize(app, env)
                @app = app
            end

            def call(env)
                yaml_config = VagrantPlugins::DevMachine::LoadYamlConfig::load(File.expand_path('devmachine.yml', env[:root_path]))

                cwd = env[:root_path]
                env_home_path = ENV['VAGRANT_HOME']
                env_local_data_path = ENV['VAGRANT_DOTFILE_PATH']
                home_path = (! ENV['VAGRANT_HOME'].nil? ? ENV['VAGRANT_HOME'] : File.expand_path(yaml_config['devmachine']['directories']['home_path'], cwd))
                local_data_path = (! ENV['VAGRANT_DOTFILE_PATH'].nil? ? ENV['VAGRANT_DOTFILE_PATH'] : File.expand_path(yaml_config['devmachine']['directories']['local_data_path'], cwd))

                # TODO use env.setup_home_path
                # TODO use env.setup_local_data_path

#                 env[:ui].info("environment: #{env_home_path} / #{home_path}")
#                 env[:ui].info("environment: #{env_local_data_path} / #{local_data_path}")

                # Assure environment variables are set
                if home_path != ENV['VAGRANT_HOME'] or local_data_path != ENV['VAGRANT_DOTFILE_PATH']
                    # TODO also cleanup default vagrant path
                    # TODO make cleanup command
                    if ENV['VAGRANT_DOTFILE_PATH'].nil?
                        Dir.chdir(File.expand_path('.vagrant', yaml_config['devmachine']['cwd'])) { Dir.glob('{.,**/*}').map {|path| File.expand_path(path) }.select { |dir| File.directory? dir }.reverse_each { |dir| Dir.rmdir dir if (Dir.entries(dir) - %w[ . .. ]).empty? } }
                    end
                    env[:ui].info("Assuring environment...")
                    ENV['VAGRANT_HOME'] = home_path
                    ENV['VAGRANT_DOTFILE_PATH'] = local_data_path
                    # TODO restart vagrant with all VAGRANT_ variables that are already present
                    # TODO also set VAGRANT_CWD
                    if PLATFORM == :windows
                        exec "SET \"VAGRANT_HOME=#{home_path}\" && SET \"VAGRANT_DOTFILE_PATH=#{local_data_path}\" && vagrant #{ARGV.join' '}"
                    else
                        exec "export VAGRANT_HOME=#{home_path} && export VAGRANT_DOTFILE_PATH=#{local_data_path} && vagrant #{ARGV.join' '}"
                    end
                else
                    @app.call(env)
                end
            end

        end

        class PrintInformation

            def initialize(app, env)
                @app = app
            end

            def call(env)
                yaml_config = VagrantPlugins::DevMachine::LoadYamlConfig::load(File.expand_path('devmachine.yml', env[:root_path]))

                # Branding
                branding = (yaml_config['devmachine']['branding'] + "\n" rescue "") + "(CC BY-SA 4.0) 2016 MetalArend"
                env[:ui].success(branding)

                # Paths
                # As the environment will always be the same for the whole Vagrantfile, this should be okay for multiple vms
                env[:machine_index].each do |entry|
                    if !env[:machine].nil? && entry.name == env[:machine].name.to_s
                        env[:ui].info("machine: " + entry.name)
                        vagrantfile_path = entry.vagrantfile_path.to_s
                        home_path = env[:home_path].to_s
                        # if home_path != File.expand_path('cache', vagrantfile_path)
                            env[:ui].info("home_path: " + Pathname.new(home_path).relative_path_from(Pathname.new(vagrantfile_path)).to_s)
                        # end
                        local_data_path = entry.local_data_path.to_s
                        # if local_data_path != File.expand_path('cache', vagrantfile_path)
                            env[:ui].info("local_data_path: " + Pathname.new(local_data_path).relative_path_from(Pathname.new(vagrantfile_path)).to_s)
                        # end
                    end
                end

                env[:ui].info("\n")
                @app.call(env)
            end

        end

        class InstallPlugins

            def initialize(app, env)
                @app = app
            end

            def call(env)
                yaml_config = VagrantPlugins::DevMachine::LoadYamlConfig::load(File.expand_path('devmachine.yml', env[:root_path]))

                plugins = yaml_config['devmachine']['plugins'] rescue {}
                plugins_to_install = plugins.select { |plugin, desired_platform| not Vagrant.has_plugin? plugin }
                restart = false
                if not plugins_to_install.empty?
                    env[:ui].info("Installing missing plugins...")
                    plugins_to_install.each do |plugin, desired_platform|
                        if system "vagrant plugin install #{plugin}"
                            restart = true
                        else
                            abort "Installation has failed."
                        end
                    end
                    if true === restart
                        env[:ui].info("Running \"vagrant #{ARGV.join' '}\" again...")
                        exec "vagrant #{ARGV.join' '}"
                    end
                end
                @app.call(env)
            end

        end

        class CleanCache

            def initialize(app, env)
                @app = app
            end

            def call(env)
                # Default settings will have same path for home and local_data, but we'll ignore that for now
                @clean_data_path = env[:machine].data_dir
                @clean_home_path = env[:home_path]
                # As the environment will always be the same for the whole Vagrantfile, this is okay for multiple vms
                env[:machine_index].each do |entry|
                    # Why is local_data_path not a symbol?
                    @clean_local_data_path = entry.local_data_path if entry.name == env[:machine].name.to_s
                end
                @app.call(env)
                # List all directories, including the root folder: {.,**/*}
                # Avoid problems with special characters in path by using chdir and expand_path
                # Use reverse_each to start in the deepest directory, and cleanup empty directories recursively going up
                # Don't check . or .. directories
                if not @clean_home_path.nil? and Dir.exists?(@clean_home_path)
                    Dir.chdir(@clean_home_path) { Dir.glob('{.,**/*}').map {|path| File.expand_path(path) }.select { |dir| File.directory? dir }.reverse_each { |dir| Dir.rmdir dir if (Dir.entries(dir) - %w[ . .. ]).empty? } }
                end
                if not @clean_local_data_path.nil? and Dir.exists?(@clean_local_data_path)
                    Dir.chdir(@clean_local_data_path) { Dir.glob('{.,**/*}').map {|path| File.expand_path(path) }.select { |dir| File.directory? dir }.reverse_each { |dir| Dir.rmdir dir if (Dir.entries(dir) - %w[ . .. ]).empty? } }
                end
                File.delete(File.expand_path('devmachine.opt.yml', env[:root_path]))
            end

        end

        class Plugin < Vagrant.plugin('2')

            name "devmachine"
            description <<-DESC
                DevMachine
            DESC

            config "devmachine" do
                require_relative 'vagrant-devmachine/config'
                Config
            end

            # https://www.vagrantup.com/docs/plugins/action-hooks.html
            action_hook(:print_information, :authenticate_box_url) do |hook|
                # Assure environment - prepend before anything else
                hook.prepend(DevMachine::AssureEnvironment)
            end
            action_hook(:install_plugins, :machine_action_up) do |hook|
                # Assure environment - prepend before anything else
                hook.prepend(DevMachine::AssureEnvironment)
                # Install plugins
                hook.append(DevMachine::InstallPlugins)
                # Print information (including branding)
                hook.append(DevMachine::PrintInformation)
            end
            action_hook(:install_plugins, :machine_action_provision) do |hook|
                # Assure environment - prepend before anything else
                hook.prepend(DevMachine::AssureEnvironment)
                # Install plugins
                hook.append(DevMachine::InstallPlugins)
                # Print information (including branding)
                hook.append(DevMachine::PrintInformation)
            end
            action_hook(:clean_cache, :machine_action_destroy) do |hook|
                # Clean cache after destroy
                hook.prepend(DevMachine::CleanCache)
                # Assure environment - prepend before anything else
                hook.prepend(DevMachine::AssureEnvironment)
            end
            # Print hooks
            # action_hook(self::ALL_ACTIONS) do |hook|
            #     hook.prepend(DevMachine::PrintHook)
            # end

        end

    end

end