module VagrantPlugins::DevMachine
    class CleanCache

        def initialize(app, env)
            @app = app
        end

        def call(env)
            # Requirements
            require 'fileutils'
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
end