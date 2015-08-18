# == Class: vagrant::params
#
# Platform-dependent parameters for Vagrant.
#
class vagrant::params {
  # Setting up properties for the package.
  if $::architecture == 'amd64' {
    $arch = 'x86_64'
  } else {
    $arch = 'i686'
  }

  # The version of Vagrant to install.
  $version = '1.7.4'

  # Where to cache Vagrant package downloads, if necessary.
  $cache = '/var/cache/vagrant'

  case $::osfamily {
    'Darwin': {
      $package = "vagrant-${version}"
      $package_basename = "vagrant_${version}.dmg"
      $provider = 'pkgdmg'
      $download = false
    }
    'Debian': {
      $package = 'vagrant'
      $package_basename = "vagrant_${version}_${arch}.deb"
      $provider = 'dpkg'
      $download = true
    }
    'RedHat': {
      $package = 'vagrant'
      $package_basename = "vagrant_${version}_${arch}.rpm"
      $provider = 'rpm'
      $download = true
    }
    default: {
      fail("Do not know how to install Vagrant on ${::osfamily}!")
    }
  }

  # The download URL for Vagrant.
  $base_url = 'https://dl.bintray.com/mitchellh/vagrant/'
  $package_url = "${base_url}${package_basename}"
}
