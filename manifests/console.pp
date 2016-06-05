# Class: bacula::console
#
# This class manages the bconsole application
#
# Parameters:
#   $director_server:
#     The FQDN of the director
#   $director_password:
#     The password of the director
#   $template:
#     The template to use to generate the bconsole.conf file (Optional)
#     - Default: 'bacula/bconsole.conf.erb'
#
# Sample Usage:
#
# class { 'bacula::console':
#   director_server   => 'bacula.domain.com',
#   director_password => 'XXXXXXXX',
# }
class bacula::console(
    $director_server,
    $director_password,
    $console_package,
    $template = 'bacula/bconsole.conf.erb'
  ) {

  if $console_package == '' {
    $real_console_package = undef
  } else {
    $real_console_package = Package['bacula-console']
  }


  $director_name_array = split($director_server, '[.]')
  $director_name = $director_name_array[0]

  if $console_package {
    package { $console_package:
      ensure => 'latest';
    }
  }

  file { '/etc/bacula/bconsole.conf':
    ensure  => file,
    owner   => 'bacula',
    group   => 'bacula',
    content => template($template),
    require => $real_console_package,
  }
}
