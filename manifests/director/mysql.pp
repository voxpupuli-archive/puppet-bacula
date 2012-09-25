# == Class: bacula::director::mysql
#
# Manage MySQL resources for the Bacula director.
#
# === Parameters
#
# All +bacula+ classes are called from the main +::bacula+ class.  Parameters
# are documented there.
#
class bacula::director::mysql (
  $db_database  = 'bacula',
  $db_user      = '',
  $db_database  = 'bacula',
  $db_password  = '',
  $db_port      = '3306',
  $db_host      = 'localhost',
  $db_user_host = undef,
  $manage_db    = false
){
  include bacula::params

  if $manage_db {
    if defined(Class['mysql::server']) {
      if defined(Class['mysql::config']) {
        $db_require = [
          Class['mysql::server'],
          Class['mysql::config'],
        ]
      } else {
        $db_require = Class['mysql::server']
      }
    } else {
      $db_require = undef
    }

    $db_user_host_real = $db_user_host ? {
      undef   => $::fqdn,
      default => $db_user_host,
    }

    mysql::db { $db_database:
      user      => $db_user,
      password  => $db_password,
      host      => $db_user_host,
      grant     => ['all'],
      require   => $db_require,
      notify    => Exec['make_db_tables'],
    }
  }

  $make_db_tables_command = $::operatingsystem ? {
    /(Ubuntu|Debian)/ => '/usr/lib/bacula/make_bacula_tables',
    default           => '/usr/libexec/bacula/make_mysql_tables',
  }
  $db_parameters = "--host=${db_host} --user=${db_user} --password=${db_password} --port=${db_port} --database=${db_database}"

  exec { 'make_db_tables':
    command     => "${make_db_tables_command} ${db_parameters}",
    refreshonly => true,
    logoutput   => true,
    require     => Package[$bacula::params::director_mysql_package],
    notify      => Service[$bacula::params::director_service],
  }
}
