# == Define: bacula::client::config
#
# Install a config file describing a +bacula-fd+ client on the director.
#
# === Parameters
#
# [*client_schedule*]
#   The schedule for backups to be performed.
#
# [*director_password*]
#   The director's password the client is connecting to.
#
# [*fileset*]
#   The file set used by the client for backups
#
# === Examples
#
#   bacula::client::config { 'client1.example.com' :
#     client_schedule   => 'WeeklyCycle',
#     director_password => 'directorpassword',
#     fileset           => 'Basic:noHome',
#   }
#
define bacula::client::config (
  $client_schedule   = 'WeeklyCycle',
  $director_password = undef,
  $director_server   = undef,
  $fileset           = 'Basic:noHome'
) {
  case $director_password {
    undef   : {
      case $bacula::director::director_password {
        undef, '' : {
          fail('You must provide a value for director_password or create the',
            'configs by passing the clients hash to bacula class on the director server'
          )
        }
        default   : {
          $director_password_real = $bacula::director::director_password
        }
      }
    }
    default : {
      $director_password_real = $director_password
    }
  }

  if !is_domain_name($name) {
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
