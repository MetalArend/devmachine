# coding: utf-8
require_relative 'lib/vagrant-devmachine/version'

Gem::Specification.new do |spec|
    spec.name          = 'vagrant-devmachine'
    spec.version       = VagrantPlugins::DevMachine::VERSION
    spec.authors       = ['Bart Reunes']
    spec.email         = ['metalarend@gmail.com']
    spec.description   = %q{a development machine}
    spec.summary       = spec.description
    spec.homepage      = ''
    spec.license       = 'none yet' # MIT, Apache 2.0

    spec.files         = `git ls-files`.split($/)
    spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
    spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
    spec.require_paths = ['lib']

    spec.required_ruby_version = '>= 1.9.3'

    spec.post_install_message = <<-EOH
DevMachine is now ready to go!
    EOH

    spec.add_development_dependency 'bundler', "~> 1.3"
    spec.add_development_dependency 'rake'
end