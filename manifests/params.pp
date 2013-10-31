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
  $version  = '1.3.5'
  $version_hash = 'a40522f5fabccb9ddabad03d836e120ff5d14093'

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

  # Download URLs, unfortunately Vagrant static download files are tied
  # to the git commit hash of the version tag.  This hash is necessary to
  # construct the $base_url parameter.
  $base_url = "http://files.vagrantup.com/packages/${version_hash}/"
  $package_url = "${base_url}${package_basename}"
}
