# == Class: bacula::director::sqlite
#
# Full description of class example_class here.
#
# === Parameters
#
# Document parameters here.
#
# [*bacula::director::sqlite_servers*]
#   Explanation of what this parameter affects and what it defaults to.
#   e.g. "Specify one or more upstream ntp servers as an array."
#
# === Examples
#
#  class { 'bacula::director::sqlite':
#    bacula::director::sqlite_servers => [ 'bacula::director::sqlite1.example.org', 'bacula::director::sqlite2.example.com' ]
#  }
#
# === Copyright
#
# Copyright 2012 Red Hat, Inc., All rights reserved.
#
class bacula::director::sqlite (
  $db_database  = 'bacula'
){
  sqlite::db { $db_database:
    ensure    => present,
    location  => "/var/lib/bacula/${db_database}.db",
    owner     => 'bacula',
    group     => 'bacula',
    require   => File['/var/lib/bacula'],
    notify    => Exec['make_db_tables'],
  }

  file { '/usr/local/libexec/bacula':
    ensure  => directory,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
  }

  file { '/usr/local/libexec/bacula/make_sqlite3_tables.sh':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    content => template('bacula/make_sqlite3_tables.sh.erb'),
    require => [
      File['/var/lib/bacula'],
      Sqlite::Db[$db_database],
    ],
  }
  $make_db_tables_command = $::operatingsystem ? {
    /(Ubuntu|Debian)/ => '/usr/lib/bacula/make_bacula_tables',
    default           => '/usr/local/libexec/bacula/make_sqlite3_tables.sh',
  }

  exec { 'make_db_tables':
    command     => $make_db_tables_command,
    refreshonly => true,
    require     => File['/usr/local/libexec/bacula/make_sqlite3_tables.sh'],
  }
}
