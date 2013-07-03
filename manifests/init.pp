# == Class: vagrant
#
# Installs Vagrant, which creates reproducible development environments.
#
# === Parameters
#
# [*ensure*]
#  The ensure value for the package resource, defaults to 'installed'.
#
# [*version*]
#  The version of Vagrant to install, defaults to '1.2.2'.  If you are
#  change this, you will have likely have to modify the `download_url`
#  parameter as well.
#
# [*download_url*]
#  The base URL to retrieve the Vagrant package, defaults to a URL that
#  is specific to the version on 'http://files.vagrantup.com/packages/'.
#
class vagrant(
  $ensure       = 'installed',
  $version      = '1.2.2',
  $download_url = 'http://files.vagrantup.com/packages/7e400d00a3c5a0fdf2809c8b5001a035415a607b/',
) {
  # Setting up properties for the package.
  case $::osfamily {
    darwin: {
      $package = "vagrant-${version}"
      $package_basename = "Vagrant-${version}.dmg"
      $provider = 'pkgdmg'
      $download = false
    }
    debian: {
      $package = 'vagrant'
      if $::architecture == 'amd64' {
        $arch = 'x86_64'
      } else {
        $arch = 'i686'
      }
      $package_basename = "vagrant_${version}_${arch}.deb"
      $provider = 'dpkg'
      $download = true
    }
    redhat: {
      $package = 'vagrant'
      if $::architecture == 'amd64' {
        $arch = 'x86_64'
      } else {
        $arch = 'i686'
      }
      $package_basename = "vagrant_${version}_${arch}.rpm"
      $provider = 'yum'
      $download = true
    }
    default: {
      fail("Do not know how to install Vagrant on ${::osfamily}!\n")
    }
  }

  # Are we going to have to download the package prior to installation?
  $package_url = "${download_url}${package_basename}"
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
