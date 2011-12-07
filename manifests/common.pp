class bacula::common {

  user { 'bacula':
    ensure => present,
  }

  group { 'bacula':
    ensure => present,
  }

  file { '/var/lib/bacula':
    ensure => directory,
    owner  => bacula,
    group  => bacula,
  }
}
