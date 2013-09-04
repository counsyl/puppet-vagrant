# == Class: vagrant::params
#
# Platform-independent parameters for Vagrant.
#
class vagrant::params {
  # Setting up properties for the package.
  if $::architecture == 'amd64' {
    $arch = 'x86_64'
  } else {
    $arch = 'i686'
  }

  # The version of Vagrant to install.
  $version  = '1.2.7'

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
  # to a hash -- this is the $base_url parameter.
  $base_url = 'http://files.vagrantup.com/packages/7ec0ee1d00a916f80b109a298bab08e391945243/'
  $package_url = "${base_url}${package_basename}"

  if $download {
    $source = "${cache}/${package_basename}"
  } else {
    $source = $package_url
  }
}
