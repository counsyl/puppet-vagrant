vagrant
=======

This Puppet module installs the Vagrant software package from the releases
provided by the [Vagrant downloads](https://www.vagrantup.com/downloads.html) page.

To install vagrant, simply use the following in your manifests:

```puppet
include vagrant
```

To install a Vagrant [plugin](http://docs.vagrantup.com/v2/plugins/index.html),
use the `vagrant::plugin` defined type.  For example, to install the
[`vagrant-windows`](https://github.com/WinRb/vagrant-windows) plugin, you'd
use the following in your manifest:

```puppet
vagrant::plugin { 'vagrant-windows': }
```

License
-------

Apache License, Version 2.0

Contact
-------

Justin Bronn <justin@counsyl.com>

Support
-------

Please log tickets and issues at https://github.com/counsyl/puppet-vagrant
