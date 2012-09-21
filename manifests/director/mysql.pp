# == Class: bacula::director::mysql
#
# Full description of class example_class here.
#
# === Parameters
#
# Document parameters here.
#
# [*bacula::director::mysql_servers*]
#   Explanation of what this parameter affects and what it defaults to.
#   e.g. "Specify one or more upstream ntp servers as an array."
#
# === Examples
#
#  class { 'bacula::director::mysql':
#    bacula::director::mysql_servers => [ 'bacula::director::mysql1.example.org', 'bacula::director::mysql2.example.com' ]
#  }
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
  $db_host      = 'localhost'
){
  include bacula::params

  $db_require = defined(Class['mysql::server']) ? {
    true    => Class['mysql::server'],
    default => undef,
  }
  mysql::db { $db_database:
    user      => $db_user,
    password  => $db_password,
    host      => $db_host,
    require   => $db_require,
    notify    => Exec['make_db_tables'],
  }

  $make_db_tables_command = $::operatingsystem ? {
    /(Ubuntu|Debian)/ => '/usr/lib/bacula/make_bacula_tables',
    default           => '/usr/libexec/bacula/make_mysql_tables',
  }
  $db_parameters = "--host=${db_host} --user=${db_user} --password=${db_password} --port=${db_port} --database=${db_database}"

  exec { 'make_db_tables':
    command     => "${make_db_tables_command} ${db_parameters}",
    user        => 'bacula',
    group       => 'bacula',
    refreshonly => true,
    require     => [
      Package[$bacula::params::director_mysql_package],
      Mysql::Db[$db_database],
    ],
  }
}
