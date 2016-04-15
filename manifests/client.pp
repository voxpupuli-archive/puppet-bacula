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
#   $client_conf:
#       File name of bacula-fd configuration file 
#   $client_conf_template:
#       Template for bacula-fd configuration file 
#   $client_service:
#       The name of bacula-fd service
#   $package_provider:
#       Package provider (for solaris only) 
#   $pid_dir:
#       The bacula-fd pid dir 
#   $working_dir:
#       The bacula-fd working dir
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
    $client_conf = '/etc/bacula/bacula-fd.conf',
    $client_conf_template = 'bacula/bacula-fd.conf.erb',
    $client_package = 'bacula-client',
    $client_service = 'bacula-fd',
    $director_password,
    $director_server,
    $package_provider = undef,
    $pid_dir = '/var/run/bacula',
    $working_dir = '/var/lib/bacula'
  ) {

  $director_name_array = split($director_server, '[.]')
  $director_name = $director_name_array[0]

  package { $client_package:
    ensure   => installed,
    provider => $package_provider,
  }

  file { $client_conf:
    ensure  => file,
    content => template($client_conf_template),
    notify  => Service[$client_service],
    require => Package[$client_package],
  }

  service { $client_service:
    ensure  => running,
    enable  => true,
    require => Package[$client_package],
  }
}
