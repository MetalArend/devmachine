module VagrantPlugins::DevMachine
    class AssureEnvironment

        def initialize(app, env)
            @app = app
            @config = nil
            if !env[:machine].nil?
                @config = env[:machine].config.devmachine
            end
        end

        def call(env)
            if @config.nil?
                @app.call(env)
                return
            end

            cwd = env[:root_path]
            env_home_path = ENV['VAGRANT_HOME']
            env_local_data_path = ENV['VAGRANT_DOTFILE_PATH']
            home_path = (! ENV['VAGRANT_HOME'].nil? ? ENV['VAGRANT_HOME'] : File.expand_path(@config.home_path, cwd))
            local_data_path = (! ENV['VAGRANT_DOTFILE_PATH'].nil? ? ENV['VAGRANT_DOTFILE_PATH'] : File.expand_path(@config.local_data_path, cwd))

            #                 env[:ui].info("environment: #{env_home_path} / #{home_path}")
            #                 env[:ui].info("environment: #{env_local_data_path} / #{local_data_path}")

            # Assure environment variables are set
            if home_path != ENV['VAGRANT_HOME'] or local_data_path != ENV['VAGRANT_DOTFILE_PATH']
                # TODO also cleanup default vagrant path
                # TODO make cleanup command
                if ENV['VAGRANT_DOTFILE_PATH'].nil?
                    Dir.chdir(File.expand_path('.vagrant', cwd)) { Dir.glob('{.,**/*}').map {|path| File.expand_path(path) }.select { |dir| File.directory? dir }.reverse_each { |dir| Dir.rmdir dir if (Dir.entries(dir) - %w[ . .. ]).empty? } }
                end
                env[:ui].info("Setting environment with:")
                env[:ui].info("  VAGRANT_HOME=#{home_path}")
                env[:ui].info("  VAGRANT_DOTFILE_PATH=#{local_data_path}")
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
                # TODO make it possible to have multiple platforms to install to
                require_relative 'load_yaml_config.rb'
                yaml_config = VagrantPlugins::DevMachine::LoadYamlConfig::load(File.expand_path('devmachine.yml', env[:root_path]))
                plugins = (yaml_config['devmachine']['plugins'] rescue {}) || {}
                plugins_for_platform = plugins.select { |plugin, desired_platform| AVAILABLE_PLATFORMS.include? desired_platform.to_sym and (desired_platform.to_sym == PLATFORM or desired_platform.to_sym == :all) }
                plugins_to_install = plugins_for_platform.select { |plugin, desired_platform| not Vagrant.has_plugin? plugin }
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
                        # TODO make sure environment is set
                        exec "vagrant #{ARGV.join' '}"
                    end
                end
                @app.call(env)
            end
        end

    end
end