# TODO auto-update DevMachine? (only when internet is available)
# https://www.vagrantup.com/docs/plugins/development-basics.html
# TODO nice errors

# module VagrantPlugins::DevMachine
#     lib_path = Pathname.new(File.expand_path("../vagrant-devmachine", __FILE__))
#     autoload :Errors, lib_path.join("errors")
# end

begin
    require 'vagrant'
rescue LoadError
    raise 'This plugin must be run within Vagrant.'
end

require_relative 'vagrant-devmachine/version'
require_relative 'vagrant-devmachine/platform'
require_relative 'vagrant-devmachine/errors'
require_relative 'vagrant-devmachine/plugin'
