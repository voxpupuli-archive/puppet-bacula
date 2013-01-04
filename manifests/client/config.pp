# == Define: bacula::client::config
#
# Install a config file describing a <tt>bacula-fd</tt> client on the director.
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
# [*fileset*]
#   The file set used by the client for backups
# [*pool*]
#   The pool used by the client for backups
# [*run_scripts*]
#   An array of hashes containing the parameters for any
#   {RunScripts}[http://www.bacula.org/5.0.x-manuals/en/main/main/Configuring_Director.html#6971] to include in the backup job
#   definition. For each hash in the array a <tt>RunScript</tt> directive block will be inserted with the <tt>key = value</tt>
#   settings from the hash.  Note: The <tt>RunsWhen</tt> key is required.
# [*storage_server*]
#   The storage server hosting the pool this client will backup to
# [*tls_ca_cert*]
#   The full path and filename specifying a PEM encoded TLS CA certificate(s). Multiple certificates are permitted in
#   the file. One of <tt>TLS CA Certificate File</tt> or <tt>TLS CA Certificate Dir</tt> are required in a server context if
#   <tt>TLS Verify Peer</tt> is also specified, and are always required in a client context.
# [*tls_ca_cert_dir*]
#   Full path to TLS CA certificate directory. In the current implementation, certificates must be stored PEM
#   encoded with OpenSSL-compatible hashes, which is the subject name's hash and an extension of .0. One of
#   <tt>TLS CA Certificate File</tt> or <tt>TLS CA Certificate Dir</tt> are required in a server context if <tt>TLS Verify Peer</tt>
#   is also specified, and are always required in a client context.
# [*use_tls*]
#   Whether to use {Bacula TLS - Communications
#   Encryption}[http://www.bacula.org/en/dev-manual/main/main/Bacula_TLS_Communications.html].
#
# === Examples
#
#   bacula::client::config { 'client1.example.com' :
#     client_schedule   => 'WeeklyCycle',
#     db_backend        => 'mysql',
#     director_password => 'directorpassword',
#     director_server   => 'bacula.example.com',
#     fileset           => 'Basic:noHome',
#     pool              => 'otherpool',
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
  $pool              = 'default',
  $run_scripts       = undef,
  $storage_server    = undef,
  $tls_ca_cert       = undef,
  $tls_ca_cert_dir   = undef,
  $tls_require       = 'yes',
  $use_tls           = false
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

  if $run_scripts {
    case type($run_scripts) {
      'array' : {
        # TODO figure out how to validate each item in the array is a hash.
        $run_scripts_real = $run_scripts
      }
      'hash'  : {
        $run_scripts_real = [ $run_scripts ]
      }
      default : {
        fail("run_scripts = ${run_scripts} must be an array of hashes or a hash")
      }
    }
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
