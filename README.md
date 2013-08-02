Grafter
=======

A tool to create, configure, and manage root filesystems.

Development
-----------

Grafter is a gem, located in `./grafter` that needs to run on a linux host.
Provided is a Vagrantfile and chef configuration to provision an Ubuntu host to create both yum and debian based root filesystems.
The Vagrantfile requires the `vagrant-berkshelf` and `vagrant-omnibus` plugins.
To setup run the following

    vagrant plugin install vagrant-berkshelf
    vagrant plugin install vagrant-omnibus
    vagrant up
    vagrant ssh
    $ sudo -i
    > grafter help

Since the vagrant box is configured to use the source file located in `./grafter`,
running `grafter` inside the vagrant box will use the latest code from outside.

Grafter itself does not rely on vagrant but instead requies `yum` and/or `debootstrap`.
