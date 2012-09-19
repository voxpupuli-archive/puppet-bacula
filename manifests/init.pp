# == Class: bacula
#
# This is the main class to manage all the components of a Bacula
# infrastructure. This is the only class that needs to be declared.
#
# === Parameters:
# [*db_backend*]
#   The database backend to use
# [*mail_to*]
#   Address to email reports to
# [*is_director*]
#   Whether the node should be a director
# [*is_client*]
#   Whether the node should be a client
# [*is_storage*]
#   Whether the node should be a storage server
# [*director_password*]
#   The director's password
# [*console_password*]
#   The console's password
# [*director_server*]
#   The FQDN of the bacula director
# [*storage_server*]
#   The FQDN of the storage server
# [*manage_console*]
#   Whether the bconsole should be managed on the node
# [*manage_bat*]
#   Whether the bat should be managed on the node
# [*director_template*]
#   The ERB template to use for configuring the director instead of the one
#   included with the module
# [*storage_template*]
#   The ERB template to use for configuring the storage daemon instead of the
#   one included with the module
# [*console_template*]
#   The ERB template to use for configuring the bconsole instead of the one
#   included with the module
# [*use_console*]
#   Whether to configure a console resource on the director
# [*db_user*]
#   The user to authenticate to +$db_db+ with.
# [*db_password*]
#   The password to authenticate +$db_user+ with
# [*db_host*]
#   The db server host to connect to
# [*db_database*]
#   The db database to connect to on +$db_host+
# [*manage_db_tables*]
#   Whether to create the DB tables during install
# [*manage_db*]
#   Whether to manage the existence of the database.  If true, the +$db_user+
#   must have privileges to create databases on +$db_host+
# [*clients*]
#   For directors, +$clients+ is a hash of clients.  The keys are the clients
#   while the value is a hash of parameters The parameters accepted are
#   +fileset+ and +schedule+.
#   Example clients hash:
#     $clients = {
#       'somenode' => {
#         'fileset'  => 'Basic:noHome',
#         'schedule' => 'Hourly',
#       },
#       'node2' => {
#         'fileset'  => 'Basic:noHome',
#         'schedule' => 'Hourly',
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
class bacula(
    $db_backend         = 'sqlite',
    $db_user            = '',
    $db_password        = '',
    $db_host            = 'localhost',
    $db_database        = 'bacula',
    $db_port            = '3306',
    $manage_db          = false,
    $manage_db_tables   = true,
    $mail_to            = undef,
    $is_director        = false,
    $is_client          = true,
    $is_storage         = false,
    $director_password  = '',
    $console_password   = '',
    $director_server    = undef,
    $storage_server     = undef,
    $manage_console     = false,
    $manage_bat         = false,
    $director_template  = undef,
    $storage_template   = undef,
    $console_template   = undef,
    $use_console        = false,
    $clients            = {},
    $packages           = undef
  ) inherits bacula::config {

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
  class { 'bacula::config::validate':
    db_backend        => $db_backend,
    mail_to           => $mail_to_real,
    is_director       => $is_director,
    is_client         => $is_client,
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
    manage_db_tables => $manage_db_tables,
    db_backend       => $db_backend,
    db_user          => $db_user,
    db_password      => $db_password,
    db_host          => $db_host,
    db_database      => $db_database,
    db_port          => $db_port,
    packages         => $packages,
  }


  if $is_director {
    class { 'bacula::director':
      db_backend       => $db_backend,
      director_server  => $director_server_real,
      storage_server   => $storage_server_real,
      password         => $director_password,
      mail_to          => $mail_to_real,
      dir_template     => $director_template,
      use_console      => $use_console,
      console_password => $console_password,
      db_user          => $db_user,
      db_password      => $db_password,
      db_host          => $db_host,
      db_port          => $db_port,
      db_database      => $db_database,
      require          => Class['bacula::common'],
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
      require           => Class['bacula::common'],
    }
  }

  if $is_client {
    class { 'bacula::client':
      director_server   => $director_server_real,
      director_password => $director_password,
      require           => Class['bacula::common'],
    }
  }

  if $manage_console {
    class { 'bacula::console':
      director_server   => $director_server_real,
      director_password => $director_password,
      console_template  => $console_template,
      require           => Class['bacula::common'],
    }
  }

  if $manage_bat {
    class { 'bacula::bat':
      require => Class['bacula::common'],
    }
  }
}
