# == Class: bacula::client
#
# This class manages the bacula client (bacula-fd)
#
# === Parameters
#
# All +bacula+ classes are called from the main +::bacula+ class.  Parameters
# are documented there.
#
# === Actions:
# * Enforce the client package package be installed
# * Manage the +/etc/bacula/bacula-fd.conf+ file
# * Enforce the +bacula-fd+ service to be running
#
class bacula::client(
    $director_password  = '',
    $director_server    = undef
  ) {
  include bacula::params

  $director_server_real = $director_server ? {
    undef   => $bacula::params::director_server_default,
    default => $director_server,
  }

  $director_name_array = split($director_server_real, '[.]')
  $director_name = $director_name_array[0]

  package { 'bacula-client':
    ensure => present,
  }

  file { '/etc/bacula/bacula-fd.conf':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0640',
    content => template('bacula/bacula-fd.conf.erb'),
    require => [
      Package['bacula-client'],
      File['/var/lib/bacula', '/var/run/bacula'],
    ],
    notify  => Service['bacula-fd'],
  }

  service { 'bacula-fd':
    ensure  => running,
    enable  => true,
  }
}
