# == Class: bacula::director::mysql
#
# Manage MySQL resources for the Bacula director.
#
# === Parameters
#
# All +bacula+ classes are called from the main +::bacula+ class.  Parameters
# are documented there.
#
# === Copyright
#
# Copyright 2012 Red Hat, Inc., All rights reserved.
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
      undef   => $db_host,
      default => $db_user_host,
    }

    mysql::db { $db_database:
      user      => $db_user,
      password  => $db_password,
      host      => $db_user_host,
      require   => $db_require,
      notify    => Exec['make_db_tables'],
    }

    $exec_require = [
      Package[$bacula::params::director_mysql_package],
      Mysql::Db[$db_database],
    ]
  } else {
    $exec_require = Package[$bacula::params::director_mysql_package]
  }

  $make_db_tables_command = $::operatingsystem ? {
    /(Ubuntu|Debian)/ => '/usr/lib/bacula/make_bacula_tables',
    default           => '/usr/libexec/bacula/make_mysql_tables',
  }
  $db_parameters = "--host=${db_host} --user=${db_user} --password=${db_password} --port=${db_port} --database=${db_database}"

  exec { 'make_db_tables':
    command     => "${make_db_tables_command} ${db_parameters}",
    refreshonly => true,
    logoutput   => on_failure,
    require     => $exec_require,
  }
}
