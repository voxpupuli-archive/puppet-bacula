class bacula::console(
    $director_server,
    $director_password,
    $template = 'bacula/bconsole.conf.erb'
  ) {

  $director_name_array = split($server, '[.]')
  $director_name = $director_name_array[0]

  package { 'bacula-console':
    ensure => 'latest';
  }

  file { '/etc/bacula/bconsole.conf':
    ensure  => 'present',
    owner   => 'bacula',
    group   => 'bacula',
    content => template($template),
    require => Package['bacula-console'],
  }
}
