# == Class: vagrant
#
# Installs Vagrant, which manages reproducible development environments.
#
# Note: This does not use OS-packaged versions of Vagrant, but rather
# the versions from vagrantup.com -- which are compatible with proprietary
# plugins, like the VMware Fusion provider.
#
# === Parameters
#
# [*ensure*]
#  The ensure value for the package resource, defaults to 'installed'.
#
# [*version*]
#  The version of Vagrant to install, defaults to '1.2.7'.  If you are
#  change this, you will have to modify the `base_url` parameter accordingly.
#
# [*base_url*]
#  The base URL to retrieve the Vagrant package, defaults to a URL that
#  is specific to the version on 'http://files.vagrantup.com/packages/'.
#  This value should include a trailing slash ('/').
#
# [*cache*]
#  On Linux systems, location to store the downloaded Vagrant package,
#  defaults to '/var/cache/vagrant'.
#
# [*download*]
#  Whether or not to download the package, default is platform dependent.
#
# [*source*]
#  The source of the package resource, the default is platform dependent.
#
class vagrant(
  $ensure   = 'installed',
  $version  = $vagrant::params::version,
  $base_url = $vagrant::params::base_url,
  $cache    = $vagrant::params::cache,
  $download = $vagrant::params::download,
  $source   = $vagrant::params::source,
) inherits vagrant::params {
  # Are we going to have to download the package prior to installation?
  if $download and $ensure in ['installed', 'present'] {
    include sys::wget

    # Place packages in `/var/cache/vagrant`.
    file { $cache:
      ensure => directory,
      owner  => 'root',
      group  => 'root',
      mode   => '0644',
    }

    # Download package before trying to install it.
    exec { 'download-vagrant':
      command => "${sys::wget::path} ${package_url}",
      cwd     => $cache,
      creates => $source,
      require => File[$cache],
      before  => Package[$package],
    }
  }

  # The Vagrant package resource.
  package { $package:
    ensure   => $ensure,
    provider => $provider,
    source   => $source,
  }
}
