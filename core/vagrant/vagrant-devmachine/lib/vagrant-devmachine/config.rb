module VagrantPlugins::DevMachine
    class Config < Vagrant.plugin('2', :config)
        attr_accessor :config_path

        def initialize
            @config_path = UNSET_VALUE
        end

        # def merge(other)
        # end

        def finalize!
            @config_path = 'devmachine.yml' if @config_path == UNSET_VALUE
        end

        def validate(machine)
            errors = _detected_errors

            unless config_path.is_a?(String) || config_path.nil?
                errors << ':config_path needs to be a string or nil'
            end

            { "devmachine" => errors }
        end

    end
end