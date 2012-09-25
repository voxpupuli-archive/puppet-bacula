# == Class: bacula::console::bat
#
# This class installs the BAT (Bacula Admin Tool) application for QT supported
# systems
#
# === Parameters
#
# None
#
# === Actions:
# * Enforce the BAT system package is installed
# * Enforce +/etc/bacula/bat.conf+ points to +/etc/bacula/bconsole.conf+
#
# === Sample Usage:
#
#  class { 'bacula::console::bat': }
#
class bacula::console::bat {
  Class['bacula::console'] -> Class['bacula::console::bat']
  include bacula::params

  package { $bacula::params::bat_console_package:
    ensure  => present,
  }

  file { '/etc/bacula/bat.conf':
    ensure  => 'symlink',
    target  => 'bconsole.conf',
    require => [
      Package[$bacula::params::bat_console_package],
      File['/etc/bacula/bconsole.conf'],
    ],
  }
}
