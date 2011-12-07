class bacula::storage(
    $db_backend,
    $director_server,
    $director_password,
    $storage_server,
    $storage_package,
    $mysql_package,
    $sqlite_package,
    $console_password,
    $template = 'bacula/bacula-sd.conf.erb'
  ) {

  $storage_name_array = split($storage_server, '[.]')
  $director_name_array = split($director_server, '[.]')
  $storage_name = $storage_name_array[0]
  $director_name = $director_name_array[0]

  $db_package = $db_backend ? {
    'mysql'  => $mysql_package,
    'sqlite' => $sqlite_package,
  }

  package { [$db_package, $storage_package]:
    ensure => installed,
  }

  file { '/etc/bacula/bacula-sd.conf':
    ensure  => installed,
    owner   => 'bacula',
    group   => 'bacula',
    content => template($template),
    notify  => Service['bacula-sd'],
    require => Package[$db_package, $storage_package],
  }

  file { ['/mnt/bacula', '/mnt/bacula/default']:
    ensure  => 'directory',
    owner   => 'bacula',
    group   => 'tape',
    mode    => '0750';
  }

  # Register the Service so we can manage it through Puppet
  service { 'bacula-sd':
    enable     => true,
    ensure     => running,
    require    => Package[$db_package],
    hasstatus  => true,
    hasrestart => true;
  }
}
