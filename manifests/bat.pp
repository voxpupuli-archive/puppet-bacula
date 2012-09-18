# == Class: bacula::bat
#
# This class installs the BAT (Bacula Admin Tool) application for QT supported
# systems
#
# === Actions:
# * Enforce the BAT system package is installed
# * Enforce +/etc/bacula/bat.conf+ points to +/etc/bacula/bconsole.conf+
#
# === Sample Usage:
#
#  class { 'bacula::bat': }
#
class bacula::bat inherits bacula::console {

  $bat_console_package = $::operatingsystem ? {
    /(Redhat|CentOS)/ => 'bacula-console-bat',
    /(Debian|Ubuntu)/ => 'bacula-console-qt',
    default           => 'bacula-console-bat',
  }

  package { $bat_console_package:
    ensure  => present,
  }

  file { '/etc/bacula/bat.conf':
    ensure  => 'symlink',
    target  => 'bconsole.conf',
    require => [
      Package[$bat_console_package],
      File['/etc/bacula/bconsole.conf'],
    ],
  }
}
