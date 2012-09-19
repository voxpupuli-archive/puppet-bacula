# == Class: bacula::params
#
# Default values for parameters needed to configure the bacula class.
#
# === Parameters
#
# None
#
# === Examples
#
#  include bacula::params
#
class bacula::params {

# Define default values
  $director_server_default = "bacula.${::domain}"
  $storage_server_default = "bacula.${::domain}"
  $mail_to_default= "root@${::fqdn}"

# Define system package names
  $bat_console_package = $::operatingsystem ? {
    /(Debian|Ubuntu)/ => 'bacula-console-qt',
    default           => 'bacula-console-bat',
  }
  $console_package = 'bacula-console'
  $director_mysql_package = 'bacula-director-mysql'
  $director_postgresql_package = 'bacula-director-postgresql'
  $director_sqlite_package = 'bacula-director-sqlite'
  $storage_mysql_package = 'bacula-storage-mysql'
  $storage_postgresql_package = 'bacula-storage-postgresql'
  $storage_sqlite_package = 'bacula-storage-sqlite'

# Define system services
  $director_service = $::operatingsystem ? {
    /(Debian|Ubuntu)/ => 'bacula-director',
    default           => 'bacula-dir',
  }
}
