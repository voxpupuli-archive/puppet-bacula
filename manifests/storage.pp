# == Class: bacula::storage
#
# This class manages the bacula storage daemon (bacula-sd)
#
# === Parameters:
# [*db_backend*]
#   The database backend to use.
#   (Currently only supports +'sqlite'+ and +'mysql'+)
# [*director_server*]
#   The FQDN of the bacula director
# [*director_password*]
#   The director's password
# [*storage_server*]
#   The FQDN of the storage daemon server
# [*console_password*]
#   The password for the Console component of the Director service
# [*template*]
#   The template to use for generating the +bacula-sd.conf+ file
#   * Default: +'bacula/bacula-sd.conf.erb'+
#
# === Actions:
# * Enforce the DB component package package be installed
# * Manage the +/etc/bacula/bacula-sd.conf+ file
# * Manage the +/mnt/bacula+ and +/mnt/bacula/default+ directories
# * Manage the +/etc/bacula/bacula-sd.conf+ file
# * Enforce the +bacula-sd+ service to be running
#
# === Sample Usage:
#
#  class { 'bacula::storage':
#    db_backend        => 'mysql',
#    director_server   => 'bacula.domain.com',
#    director_password => 'XXXXXXXXXX',
#  }
#
class bacula::storage(
    $db_backend         = 'sqlite',
    $director_server    = undef,
    $director_password  = '',
    $storage_server     = undef,
    $console_password   = '',
    $storage_template   = 'bacula/bacula-sd.conf.erb'
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
  $storage_name_array = split($storage_server_real, '[.]')
  $director_name_array = split($director_server_real, '[.]')
  $storage_name = $storage_name_array[0]
  $director_name = $director_name_array[0]

  # This is necessary because the bacula-common package will
  # install the bacula-storage-mysql package regardless of
  # wheter we're installing the bacula-storage-sqlite package
  # This causes the bacula storage daemon to use mysql no
  # matter what db backend we want to use.
  #
  # However, if we install only the db compoenent package,
  # it will install the bacula-common package without
  # necessarily installing the bacula-storage-mysql package
  $db_package = $db_backend ? {
    'mysql'       => $bacula::params::storage_mysql_package,
    'postgresql'  => $bacula::params::storage_postgresql_package,
    default       => $bacula::params::storage_sqlite_package,
  }

  package { $db_package:
    ensure => present,
  }

  file { ['/mnt/bacula', '/mnt/bacula/default']:
    ensure  => directory,
    owner   => 'bacula',
    group   => 'bacula',
    mode    => '0750',
    require => Package[$db_package],
  }

  file { '/etc/bacula/bacula-sd.d':
    ensure  => directory,
    owner   => 'bacula',
    group   => 'bacula',
    require => Package[$db_package],
  }

  file { '/etc/bacula/bacula-sd.d/empty.conf':
    ensure  => file,
    owner   => 'bacula',
    group   => 'bacula',
    require => Package[$db_package],
  }

  file { '/etc/bacula/bacula-sd.conf':
    ensure  => file,
    owner   => 'bacula',
    group   => 'bacula',
    content => template($storage_template),
    require => File[
      '/etc/bacula/bacula-sd.d',
      '/etc/bacula/bacula-sd.d/empty.conf',
      '/mnt/bacula/default',
      '/var/lib/bacula',
      '/var/run/bacula'
    ],
    notify  => Service['bacula-sd'],
  }

  # Register the Service so we can manage it through Puppet
  service { 'bacula-sd':
    ensure     => running,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
    require    => File['/etc/bacula/bacula-sd.conf'],
  }
}
