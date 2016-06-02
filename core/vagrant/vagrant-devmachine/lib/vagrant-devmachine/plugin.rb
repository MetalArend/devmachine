module VagrantPlugins::DevMachine
    class Plugin < Vagrant.plugin('2')

        name "vagrant-devmachine"
        description <<-DESC
            DevMachine
        DESC

        config "devmachine" do
            require_relative 'config'
            Config
        end

        require_relative 'classes/print_hook'
        require_relative 'classes/print_information'
        require_relative 'classes/assure_environment'
        require_relative 'classes/clean_cache'

        # https://www.vagrantup.com/docs/plugins/action-hooks.html
        action_hook(:print_information, :authenticate_box_url) do |hook|
            # Assure environment - prepend before anything else
            hook.prepend(AssureEnvironment)
        end
        action_hook(:install_plugins, :machine_action_up) do |hook|
            # Assure environment - prepend before anything else
            hook.prepend(AssureEnvironment)
            # Print information (including branding)
            hook.append(PrintInformation)
        end
        action_hook(:install_plugins, :machine_action_reload) do |hook|
            # Assure environment - prepend before anything else
            hook.prepend(AssureEnvironment)
            # Print information (including branding)
            hook.append(PrintInformation)
        end
        action_hook(:install_plugins, :machine_action_provision) do |hook|
            # Assure environment - prepend before anything else
            hook.prepend(AssureEnvironment)
            # Print information (including branding)
            hook.append(PrintInformation)
        end
        action_hook(:install_plugins, :machine_action_ssh) do |hook|
            # Assure environment - prepend before anything else
            hook.prepend(AssureEnvironment)
            # Print information (including branding)
            hook.append(PrintInformation)
        end
        action_hook(:clean_cache, :machine_action_destroy) do |hook|
            # Clean cache after destroy
            hook.prepend(CleanCache)
            # Assure environment - prepend before anything else
            hook.prepend(AssureEnvironment)
        end
        # Print hooks
        # action_hook(self::ALL_ACTIONS) do |hook|
        #     hook.prepend(DevMachine::PrintHook)
        # end

    end
end