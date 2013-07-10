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
#  The version of Vagrant to install, defaults to '1.2.3'.  If you are
#  change this, you will have likely have to modify the `base_url`
#  parameter as well.
#
# [*base_url*]
#  The base URL to retrieve the Vagrant package, defaults to a URL that
#  is specific to the version on 'http://files.vagrantup.com/packages/'.
#  This value should include a trailing slash ('/').
#
class vagrant(
  $ensure   = 'installed',
  $version  = '1.2.3',
  $base_url = 'http://files.vagrantup.com/packages/95d308caaecd139b8f62e41e7add0ec3f8ae3bd1/',
) {

  # Setting up properties for the package.
  if $::architecture == 'amd64' {
    $arch = 'x86_64'
  } else {
    $arch = 'i686'
  }

  case $::osfamily {
    darwin: {
      $package = "vagrant-${version}"
      $package_basename = "Vagrant-${version}.dmg"
      $provider = 'pkgdmg'
      $download = false
    }
    debian: {
      $package = 'vagrant'
      $package_basename = "vagrant_${version}_${arch}.deb"
      $provider = 'dpkg'
      $download = true
    }
    redhat: {
      $package = 'vagrant'
      $package_basename = "vagrant_${version}_${arch}.rpm"
      $provider = 'yum'
      $download = true
    }
    default: {
      fail("Do not know how to install Vagrant on ${::osfamily}!\n")
    }
  }

  # Are we going to have to download the package prior to installation?
  $package_url = "${base_url}${package_basename}"
  if $download {
    # Place packages in `/var/cache/vagrant`.
    $cache = '/var/cache/vagrant'
    file { $cache:
      ensure => directory,
      owner  => 'root',
      group  => 'root',
      mode   => '0644',
    }
    $source = "${cache}/${package_basename}"

    # Download package before trying to install it.
    exec { 'download-vagrant':
      command => "/usr/bin/wget ${package_url}",
      cwd     => $cache,
      creates => $source,
      require => File[$cache],
      before  => Package[$package],
    }
  } else {
    $source = $package_url
  }

  # The Vagrant package resource.
  package { $package:
    ensure   => $ensure,
    provider => $provider,
    source   => $source,
  }
}
