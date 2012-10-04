# == Define: bacula::config::client
#
# Install a config file describing a +bacula-fd+ client on the director.
#
# === Parameters
#
# [*client_schedule*]
#   The schedule for backups to be performed.
#
# [*fileset*]
#   The file set used by the client for backups
#
# === Examples
#
#   bacula::config::client { 'client1.example.com' :
#     fileset         => 'Basic:noHome',
#     client_schedule => 'WeeklyCycle',
#   }
#
define bacula::config::client (
  $fileset          = 'Basic:noHome',
  $client_schedule  = 'WeeklyCycle'
) {

  if ! is_domain_name($name) {
    fail "Name for client ${name} must be a fully qualified domain name"
  }

  $name_array = split($name, '[.]')
  $hostname   = $name_array[0]

  file { "/etc/bacula/bacula-dir.d/${name}.conf":
    ensure  => file,
    owner   => 'bacula',
    group   => 'bacula',
    mode    => '0640',
    content => template('bacula/client_config.erb'),
    require => File['/etc/bacula/bacula-dir.conf'],
    notify  => Service['bacula-dir'],
  }
}
