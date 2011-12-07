class bacula::director(
    $server,
    $password,
    $db_backend,
    $storage_server,
    $director_package = '',
    $mysql_package,
    $mail_to,
    $sqlite_package,
    $template = 'bacula/bacula-dir.conf.erb',
    $use_console,
    $console_password
  ) {

  $storage_name_array = split($storage_server, '[.]')
  $director_name_array = split($server, '[.]')
  $storage_name = $storage_name_array[0]
  $director_name = $director_name_array[0]

  # Only support mysql or sqlite.
  # The given backend is validated in the bacula::config::validate class
  # before this code is reached.
  $db_package = $db_backend ? {
    'mysql'  => $mysql_package,
    'sqlite' => $sqlite_package,
  }
  
  if $director_package {
    package { $director_package:
      ensure => installed,
    }
    File['/etc/bacula/bacula-dir.conf'] {
      require +> Package[$director_pacakge],
    }
  }

  package { $db_package:
    ensure => installed,
  }

  # Create the configuration for the Director and make sure the directory for
  # the per-Client configuration is created before we run the realization for
  # the exported files below
  file { '/etc/bacula/bacula-dir.conf':
    ensure  => file,
    owner   => 'bacula',
    group   => 'bacula',
    content => template($template),
    notify  => Service['bacula-dir'],
    require => Package[$db_package],
  }

  # Register the Service so we can manage it through Puppet
  service { 'bacula-dir':
    enable     => true,
    ensure     => running,
    require    => Package[$db_package],
    hasstatus  => true,
    hasrestart => true,
  }
}
