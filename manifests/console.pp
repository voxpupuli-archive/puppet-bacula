# == Class: bacula::console
#
# This class manages the bconsole application
#
# === Parameters
#
# All +bacula+ classes are called from the main +::bacula+ class.  Parameters
# are documented there.
#
class bacula::console(
  $console_template   = 'bacula/bconsole.conf.erb',
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


  package { $bacula::params::console_package:
    ensure => present,
  }

  file { '/etc/bacula/bconsole.conf':
    ensure  => file,
    owner   => 'bacula',
    group   => 'bacula',
    mode    => '0640',
    content => template($console_template),
    require => Package[$bacula::params::console_package],
  }
}
