# Class: bacula::client
#
# This class manages the bacula client (bacula-fd)
#
# Parameters:
#   $director_server:
#       The FQDN of the bacula director
#   $director_password:
#       The director's password
#   $client_package:
#       The name of the package to install the bacula-fd service.
#
# Actions:
#   - Enforce the $client_package package be installed
#   - Manage the /etc/bacula/bacula-fd.conf file
#   - Enforce the bacula-fd service to be running
#
# Sample Usage:
# 
# class { 'bacula::client':
#   director_server   => 'bacula.domain.com',
#   director_password => 'XXXXXXXXXX',
#   client_package    => 'bacula-client',
# }
class bacula::client(
    $director_server,
    $director_password,
    $client_package
  ) {

  $director_name_array = split($director_server, '[.]')
  $director_name = $director_name_array[0]

  package { $client_package:
    ensure => installed,
  }

  file { '/etc/bacula/bacula-fd.conf':
    ensure  => file,
    content => template('bacula/bacula-fd.conf.erb'),
    notify  => Service['bacula-fd'],
    require => Package[$client_package],
  }

  service { 'bacula-fd':
    ensure  => running,
    enable  => true,
    require => Package[$client_package],
  }
}
