# Class: bacula::common
#
# This class enforces common resources needed by all
# bacula components
#
# Actions:
#   - Enforce the bacula user and groups exist
#   - Enforce the /var/spool/bacula is a director and /var/lib/bacula points to it
#
# Sample Usage:
#
# class { 'bacula::common': }
class bacula::common (
  $packages,
  $manage_db_tables,
  $manage_db         = true,
  $db_backend,
  $db_user,
  $db_database,
  $db_password,
  $db_port,
  $db_host,
  ) {

  $notify_database = $manage_db_tables ? {
    true  => Exec['make_db_tables'],
    false => undef,
  }

  if $packages {
    package { $packages:
      ensure => installed,
      notify => $notify_database,
    }
  }

  $db_parameters = $db_backend ? {
    'sqlite' => '',
    'mysql'  => "--host=${db_host} --user=${db_user} --password=${db_password} --port=${db_port} --database=${db_database}",
  }

  if $manage_db_tables {
    exec { 'make_db_tables':
      command     => "/usr/lib/bacula/make_bacula_tables ${db_parameters}",
      refreshonly => true,
    }
  }

  if $manage_db {

    if defined(Class['mysql::server']) {
      $mysql_class = 'Class["mysql::server"]'
    } else {
      $mysql_class = undef
    }

    case $db_backend {
      'mysql': {
        mysql::db { $db_database:
          user     => $db_user,
          password => $db_password,
          host     => $db_host,
          notify   => $notify_database,
          require  => $mysql_class,
        }
      }

      'sqlite': {
        sqlite::db { $db_database:
          ensure   => present,
          location => "/var/lib/bacula/${db_database}.db",
          owner    => 'bacula',
          group    => 'bacula',
          require  => File['/var/lib/bacula'],
        }
      }

      default: {
        fail "The bacula module does not support managing the ${db_backend} backend database"
      }
    }
  }

  user { 'bacula':
    ensure => present,
    gid    => 'bacula',
  }

  group { 'bacula':
    ensure => present,
  }

  file { '/etc/bacula/':
    ensure  => directory,
  }

  file { '/var/lib/bacula':
    ensure => directory,
    owner  => bacula,
    group  => bacula,
  }

  file { '/var/spool/bacula':
    ensure => directory,
    owner  => bacula,
    group  => bacula,
  }

  file { '/var/log/bacula':
    ensure  => directory,
    owner   => bacula,
    group   => bacula,
    recurse => true,
  }

  file { '/var/run/bacula':
    ensure => directory,
    owner  => bacula,
    group  => bacula,
  }
}
