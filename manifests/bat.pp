class bacula::bat inherits bacula::console {

  package { 'bacula-console-qt':
    ensure => installed,
  }

  file { '/etc/bacula/bat.conf':
    ensure  => 'symlink',
    target  => 'bconsole.conf',
    require => [ Package['bacula-console-qt'], File['/etc/bacula/bconsole.conf'] ],
  }
}
