# Class: bacula
#
# This is the main class to manage all the components of a Bacula
# infrastructure. This is the only class that needs to be declared.
#
# Parameters:
#   $db_backend:
#     The database backend to use
#   $mail_to:
#     Address to email reports to
#   $is_director:
#     Whether the node should be a director
#   $is_client
#     Whether the node should be a client
#   $is_storage
#     Whether the node should be a storage server
#   $director_password
#     The director's password
#   $console_password
#     The console's password
#   $director_server
#     The FQDN of the bacula director
#   $storage_server
#     The FQDN of the storage server
#   $manage_console
#     Whether the bconsole should be managed on the node
#   $manage_bat
#     Whether the bat should be managed on the node
#   $director_package
#     The name of the package to install the director
#   $storage_package
#     The name of the package to install the storage
#   $client_package
#     The name of the package to install the client
#   $director_sqlite_package
#     The name of the package to install the director's sqlite functionality
#   $storage_sqlite_package
#     The name of the package to install the storage daemon's sqlite functionality
#   $director_mysql_package
#     The name of the package to install the director's mysql functionality
#   $storage_mysql_package
#     The name of the package to install the storage's sqlite functionality
#   $director_template
#     The ERB template to use for configuring the director instead of the one included with the module
#   $storage_template
#     The ERB template to use for configuring the storage daemon instead of the one included with the module
#   $console_template
#     The ERB template to use for configuring the bconsole instead of the one included with the module
#   $use_console
#     Whether to configure a console resource on the director
#   $console_password
#     The password to use for the console resource on the director
#   $db_user
#     The user to authenticate to $db_db with.
#   $db_password
#     The password to authenticate $db_user with
#   $db_host
#     The db server host to connect to
#   $db_database
#     The db database to connect to on $db_host
#   $console_package
#     The package to install the bconsole application
#   $manage_db_tables
#     Whether to create the DB tables during install
#   $manage_db
#     Whether to manage the existance of the database.  If true, the $db_user must have privileges 
#     to create databases on $db_host
#   $clients
#     For directors, $clients is a hash of clients.  The keys are the clients while the value is a hash of parameters
#     The parameters accepted are fileset and schedule.
#
# Example clients hash
#  $clients = {
#    'somenode' => {
#      'fileset'  => 'Basic:noHome',
#      'schedule' => 'Hourly',
#    },
#    'node2' => {
#      'fileset'  => 'Basic:noHome',
#      'schedule' => 'Hourly',
#    }
#  }
#
#
# Sample Usage
#
# class { 'bacula':
#   is_storage        => true,
#   is_director       => true,
#   is_client         => true,
#   manage_console    => true,
#   director_password => 'xxxxxxxxx',
#   console_password  => 'xxxxxxxxx',
#   director_server   => 'bacula.domain.com',
#   mail_to           => 'bacula-admin@domain.com',
#   storage_server    => 'bacula.domain.com',
#   clients           => $clients,
# }
class bacula(
    $db_backend              = $bacula::config::db_backend,
    $db_user                 = $bacula::config::db_user,
    $db_password             = $bacula::config::db_password,
    $db_host                 = $bacula::config::db_host,
    $db_database             = $bacula::config::db_database,
    $db_port                 = $bacula::config::db_port,
    $manage_db               = $bacula::config::safe_manage_db,
    $manage_db_tables        = $bacula::config::safe_manage_db_tables,
    $mail_to                 = $bacula::config::mail_to,
    $is_director             = $bacula::config::safe_is_director, 
    $is_client               = $bacula::config::safe_is_client,
    $is_storage              = $bacula::config::safe_is_storage,
    $director_password       = $bacula::config::director_password,
    $console_password        = $bacula::config::console_password,
    $director_server         = $bacula::config::bacula_director_server,
    $storage_server          = $bacula::config::bacula_storage_server,
    $manage_console          = $bacula::config::safe_manage_console,
    $console_package         = $bacula::config::console_package,
    $manage_bat              = $bacula::config::safe_manage_bat,
    $director_package        = $bacula::config::director_package,
    $storage_package         = $bacula::config::storage_package,
    $client_package          = $bacula::config::client_package,
    $director_sqlite_package = $bacula::config::director_sqlite_package,
    $storage_sqlite_package  = $bacula::config::storage_sqlite_package,
    $director_mysql_package  = $bacula::config::director_mysql_package,
    $storage_mysql_package   = $bacula::config::storage_mysql_package,
    $director_template       = $bacula::config::director_template,
    $storage_template        = $bacula::config::storage_template,
    $console_template        = $bacula::config::console_template,
    $use_console             = $bacula::config::safe_use_console,
    $console_password        = $bacula::config::console_password,
    $clients                 = {}
  ) inherits bacula::config {
    


  #Validate our parameters
  #It's ugly to do it in the parent class
  class { 'bacula::config::validate':
    db_backend        => $db_backend,
    mail_to           => $mail_to,
    is_director       => $is_director,
    is_client         => $is_client,
    is_storage        => $is_storage,
    director_password => $director_password,
    use_console       => $use_console,
    console_password  => $console_password,
    director_server   => $director_server,
    storage_server    => $storage_server,
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
      server           => $director_server,
      storage_server   => $storage_server,
      password         => $director_password,
      mysql_package    => $director_mysql_package,
      sqlite_package   => $director_sqlite_package,
      director_package => $director_package,
      mail_to          => $mail_to,
      template         => $director_template,
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
      director_server   => $director_server,
      director_password => $director_password,
      storage_server    => $storage_server,
      mysql_package     => $storage_mysql_package,
      sqlite_package    => $storage_sqlite_package,
      storage_package   => $storage_package,
      console_password  => $console_password,
      template          => $storage_template,
      require           => Class['bacula::common'],
    }
  }

  if $is_client {
    class { 'bacula::client': 
      director_server   => $director_server,
      director_password => $director_password,
      client_package    => $client_package,
      require           => Class['bacula::common'],
    }
  }

  if $manage_console {
    class { 'bacula::console':
      director_server   => $director_server,
      director_password => $director_password,
      console_package   => $console_package,
      require           => Class['bacula::common'],
    }
  }

  if $manage_bat {
    class { 'bacula::bat': 
      require => Class['bacula::common'],
    }
  }
}
