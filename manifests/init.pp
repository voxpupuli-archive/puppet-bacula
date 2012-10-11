# == Class: bacula
#
# This is the main class to manage all the components of a Bacula
# infrastructure. This is the only class that needs to be declared.
#
# === Parameters:
#
# [*console_password*]
#   The console's password
# [*console_template*]
#   The ERB template to use for configuring the bconsole instead of the one
#   included with the module
# [*db_backend*]
#   The database backend to use
# [*db_database*]
#   The db database to connect to on +$db_host+
# [*db_host*]
#   The db server host to connect to
# [*db_password*]
#   The password to authenticate +$db_user+ with
# [*db_port*]
#   The port to connect to the database server on
# [*db_user*]
#   The user to authenticate to +$db_db+ with.
# [*db_user_host*]
#   The host string used by MySQL to allow connections from
# [*director_password*]
#   The director's password
# [*director_server*]
#   The FQDN of the bacula director
# [*director_template*]
#   The ERB template to use for configuring the director instead of the one
#   included with the module
# [*is_client*]
#   Whether the node should be a client
# [*is_director*]
#   Whether the node should be a director
# [*is_storage*]
#   Whether the node should be a storage server
# [*mail_to*]
#   Address to email reports to
# [*manage_console*]
#   Whether the bconsole should be managed on the node
# [*manage_bat*]
#   Whether the bat should be managed on the node
# [*manage_db*]
#   Whether to manage the existence of the database.  If true, the +$db_user+
#   must have privileges to create databases on +$db_host+
# [*manage_db_tables*]
#   Whether to create the DB tables during install
# [*storage_server*]
#   The FQDN of the storage server
# [*storage_template*]
#   The ERB template to use for configuring the storage daemon instead of the
#   one included with the module
# [*use_console*]
#   Whether to configure a console resource on the director
# [*clients*]
#   For directors, +$clients+ is a hash of clients.  The keys are the clients
#   while the value is a hash of parameters The parameters accepted are
#   +fileset+ and +client_schedule+.
#   Example clients hash:
#     $clients = {
#       'somenode.example.com'  => {
#         'fileset'         => 'Basic:noHome',
#         'client_schedule' => 'Hourly',
#       },
#       'node2.example.com'     => {
#         'fileset'         => 'Basic:noHome',
#         'client_schedule' => 'Hourly',
#       }
#     }
#
# === Sample Usage
#
#  class { 'bacula':
#    is_storage        => true,
#    is_director       => true,
#    is_client         => true,
#    manage_console    => true,
#    director_password => 'xxxxxxxxx',
#    console_password  => 'xxxxxxxxx',
#    director_server   => 'bacula.domain.com',
#    mail_to           => 'bacula-admin@domain.com',
#    storage_server    => 'bacula.domain.com',
#    clients           => $clients,
#  }
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
class bacula (
  $console_password   = '',
  $console_template   = undef,
  $db_backend         = 'sqlite',
  $db_user            = '',
  $db_password        = '',
  $db_host            = 'localhost',
  $db_user_host       = undef,
  $db_database        = 'bacula',
  $db_port            = '3306',
  $director_password  = '',
  $director_server    = undef,
  $director_template  = undef,
  $is_client          = true,
  $is_director        = false,
  $is_storage         = false,
  $mail_to            = undef,
  $manage_db          = false,
  $manage_db_tables   = true,
  $manage_console     = false,
  $manage_bat         = false,
  $storage_server     = undef,
  $storage_template   = undef,
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
  #Validate our parameters
  #It's ugly to do it in the parent class
  class { 'bacula::params::validate':
    db_backend        => $db_backend,
    mail_to           => $mail_to_real,
    is_client         => $is_client,
    is_director       => $is_director,
    is_storage        => $is_storage,
    director_password => $director_password,
    use_console       => $use_console,
    console_password  => $console_password,
    director_server   => $director_server_real,
    storage_server    => $storage_server_real,
    manage_console    => $manage_console,
    manage_bat        => $manage_bat,
    db_user           => $db_user,
    db_password       => $db_password,
    db_host           => $db_host,
    db_database       => $db_database,
    db_port           => $db_port,
    manage_db_tables  => $manage_db_tables,
    manage_db         => $manage_db,
  }

  class { 'bacula::common':
    manage_db_tables  => $manage_db_tables,
    db_backend        => $db_backend,
    db_user           => $db_user,
    db_password       => $db_password,
    db_host           => $db_host,
    db_database       => $db_database,
    db_port           => $db_port,
    is_client         => $is_client,
    is_director       => $is_director,
    is_storage        => $is_storage,
    manage_console    => $manage_console,
    manage_bat        => $manage_bat,
  }


  if $is_director {
    class { 'bacula::director':
      db_backend        => $db_backend,
      director_server   => $director_server_real,
      storage_server    => $storage_server_real,
      director_password => $director_password,
      mail_to           => $mail_to_real,
      dir_template      => $director_template,
      use_console       => $use_console,
      console_password  => $console_password,
      db_user           => $db_user,
      db_password       => $db_password,
      db_host           => $db_host,
      db_user_host      => $db_user_host,
      db_port           => $db_port,
      db_database       => $db_database,
      manage_db         => $manage_db,
      manage_db_tables  => $manage_db_tables,
      clients           => $clients,
    }
  }

  if $is_storage {
    class { 'bacula::storage':
      db_backend        => $db_backend,
      director_server   => $director_server_real,
      director_password => $director_password,
      storage_server    => $storage_server_real,
      console_password  => $console_password,
      storage_template  => $storage_template,
    }
  }

  if $is_client {
    class { 'bacula::client':
      director_server   => $director_server_real,
      director_password => $director_password,
    }
  }

  if $manage_console {
    class { 'bacula::console':
      director_server   => $director_server_real,
      director_password => $director_password,
      console_template  => $console_template,
    }
  }

  if $manage_bat {
    class { 'bacula::console::bat':
    }
  }
}
