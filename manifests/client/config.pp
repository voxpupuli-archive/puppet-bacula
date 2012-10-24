# == Define: bacula::client::config
#
# Install a config file describing a +bacula-fd+ client on the director.
#
# === Parameters
#
# [*client_schedule*]
#   The schedule for backups to be performed.
# [*db_backend*]
#   The database backend of the catalog storing information about the backup
# [*director_password*]
#   The director's password the client is connecting to.
# [*director_server*]
#   The FQDN of the director server the client will connect to.
# [*pool*]
#   The pool used by the client for backups
# [*fileset*]
#   The file set used by the client for backups
# [*storage_server*]
#   The storage server hosting the pool this client will backup to
#
# === Examples
#
#   bacula::client::config { 'client1.example.com' :
#     client_schedule   => 'WeeklyCycle',
#     db_backend        => 'mysql',
#     director_password => 'directorpassword',
#     director_server   => 'bacula.example.com',
#     pool              => 'otherpool',
#     fileset           => 'Basic:noHome',
#     storage_server    => 'bacula.example.com',
#   }
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
define bacula::client::config (
  $client_schedule   = 'WeeklyCycle',
  $db_backend        = undef,
  $director_password = '',
  $director_server   = undef,
  $fileset           = 'Basic:noHome',
  $pool              = "${storage_server_real}:pool:default"
  $storage_server    = undef
) {
  include bacula::params

  if !is_domain_name($name) {
    fail "Name for client ${name} must be a fully qualified domain name"
  }

  case $db_backend {
    undef   : {
      $db_backend_real = $bacula::director::db_backend ? {
        undef   => 'sqlite',
        default => $bacula::director::db_backend,
      }
    }
    default : {
      $db_backend_real = $db_backend
    }
  }

  case $director_password {
    ''      : {
      $director_password_real = $bacula::director::director_password ? {
        undef   => '',
        default => $bacula::director::director_password,
      }
    }
    default : {
      $director_password_real = $director_password
    }
  }

  case $director_server {
    undef   : {
      $director_server_real = $bacula::director::director_server ? {
        undef   => $bacula::params::director_server_default,
        default => $bacula::director::director_server,
      }
    }
    default : {
      $director_server_real = $director_server
    }
  }

  if !is_domain_name($director_server_real) {
    fail "director_server=${director_server_real} must be a fully qualified domain name"
  }

  case $storage_server {
    undef   : {
      $storage_server_real = $bacula::director::storage_server ? {
        undef   => $bacula::params::storage_server_default,
        default => $bacula::director::storage_server,
      }
    }
    default : {
      $storage_server_real = $storage_server
    }
  }

  if !is_domain_name($storage_server_real) {
    fail "storage_server=${storage_server_real} must be a fully qualified domain name"
  }

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
