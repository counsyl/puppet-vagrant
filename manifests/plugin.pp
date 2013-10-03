# == Define: vagrant::plugin
#
# Installs a Vagrant plugin.
#
# === Parameters
#
# [*name*]
#  Required, the name of the Vagrant plugin to install.
#
# [*ensure*]
#  Ensure value for the Vagrant plugin, default is 'installed'.
#
# [*version*]
#  Version of the Vagrant plugin to install, default is undefined.
#
# [*source*]
#  The source of the plugin, may be a URL to a RubyGems server or a
#  path to a gem local gem file.
#
# [*cwd*]
#  The current working directory for the `exec` resource that installs
#  the Vagrant plugin, default is undefined.
#
# [*environment*]
#  The environment parameter for the `exec` resource that installs the
#  Vagrant plugin, default is undefined.
#
# [*user*]
#  The user to install the plugin for, by default this is undefined and
#  will result in the plugin being installed for the root user.
#
define vagrant::plugin(
  $ensure      = 'installed',
  $version     = undef,
  $source      = undef,
  $cwd         = undef,
  $environment = undef,
  $user        = undef,
) {
  # If the source is a gem file, then we have to tell `vagrant plugin install`
  # to use the file instead of $name.
  if $source =~ /-(\d+\..+)\.gem$/ {
    $gem = true
    $plugin_name = $source
  } else {
    $gem = false
    $plugin_name = $name
  }

  # If an actual gem repository source is used, then add the `--plugin-source`
  # argument.
  if $source and ! $gem {
    $plugin_source = "--plugin-source ${source}"
  } else {
    $plugin_source = ''
  }

  # Add `--plugin-version` argument if not using a gem source.
  if $version and ! $gem {
    $plugin_version = "--plugin-version ${version}"
  } else {
    $plugin_version = ''
  }

  if $version {
    $plugin_exists = "vagrant plugin list | grep '^${name} (${version})$'"
  } else {
    $plugin_exists = "vagrant plugin list | grep '^${name} '"
  }

  # If the plugin is for a specific user, then their entire profile needs
  # to be loaded -- thus a `su -` is required.
  if $user {
    $prefix = "su - ${user} "
  } else {
    $prefix = ''
  }

  # Constructing the plugin commands depending on the ensure value.
  case $ensure {
    'installed', 'present': {
      $unless = $plugin_exists
      $onlyif = undef
      $plugin_options = join([$plugin_source, $plugin_version], " ")
      $plugin_cmd = "${prefix}vagrant plugin install ${plugin_name} ${plugin_options}"
    }
    'uninstalled', 'absent': {
      $unless = undef
      $onlyif = $plugin_exists
      $plugin_cmd = "${prefix}vagrant plugin uninstall ${plugin_name}"
    }
    default: {
      fail("Invalid ensure value: ${ensure}.\n")
    }
  }

  # This exec resource does the work of installing or uninstalling the
  # Vagrant plugin.
  exec { "vagrant-plugin-${name}":
    command     => $plugin_cmd,
    path        => ['/bin', '/usr/bin', '/usr/local/bin'],
    cwd         => $cwd,
    user        => 'root',
    onlyif      => $onlyif,
    unless      => $unless,
    environment => $environment,
    require     => Class['vagrant'],
  }
}
