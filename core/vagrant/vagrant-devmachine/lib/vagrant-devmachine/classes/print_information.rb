module VagrantPlugins::DevMachine
    class PrintInformation

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

            # Branding
            branding = ((env[:machine].config.devmachine.branding + "\n") rescue "") + "(CC BY-SA 4.0) 2016 MetalArend"
            env[:ui].success(branding)

            # Paths
            # As the environment will always be the same for the whole Vagrantfile, this should be okay for multiple vms
            env[:machine_index].each do |entry|
                if entry.name == env[:machine].name.to_s
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
end