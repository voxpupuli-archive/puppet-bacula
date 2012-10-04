# == Class: bacula::director::sqlite
#
# Manage SQLite resources for the Bacula director
#
# === Parameters
#
# All +bacula+ classes are called from the main +::bacula+ class.  Parameters
# are documented there.
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
    require => Package[$bacula::params::director_sqlite_package],
  }

  $make_db_tables_command = $::operatingsystem ? {
    /(Ubuntu|Debian)/ => '/usr/lib/bacula/make_bacula_tables',
    default           => '/usr/local/libexec/bacula/make_sqlite3_tables.sh',
  }

  exec { 'make_db_tables':
    command     => $make_db_tables_command,
    refreshonly => true,
    require     => File['/usr/local/libexec/bacula/make_sqlite3_tables.sh'],
    notify      => Service['bacula-dir'],
  }
}
