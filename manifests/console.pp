# == Class: bacula::console
#
# This class manages the bconsole application
#
# === Parameters:
# [*director_server*]
#   The FQDN of the director
# [*director_password*]
#   The password of the director
# [*console_template*]
#   The template to use to generate the bconsole.conf file (Optional)
#   * Default: +'bacula/bconsole.conf.erb'+
#
# === Sample Usage:
#
#  class { 'bacula::console':
#    director_server   => 'bacula.domain.com',
#    director_password => 'XXXXXXXX',
#  }
#
class bacula::console(
    $director_server    = undef,
    $director_password  = '',
    $console_template   = 'bacula/bconsole.conf.erb'
  ) {

  include bacula::params

  $director_server_real = $director_server ? {
    undef   => $bacula::params::director_server_default,
    default => $director_server,
  }
  $director_name_array = split($director_server_real, '[.]')
  $director_name = $director_name_array[0]


  package { $bacula::params::console_package:
    ensure => present,
  }

  file { '/etc/bacula/bconsole.conf':
    ensure  => file,
    owner   => 'bacula',
    group   => 'bacula',
    content => template($console_template),
    require => Package[$bacula::params::console_package],
  }
}
