module VagrantPlugins::DevMachine
    class Config < Vagrant.plugin('2', :config)
        attr_accessor :branding
        attr_accessor :config_path
        attr_accessor :home_path
        attr_accessor :local_data_path

        def initialize
            @branding = UNSET_VALUE
            @config_path = UNSET_VALUE
            @home_path = UNSET_VALUE
            @local_data_path = UNSET_VALUE
        end

        # def merge(other)
        # end

        def finalize!
            # Branding
            default_branding = %q(
                ________            ______  ___            ______ _____
                ___  __ \_______   ____   |/  /_____ _________  /____(_)___________
                __  / / /  _ \_ | / /_  /|_/ /_  __ `/  ___/_  __ \_  /__  __ \  _ \
                _  /_/ //  __/_ |/ /_  /  / / / /_/ // /__ _  / / /  / _  / / /  __/
                /_____/ \___/_____/ /_/  /_/  \__,_/ \___/ /_/ /_//_/  /_/ /_/\___/
            ).gsub(/^\n|\s+$/, '')
            indent = default_branding.split("\n").map { |line| line[/^ +/] }.compact.map(&:size).min
            default_branding = default_branding.split("\n").map { |line| line.gsub(/^\s{#{indent}}/, '') }.join("\n")
            @branding = default_branding if @branding == UNSET_VALUE

            # Config path
            @config_path = 'devmachine.yml' if @config_path == UNSET_VALUE

            # Vagrant Home
            if @home_path == UNSET_VALUE
                @home_path = 'cache'
            elsif nil == @home_path || :default == @home_path
                # Taken from the Vagrant source: check for USERPROFILE on Windows, for compatibility
                if ENV["USERPROFILE"]
                    @home_path = "#{ENV["USERPROFILE"]}/.vagrant.d"
                else
                    @home_path = '~/.vagrant.d'
                end
            end

            # Vagrant Dotfile Path
            if @local_data_path == UNSET_VALUE
                @local_data_path = 'cache'
            elsif nil == @local_data_path || :default == @local_data_path
                @local_data_path = '.vagrant'
            end
        end

        def validate(machine)
            errors = _detected_errors

            # TODO add more checks
            unless config_path.is_a?(String) || config_path.nil?
                errors << ':config_path needs to be a string or nil'
            end

            { "devmachine" => errors }
        end

    end
end