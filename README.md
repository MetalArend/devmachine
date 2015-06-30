DevMachine
==========

A combination of vagrant, shell scripts and docker containers, to create an os-independant, easy-to-use development machine for developers and designers.

(CC BY-SA 4.0) 2014 MetalArend


Recommended:
If you use windows, we recommend adding the following vagrant plugins:

https://github.com/GM-Alex/vagrant-winnfsd
$ vagrant plugin install vagrant-winnfsd

Install Cygwin, make sure to install rsync and ssh from the list, and add the path to the Cygwin bin directory to your PATH.
https://cygwin.com/cygwin-ug-net/using.html#cygdrive
https://github.com/mitchellh/vagrant/issues/3230#issuecomment-37757086
http://answers.microsoft.com/en-us/insider/forum/insider_wintp-insider_devices/virtualbox-4322-installing-guest-additions-breaks/473dd881-336b-43d9-9aac-6c1cb81a87b5
http://www.pixelninja.me/cannot-create-virtual-environment-in-vagrant-in-windows-8-1/
http://stackoverflow.com/questions/19689632/vagrant-errors-after-windows-8-1-update


Use Cygwin with rsync and ssh
Virtualbox 4.3.20.r96997
Vagrant 1.7.2
vagrant-share (1.1.3, system)
vagrant-winnfsd (1.0.11)


docker-compose stop && docker-compose rm -f && docker-compose build && docker-compose up -d
