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
    content => template('bacula/client_config.erb'),
    require => File['/etc/bacula/bacula-dir.conf'],
    before  => Service[$bacula::params::director_service],
    notify  => Service[$bacula::params::director_service],
  }
}
