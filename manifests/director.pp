# Class: bacula::director
#
# This class manages the bacula director component
#
# Parameters:
# [*director_server*]
#   The FQDN of the bacula director
# [*director_password*]
#   The password of the director
# [*db_backend*]
#   The DB backend to store the catalogs in. (Currently only support +sqlite+
#   and +mysql+)
# [*db_user*]
#   The user to authenticate to +$db_db+ with.
# [*db_password*]
#   The password to authenticate +$db_user+ with
# [*db_host*]
#   The db server host to connect to
# [*db_database*]
#   The db database to connect to on +$db_host+
# [*manage_db_tables*]
#   Whether to create the DB tables during install
# [*storage_server*]
#   The FQDN of the storage daemon server
# [*dir_template*]
#   The ERB template to us to generate the +bacula-dir.conf+ file
#   * Default: +'bacula/bacula-dir.conf.erb'+
# [*use_console*]
#   Whether to manage the Console resource in the director
# [*console_password*]
#   If $use_console is true, then use this value for the password
# [*clients*]
#   For directors, +$clients+ is a hash of clients.  The keys are the clients
#   while the value is a hash of parameters The parameters accepted are
#   +fileset+ and +client_schedule+.
#   Example clients hash:
#     $clients = {
#       'somenode.example.com'  => {
#         'fileset'         => 'Basic:noHome',
#         'client_schedule' => 'Hourly',
#       },
#       'node2.example.com'     => {
#         'fileset'         => 'Basic:noHome',
#         'client_schedule' => 'Hourly',
#       }
#     }
#
# === Sample Usage:
#
#  class { 'bacula::director':
#    director_server    => 'bacula.domain.com',
#    director_password  => 'XXXXXXXXX',
#    db_backend         => 'sqlite',
#    storage_server     => 'bacula.domain.com',
#    mail_to            => 'bacula-admin@domain.com',
#    use_console        => true,
#    console_password   => 'XXXXXX',
#  }
#
class bacula::director(
    $director_server    = undef,
    $director_password  = '',
    $db_backend         = 'sqlite',
    $db_user            = '',
    $db_password        = '',
    $db_host            = 'localhost',
    $db_database        = 'bacula',
    $db_port            = '3306',
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
  if versioncmp($::puppetversion, '2.7.0') >= 0 {
    generate_clients($clients)
  } else {
    create_resources('bacula::config::client', $clients)
  }

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
          db_database => $db_database,
          db_user     => $db_user,
          db_password => $db_password,
          db_port     => $db_port,
          db_host     => $db_host,
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
