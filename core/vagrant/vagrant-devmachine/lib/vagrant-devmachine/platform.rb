module VagrantPlugins::DevMachine
    require 'rbconfig'

    AVAILABLE_PLATFORMS = [:windows, :mac, :linux, :unix, :unknown, :all]
    PLATFORM ||= (
    host_os = RbConfig::CONFIG['host_os']
    case
        when ENV['OS'] == 'Windows_NT'
            :windows
        when host_os =~ /mswin|msys|mingw|cygwin|bccwin|wince|emc/
            :windows
        when host_os =~ /darwin|mac os/
            :mac
        when host_os =~ /linux/
            :linux
        when host_os =~ /solaris|bsd/
            :unix
        else
            :unknown
    end
    )
end