# == Class: vagrant::params
#
# Platform-dependent parameters for Vagrant.
#
class vagrant::params {
  # Setting up properties for the package.
  if ($::architecture == 'amd64' or $::architecture == 'x86_64') {
    $arch = 'x86_64'
  } else {
    $arch = 'i686'
  }

  # The version of Vagrant to install.
  $version = hiera('vagrant::version', '1.7.4')

  # Where to cache Vagrant package downloads, if necessary.
  $cache = '/var/cache/vagrant'

  case $::osfamily {
    'Darwin': {
      $package = "vagrant-${version}"
      if versioncmp($version, '1.9.2') > 0 {
        # from version 1.9.3 upward, the .dmg includes the architecture
        $package_basename = "vagrant_${version}_${arch}.dmg"
      }
      else {
        $package_basename = "vagrant_${version}.dmg"
      }
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
  $base_url = hiera(
      'vagrant::package_url', 'https://releases.hashicorp.com/vagrant/')
  $package_url = "${base_url}${version}/${package_basename}"
}
