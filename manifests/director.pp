# == Class: bacula::director
#
# This class manages the Bacula director component
#
# === Parameters
#
# All +bacula+ classes are called from the main +::bacula+ class.  Parameters
# are documented there.
#
# === Copyright
#
# Copyright 2012 Russell Harrison
#
# === License
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
class bacula::director(
    $console_password   = '',
    $db_backend         = 'sqlite',
    $db_database        = 'bacula',
    $db_host            = 'localhost',
    $db_password        = '',
    $db_port            = '3306',
    $db_user            = '',
    $db_user_host       = undef,
    $dir_template       = 'bacula/bacula-dir.conf.erb',
    $director_password  = '',
    $director_server    = undef,
    $mail_to            = undef,
    $manage_db          = false,
    $manage_db_tables   = true,
    $storage_server     = undef,
    $use_console        = false,
    $clients            = {}
  ) {
  include bacula::params

  $director_server_real = $director_server ? {
    undef   => $bacula::params::director_server_default,
    default => $director_server,
  }
  $storage_server_real = $storage_server ? {
    undef   => $bacula::params::storage_server_default,
    default => $storage_server,
  }
  $mail_to_real = $mail_to ? {
    undef   => $bacula::params::mail_to_default,
    default => $mail_to,
  }

  # This function takes each client specified in $clients
  # and generates a bacula::client resource for each
  #
  # It also searches top scope for variables in the style
  # $::bacula_client_mynode with values in format
  # fileset=Basic:noHome,client_schedule=Hourly
  # In order to work with Puppet 2.6 where create_resources isn't in core,
  # we just skip the top-level stuff for now.
#  if versioncmp($::puppetversion, '2.7.0') >= 0 {
#    generate_clients($clients)
#  } else {
    create_resources('bacula::client::config', $clients)
#  }

#TODO add postgresql support
  $db_package = $db_backend ? {
    'mysql'       => $bacula::params::director_mysql_package,
    'postgresql'  => $bacula::params::director_postgresql_package,
    default       => $bacula::params::director_sqlite_package,
  }

  package { $db_package:
    ensure => present,
  }

# Create the configuration for the Director and make sure the directory for
# the per-Client configuration is created before we run the realization for
# the exported files below

  file { '/etc/bacula/bacula-dir.d':
    ensure  => directory,
    owner   => 'bacula',
    group   => 'bacula',
    mode    => '0750',
    require => Package[$db_package],
  }

  file { '/etc/bacula/bacula-dir.d/empty.conf':
    ensure  => file,
    owner   => 'bacula',
    group   => 'bacula',
    mode    => '0640',
  }

  file { '/etc/bacula/bacula-dir.conf':
    ensure  => file,
    owner   => 'bacula',
    group   => 'bacula',
    mode    => '0640',
    content => template($dir_template),
    require => File[
      '/etc/bacula/bacula-dir.d/empty.conf',
      '/var/lib/bacula',
      '/var/log/bacula',
      '/var/spool/bacula',
      '/var/run/bacula'
    ],
    notify  => Service['bacula-dir'],
  }

  if $manage_db_tables   {
    case $db_backend {
      'mysql': {
        class { 'bacula::director::mysql':
          db_database   => $db_database,
          db_user       => $db_user,
          db_password   => $db_password,
          db_port       => $db_port,
          db_host       => $db_host,
          db_user_host  => $db_user_host,
          manage_db     => $manage_db,
        }
      }
      'sqlite': {
        class { 'bacula::director::sqlite':
          db_database => $db_database,
        }
      }
      default: {
        fail "The bacula module does not support managing the ${db_backend} backend database"
      }
    }
  }

# Register the Service so we can manage it through Puppet
  if $manage_db_tables {
    $service_require = Exec['make_db_tables']
  } else {
    $service_require = undef
  }

  service { 'bacula-dir':
    ensure      => running,
    name        => $bacula::params::director_service,
    enable      => true,
    hasstatus   => true,
    hasrestart  => true,
    require     => $service_require,
  }

}
