# == Class: bacula
#
# This is the main class to manage all the components of a Bacula
# infrastructure. This is the only class that needs to be declared.
#
# === Parameters:
#
# [*clients*]
#   For directors, +$clients+ is a hash of clients.  The keys are the clients while the value is a hash of parameters. The
#   parameters accepted are the same as the +bacula::client::config+ define.
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
# [*plugin_dir*]
#   The directory Bacula plugins are stored in. Use this parameter if you want to override the default plugin
#   location. If this is anything other than +undef+ it will also configure plugins on older distros were the default
#   package is too old to support plugins.  Only use if the version in the distro repositories supports plugins or
#   you have included a respository with a newer Bacula packaged for your distro.
# [*storage_server*]
#   The FQDN of the storage server
# [*storage_template*]
#   The ERB template to use for configuring the storage daemon instead of the
#   one included with the module
# [*use_console*]
#   Whether to configure a console resource on the director
#
# === Sample Usage
#
#  $clients = {
#    'node1.example.com' => {
#      'fileset'         => 'Basic:noHome',
#      'client_schedule' => 'Hourly',
#    },
#    'node2.example.com' => {
#      'fileset'         => 'Basic:noHome',
#      'client_schedule' => 'Hourly',
#    }
#  }
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
  $console_password  = '',
  $console_template  = undef,
  $db_backend        = 'sqlite',
  $db_user           = '',
  $db_password       = '',
  $db_host           = 'localhost',
  $db_user_host      = undef,
  $db_database       = 'bacula',
  $db_port           = '3306',
  $director_password = '',
  $director_server   = undef,
  $director_template = undef,
  $is_client         = true,
  $is_director       = false,
  $is_storage        = false,
  $mail_to           = undef,
  $manage_db         = false,
  $manage_db_tables  = true,
  $manage_console    = false,
  $manage_bat        = false,
  $plugin_dir        = undef,
  $storage_server    = undef,
  $storage_template  = undef,
  $use_console       = false,
  $clients           = {}
) {
  include bacula::params

  $director_server_real = $director_server ? {
    undef   => $bacula::params::director_server_default,
    default => $director_server,
  }
  $storage_server_real  = $storage_server ? {
    undef   => $bacula::params::storage_server_default,
    default => $storage_server,
  }
  $mail_to_real         = $mail_to ? {
    undef   => $bacula::params::mail_to_default,
    default => $mail_to,
  }

  case $plugin_dir {
    undef : {
      $use_plugins     = $bacula::params::use_plugins
      $plugin_dir_real = $bacula::params::plugin_dir
    }
    default : {
      $use_plugins     = true
      $plugin_dir_real = $plugin_dir
    }
  }

  # Validate our parameters
  # It's ugly to do it in the parent class
  class { 'bacula::params::validate':
    console_password  => $console_password,
    db_backend        => $db_backend,
    db_database       => $db_database,
    db_host           => $db_host,
    db_password       => $db_password,
    db_port           => $db_port,
    db_user           => $db_user,
    director_password => $director_password,
    director_server   => $director_server_real,
    is_client         => $is_client,
    is_director       => $is_director,
    is_storage        => $is_storage,
    mail_to           => $mail_to_real,
    manage_bat        => $manage_bat,
    manage_console    => $manage_console,
    manage_db         => $manage_db,
    manage_db_tables  => $manage_db_tables,
    plugin_dir        => $plugin_dir_real,
    storage_server    => $storage_server_real,
    use_console       => $use_console,
    use_plugins       => $use_plugins,
  }

  class { 'bacula::common':
    db_backend       => $db_backend,
    db_database      => $db_database,
    db_host          => $db_host,
    db_password      => $db_password,
    db_port          => $db_port,
    db_user          => $db_user,
    is_client        => $is_client,
    is_director      => $is_director,
    is_storage       => $is_storage,
    manage_bat       => $manage_bat,
    manage_console   => $manage_console,
    manage_db_tables => $manage_db_tables,
    plugin_dir       => $plugin_dir_real,
    use_plugins      => $use_plugins,
  }

  if $is_director {
    class { 'bacula::director':
      clients           => $clients,
      console_password  => $console_password,
      db_backend        => $db_backend,
      db_database       => $db_database,
      db_host           => $db_host,
      db_password       => $db_password,
      db_port           => $db_port,
      db_user           => $db_user,
      db_user_host      => $db_user_host,
      dir_template      => $director_template,
      director_password => $director_password,
      director_server   => $director_server_real,
      mail_to           => $mail_to_real,
      manage_db         => $manage_db,
      manage_db_tables  => $manage_db_tables,
      plugin_dir        => $plugin_dir_real,
      storage_server    => $storage_server_real,
      use_console       => $use_console,
      use_plugins       => $use_plugins,
    }
  }

  if $is_storage {
    class { 'bacula::storage':
      console_password  => $console_password,
      db_backend        => $db_backend,
      director_password => $director_password,
      director_server   => $director_server_real,
      plugin_dir        => $plugin_dir_real,
      storage_server    => $storage_server_real,
      storage_template  => $storage_template,
      use_plugins       => $use_plugins,
    }
  }

  if $is_client {
    class { 'bacula::client':
      director_server   => $director_server_real,
      director_password => $director_password,
      plugin_dir        => $plugin_dir_real,
      use_plugins       => $use_plugins,
    }
  }

  if $manage_console {
    class { 'bacula::console':
      console_template  => $console_template,
      director_password => $director_password,
      director_server   => $director_server_real,
    }
  }

  if $manage_bat {
    class { 'bacula::console::bat':
    }
  }
}
