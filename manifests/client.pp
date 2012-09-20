# == Class: bacula::client
#
# This class manages the bacula client (bacula-fd)
#
# === Parameters:
# [*director_server*]
#   The FQDN of the bacula director
# [*director_password*]
#   The director's password
#
# === Actions:
# * Enforce the client package package be installed
# * Manage the +/etc/bacula/bacula-fd.conf+ file
# * Enforce the +bacula-fd+ service to be running
#
# === Sample Usage:
#
#  class { 'bacula::client':
#    director_server   => 'bacula.example.com',
#    director_password => 'XXXXXXXXXX',
#  }
#
class bacula::client(
    $director_server    = undef,
    $director_password  = ''
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
    content => template('bacula/bacula-fd.conf.erb'),
    require => [
      Package['bacula-client'],
      File['/var/lib/bacula'],
    ],
    notify  => Service['bacula-fd'],
  }

  service { 'bacula-fd':
    ensure  => running,
    enable  => true,
    require => File['/etc/bacula/bacula-fd.conf'],
  }
}
