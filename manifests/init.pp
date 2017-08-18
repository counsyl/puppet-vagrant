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
#  The version of Vagrant to install, defaults to '1.9.7'.
#
# [*cache*]
#  On Linux systems, location to store the downloaded Vagrant package,
#  defaults to '/var/cache/vagrant'.
#
# [*download*]
#  Whether or not to download the package, default is platform dependent.
#
# [*package*]
#  The name of the package resource; default is platform dependent, e.g.,
#  'vagrant' or 'vagrant-1.7.4'.
#
# [*package_basename*]
#  The basename of the package; default is platform dependent, e.g.,
#  'vagrant_1.7.4_x86_64.rpm'.
#
# [*package_url*]
#  The URL to download the package from, must reference the same file
#  as `package_basename`.
#
# [*provider*]
#  The provider of the package resource, the default is platform dependent.
#
# [*source*]
#  The source of the package resource, the default is platform dependent.
#
class vagrant(
  $ensure           = 'installed',
  $version          = $vagrant::params::version,
  $cache            = $vagrant::params::cache,
  $download         = $vagrant::params::download,
  $package          = $vagrant::params::package,
  $package_basename = $vagrant::params::package_basename,
  $package_url      = $vagrant::params::package_url,
  $provider         = $vagrant::params::provider,
  $source           = $vagrant::params::source,
) inherits vagrant::params {

  # If we're downloading the package, then it's source will be from the local
  # file system.  For those package providers that do the downloading (e.g.,
  # OS X) then the source is just the package URL.
  if $source {
    $package_source = $source
  } elsif $download {
    $package_source = "${cache}/${package_basename}"
  } else {
    $package_source = $package_url
  }

  # Are we going to have to download the package prior to installation?
  if $download and $ensure in ['installed', 'present'] {
    # Place packages in `/var/cache/vagrant`.
    file { $cache:
      ensure => directory,
      owner  => 'root',
      group  => 'root',
      mode   => '0644',
    }

    # Download package before trying to install it.
    sys::fetch { 'download-vagrant':
      source      => $package_url,
      destination => $package_source,
      require     => File[$cache],
      before      => Package[$package],
    }
  }

  # The Vagrant package resource.
  package { $package:
    ensure   => $ensure,
    provider => $provider,
    source   => $package_source,
  }
}
