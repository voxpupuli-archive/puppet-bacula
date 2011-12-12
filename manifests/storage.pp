# Class: bacula::storage
#
# This class manages the bacula storage daemon (bacula-sd)
#
# Parameters:
#   $db_backend:
#     The database backend to use. (Currently only supports sqlite)
#   $director_server:
#     The FQDN of the bacula director
#   $director_password:
#     The director's password
#   $storage_server:
#     The FQDN of the storage daemon server
#   $storage_package:
#     The package name to install the storage daemon (Optional)
#   $mysql_package:
#     The package name to install the storage daemon mysql component
#   $sqlite_package:
#     The package name to install the storage daemon sqlite component
#   $console_password:
#     The password for the Console compoenent of the Director service
#   $template:
#     The tempalte to use for generating the bacula-sd.conf file
#     - Default: 'bacula/bacula-sd.conf.erb'
#
# Actions:
#   - Enforce the DB compoenent package package be installed
#   - Manage the /etc/bacula/bacula-sd.conf file
#   - Manage the /mnt/bacula and /mnt/bacula/default directories
#   - Manage the /etc/bacula/bacula-sd.conf file
#   - Enforce the bacula-sd service to be running
#
# Sample Usage:
# 
# class { 'bacula::client':
#   director_server   => 'bacula.domain.com',
#   director_password => 'XXXXXXXXXX',
#   client_package    => 'bacula-client',
# }
class bacula::storage(
    $db_backend,
    $director_server,
    $director_password,
    $storage_server,
    $storage_package = '',
    $mysql_package,
    $sqlite_package,
    $console_password,
    $template = 'bacula/bacula-sd.conf.erb'
  ) {

  $storage_name_array = split($storage_server, '[.]')
  $director_name_array = split($director_server, '[.]')
  $storage_name = $storage_name_array[0]
  $director_name = $director_name_array[0]

  $db_package = $db_backend ? {
    'mysql'  => $mysql_package,
    'sqlite' => $sqlite_package,
  }

  # This is necessary because the bacula-common package will
  # install the bacula-storage-mysql package regardless of 
  # wheter we're installing the bacula-storage-sqlite package
  # This causes the bacula storage daemon to use mysql no
  # matter what db backend we want to use.  
  #
  # However, if we install only the db compoenent package,
  # it will install the bacula-common package without
  # necessarily installing the bacula-storage-mysql package
  if $storage_package {
    package { $storage_package:
      ensure => installed,
    }
    File['/etc/bacula/bacula-sd.conf'] {
      require +> Package[$storage_package],
    }
    Service['bacula-sd'] {
      require +> Package[$storage_package],
    }
  }

  if $db_package {
    package { $db_package:
      ensure => installed,
    }
  }

  file { '/etc/bacula/bacula-sd.conf':
    ensure  => file,
    owner   => 'bacula',
    group   => 'bacula',
    content => template($template),
    notify  => Service['bacula-sd'],
    require => $db_package ? {
      ''      => undef,
      default => Package[$db_package],
    }
  }

  file { ['/mnt/bacula', '/mnt/bacula/default']:
    ensure  => directory,
    owner   => 'bacula',
    group   => 'bacula',
    mode    => '0750',
  }

  file { '/etc/bacula/bacula-sd.d':
    ensure => directory,
    owner  => 'bacula',
    group  => 'bacula',
    before => Service['bacula-sd'],
  }

  file { '/etc/bacula/bacula-sd.d/empty.conf':
    ensure => file,
    before => Service['bacula-sd'],
  }

  # Register the Service so we can manage it through Puppet
  service { 'bacula-sd':
    enable     => true,
    ensure     => running,
    hasstatus  => true,
    hasrestart => true,
    require    => $db_package ? {
      ''      => undef,
      default => Package[$db_package],
    }
  }
}
