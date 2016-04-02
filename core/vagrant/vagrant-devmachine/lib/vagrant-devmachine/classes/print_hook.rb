module VagrantPlugins::DevMachine
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
end