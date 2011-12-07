class bacula::common {

  user { 'bacula':
    ensure => present,
    gid    => 'bacula',
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
