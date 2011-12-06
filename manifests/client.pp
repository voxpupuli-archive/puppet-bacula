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
  }

  service { 'bacula-fd':
    ensure  => running,
    enable  => true,
    require => Package[$client_package],
  }
}
