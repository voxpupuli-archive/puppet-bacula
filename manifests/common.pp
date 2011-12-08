# Class: bacula::common
# 
# This class enforces common resources needed by all 
# bacula components
#
# Actions:
#   - Enforce the bacula user and groups exist
#   - Enforce the /var/spool/bacula is a director and /var/lib/bacula points to it
#
# Sample Usage:
#
# class { 'bacula::common': }
class bacula::common {

  user { 'bacula':
    ensure => present,
    gid    => 'bacula',
  }

  group { 'bacula':
    ensure => present,
  }

  file { '/var/spool/bacula':
    ensure => directory,
    owner  => bacula,
    group  => bacula,
  }

  file { '/var/lib/bacula':
    ensure => symlink,
    target => '/var/spool/bacula',
  }
}
