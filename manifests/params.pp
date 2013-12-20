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

  # The version of Vagrant to install, and the Git hash of the tagged version.
  $version = '1.4.1'

  # Where to cache Vagrant package downloads, if necessary.
  $cache = '/var/cache/vagrant'

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
      $provider = 'rpm'
      $download = true
    }
    default: {
      fail("Do not know how to install Vagrant on ${::osfamily}!\n")
    }
  }

  # The download URL for Vagrant.
  $base_url = 'https://dl.bintray.com/mitchellh/vagrant/'
  $package_url = "${base_url}${package_basename}"
}
