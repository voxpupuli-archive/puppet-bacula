# Class: bacula::bat
# 
# This class installs the BAT application for QT supported systems
# 
# Actions:
#   - Enforce the bacula-console-qt package is installed
#   - Enforce /etc/bacula/bat.conf points to /etc/bacula/bconsole.bat
#
# Sample Usage:
# 
# class { 'bacula::bat': }
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
