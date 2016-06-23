DevMachine
==========

A combination of shell scripts and docker containers, to create an os-independant, easy-to-use development machine for developers and designers.

(CC BY-SA 4.0) 2014-2015 MetalArend

## Instructions:

	- (All) Install Virtualbox 4.3.20.r96997 from https://www.virtualbox.org/wiki/Download_Old_Builds_4_3_pre24
	- (All) Install Vagrant 1.7.2 from http://www.vagrantup.com/downloads.html

	- (Windows) Install vagrant-winnfsd (1.0.11) from https://github.com/GM-Alex/vagrant-winnfsd
        ```bash
        $ vagrant plugin install vagrant-winnfsd
        ```
	- (Windows) Install commandline tool
		- Or install Gow from https://github.com/bmatzelle/gow
		- Or install Cygwin from https://cygwin.com/install.html
    		- make sure to install rsync and ssh as well
    		- add the path to the Cygwin bin directory to your PATH


## Windows documentation:

    - Windows 8.1: in an elevated Command Prompt, disable Hyper-V by running the command: "dism.exe /Online /Disable-Feature:Microsoft-Hyper-V-All" (and restart host)
	- https://cygwin.com/cygwin-ug-net/using.html#cygdrive
    - https://github.com/mitchellh/vagrant/issues/3230#issuecomment-37757086
    - http://answers.microsoft.com/en-us/insider/forum/insider_wintp-insider_devices/virtualbox-4322-installing-guest-additions-breaks/473dd881-336b-43d9-9aac-6c1cb81a87b5
    - http://www.pixelninja.me/cannot-create-virtual-environment-in-vagrant-in-windows-8-1/
    - http://stackoverflow.com/questions/19689632/vagrant-errors-after-windows-8-1-update

## Special provision:

    ```bash
	$ vagrant provision --provision-with cd:"<directory>"
	$ vagrant provision --provision-with project:"<directory>", where <directory> may be inside "/env/workspace"
	
	$ vagrant provision --provision-with docker-compose:<container>:"<entrypoint>":"<command>" (alias: compose)
	$ vagrant provision --provision-with ansible-playbook:"<playbook>".. (alias: playbook)
	$ vagrant provision --provision-with run:"<command>".. (alias: command)
	$ vagrant provision --provision-with bash:"<script>".. with dos2unix conversion (alias: script)
	$ vagrant provision --provision-with <program>:"<command>"..
	```
