# Class: bacula::director
#
# This class manages the bacula director component
#
# Parameters:
#   $server:
#     The FQDN of the bacula director
#   $password:
#     The password of the director
#   $db_backend:
#     The DB backend to store the catalogs in. (Currently only support sqlite)
#   $storage_server:
#     The FQDN of the storage daemon server
#   $director_package:
#     The name of the package that installs the director (Optional)
#   $mysql_package:
#     The name of the package that installs the mysql support for the director
#   $sqlite_package:
#     The name of the package that installs the sqlite support for the director
#   $template:
#     The ERB template to us to generate the bacula-dir.conf file
#     - Default: 'bacula/bacula-dir.conf.erb'
#   $use_console:
#     Whether to manage the Console resource in the director
#   $console_password:
#     If $use_console is true, then use this value for the password
#
# Sample Usage:
#
# class { 'bacula::director':
#   server           => 'bacula.domain.com',
#   password         => 'XXXXXXXXX',
#   db_backend       => 'sqlite',
#   storage_server   => 'bacula.domain.com',
#   mail_to          => 'bacula-admin@domain.com',
#   use_console      => true,
#   console_password => 'XXXXXX',
# }
class bacula::director(
    $server,
    $password,
    $db_backend,
    $db_user,
    $db_password,
    $db_host,
    $db_database,
    $db_port,
    $storage_server,
    $director_package = '',
    $mysql_package,
    $mail_to,
    $sqlite_package,
    $template = 'bacula/bacula-dir.conf.erb',
    $use_console,
    $console_password,
    $clients = {}
  ) {

  
  $storage_name_array = split($storage_server, '[.]')
  $director_name_array = split($server, '[.]')
  $storage_name = $storage_name_array[0]
  $director_name = $director_name_array[0]

  
  # This function takes each client specified in $clients
  # and generates a bacula::client resource for each
  #
  # It also searches top scope for variables in the style
  # $bacula_client_mynode with values in format
  # fileset=Basic:noHome,schedule=Hourly
  generate_clients($clients)

  # Only support mysql or sqlite.
  # The given backend is validated in the bacula::config::validate class
  # before this code is reached.
  $db_package = $db_backend ? {
    'mysql'  => $mysql_package,
    'sqlite' => $sqlite_package,
  }
  
  if $director_package {
    package { $director_package:
      ensure => installed,
    }
    File['/etc/bacula/bacula-dir.conf'] {
      require +> Package[$director_pacakge],
    }
  }

  if $db_package {
    package { $db_package:
      ensure => installed,
    }
  }

  # Create the configuration for the Director and make sure the directory for
  # the per-Client configuration is created before we run the realization for
  # the exported files below
  file { '/etc/bacula/bacula-dir.conf':
    ensure  => file,
    owner   => 'bacula',
    group   => 'bacula',
    content => template($template),
    notify  => Service['bacula-director'],
    require => $db_package ? {
      ''      => undef,
      default => Package[$db_package],
    }
  }

  file { '/etc/bacula/bacula-dir.d':
    ensure => directory,
    owner  => 'bacula',
    group  => 'bacula',
    before => Service['bacula-director'],
  }

  file { '/etc/bacula/bacula-dir.d/empty.conf':
    ensure => file,
    before => Service['bacula-director'],
  }

  # Register the Service so we can manage it through Puppet
  service { 'bacula-director':
    enable     => true,
    ensure     => running,
    hasstatus  => true,
    hasrestart => true,
    require    => $db_package ? {
      ''       => undef,
      default  => Package[$db_package],
    }
  }
}
