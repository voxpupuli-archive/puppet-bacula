# == Class: bacula::director
#
# This class manages the Bacula director component
#
# === Parameters
#
# All +bacula+ classes are called from the main +::bacula+ class.  Parameters
# are documented there.
#
class bacula::director(
    $director_server    = undef,
    $director_password  = '',
    $db_backend         = 'sqlite',
    $db_user            = '',
    $db_password        = '',
    $db_host            = 'localhost',
    $db_user_host       = undef,
    $db_database        = 'bacula',
    $db_port            = '3306',
    $manage_db          = false,
    $manage_db_tables   = true,
    $storage_server     = undef,
    $mail_to            = undef,
    $dir_template       = 'bacula/bacula-dir.conf.erb',
    $use_console        = false,
    $console_password   = '',
    $clients            = {}
  ) {
  include bacula::params

  $director_server_real = $director_server ? {
    undef   => $bacula::params::director_server_default,
    default => $director_server,
  }
  $storage_server_real = $storage_server ? {
    undef   => $bacula::params::storage_server_default,
    default => $storage_server,
  }
  $mail_to_real = $mail_to ? {
    undef   => $bacula::params::mail_to_default,
    default => $mail_to,
  }
  $storage_name_array = split($storage_server_real, '[.]')
  $director_name_array = split($director_server_real, '[.]')
  $storage_name = $storage_name_array[0]
  $director_name = $director_name_array[0]


  # This function takes each client specified in $clients
  # and generates a bacula::client resource for each
  #
  # It also searches top scope for variables in the style
  # $::bacula_client_mynode with values in format
  # fileset=Basic:noHome,client_schedule=Hourly
  # In order to work with Puppet 2.6 where create_resources isn't in core,
  # we just skip the top-level stuff for now.
#  if versioncmp($::puppetversion, '2.7.0') >= 0 {
#    generate_clients($clients)
#  } else {
    create_resources('bacula::config::client', $clients)
#  }

#TODO add postgresql support
  $db_package = $db_backend ? {
    'mysql'       => $bacula::params::director_mysql_package,
    'postgresql'  => $bacula::params::director_postgresql_package,
    default       => $bacula::params::director_sqlite_package,
  }

  package { $db_package:
    ensure => present,
  }

# Create the configuration for the Director and make sure the directory for
# the per-Client configuration is created before we run the realization for
# the exported files below

#FIXME Need to set file perms
  file { '/etc/bacula/bacula-dir.d':
    ensure  => directory,
    owner   => 'bacula',
    group   => 'bacula',
    require => Package[$db_package],
    before  => Service[$bacula::params::director_service],
  }

#FIXME Need to set file perms
  file { '/etc/bacula/bacula-dir.d/empty.conf':
    ensure  => file,
    owner   => 'bacula',
    group   => 'bacula',
    require => Package[$db_package],
    before  => Service[$bacula::params::director_service],
  }

#FIXME Need to set file perms
  file { '/etc/bacula/bacula-dir.conf':
    ensure  => file,
    owner   => 'bacula',
    group   => 'bacula',
    content => template($dir_template),
    require => File[
      '/etc/bacula/bacula-dir.d',
      '/etc/bacula/bacula-dir.d/empty.conf',
      '/var/lib/bacula',
      '/var/log/bacula',
      '/var/spool/bacula',
      '/var/run/bacula'
    ],
    notify  => Service[$bacula::params::director_service],
  }

  if $manage_db_tables   {
    case $db_backend {
      'mysql': {
        class { 'bacula::director::mysql':
          db_database   => $db_database,
          db_user       => $db_user,
          db_password   => $db_password,
          db_port       => $db_port,
          db_host       => $db_host,
          db_user_host  => $db_user_host,
          manage_db     => $manage_db,
        }
      }
      'sqlite': {
        class { 'bacula::director::sqlite':
          db_database => $db_database,
        }
      }
      default: {
        fail "The bacula module does not support managing the ${db_backend} backend database"
      }
    }
  }

# Register the Service so we can manage it through Puppet
  if $manage_db_tables {
    $service_require = $db_backend ? {
      'mysql'   => [
        File['/etc/bacula/bacula-dir.conf'],
        Mysql::Db[$db_database],
        Exec['make_db_tables'],
      ],
      default   => [
        File['/etc/bacula/bacula-dir.conf'],
        Sqlite::Db[$db_database],
      ],
    }
  } else {
    $service_require = File['/etc/bacula/bacula-dir.conf']
  }

  service { $bacula::params::director_service:
    ensure      => running,
    enable      => true,
    hasstatus   => true,
    hasrestart  => true,
    require     => $service_require,
  }

}
