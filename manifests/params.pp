# == Class: vagrant::params
#
# Platform-dependent parameters for Vagrant.
#
class vagrant::params {
  # Setting up properties for the package.
  if ($facts['os']['architecture'] == 'amd64' or $facts['os']['architecture'] == 'x86_64') {
    $arch = 'x86_64'
  } else {
    $arch = 'i686'
  }

  # The version of Vagrant to install.
  $version = lookup('vagrant::version', { default_value => '2.2.5' })

  # Where to cache Vagrant package downloads, if necessary.
  $cache = '/var/cache/vagrant'

  $version_without_release = split($version,'-')[0]

  case $facts['os']['family'] {
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
      if versioncmp($version_without_release, '2.3') >= 0 {
        $package_basename = "vagrant-${version}.${arch}.rpm"
      } else {
        $package_basename = "vagrant_${version}_${arch}.rpm"
      }
      $provider = 'rpm'
      $download = true
    }
    default: {
      fail("Do not know how to install Vagrant on ${facts['os']['family']}!")
    }
  }

  # The download URL for Vagrant.
  $base_url = lookup(
    'vagrant::package_url',
    { default_value => 'https://releases.hashicorp.com/vagrant/' }
  )
  $package_url = "${base_url}${version_without_release}/${package_basename}"
}
