            if Vagrant.has_plugin?("vagrant-triggers") then
                config.trigger.after [:up, :resume] do
                    info "Adjusting datetime after suspend and resume."
                    run_remote "sudo sntp -4sSc pool.ntp.org; date"
                end
            end

            if Vagrant.has_plugin?("vagrant-triggers") then
                config.trigger.after [:up, :resume] do
                    info "Adjusting datetime after suspend and resume."
                    run_remote <<-EOT.prepend("\n")
                        sudo system-docker stop ntp
                        sudo ntpd -n -q -g -I eth0 > /dev/null
                        date
                        sudo system-docker start ntp
                    EOT
                end
            end

            # Adjusting datetime before provisioning.
            config.vm.provision :shell, run: "always" do |sh|
                sh.inline = <<-EOT
                    system-docker stop ntp
                    ntpd -n -q -g -I eth0 > /dev/null
                    date
                    system-docker start ntp
                EOT
            end

            config.vm.provision :docker do |d|
                d.pull_images "busybox"
                d.run "simple-echo",
                    image: "busybox",
                    args: "-p 8080:8080",
                    cmd: "nc -p 8080 -l -l -e echo hello world!"
            end