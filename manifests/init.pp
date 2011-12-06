class bacula(
    $db_backend              = $bacula::config::db_backend,
    $mail_to                 = $bacula::config::mail_to,
    $is_director             = $bacula::config::safe_is_director, 
    $is_client               = $bacula::config::safe_is_client,
    $is_storage              = $bacula::config::safe_is_storage,
    $director_password       = $bacula::config::director_password,
    $console_password        = $bacula::config::console_password,
    $director_server         = $bacula::config::bacula_director_server,
    $storage_server          = $bacula::config::bacula_storage_server,
    $manage_console          = $bacula::config::safe_manage_console,
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
    $console_password        = $bacula::config::console_password
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
    }
  }

  if $is_client {
    class { 'bacula::client': 
      director_server   => $director_server,
      director_password => $director_password,
      client_package    => $client_package,
    }
  }

  if $manage_console {
    class { 'bacula::console':
      director_server   => $director_server,
      director_password => $director_password,
    }
  }

  if $manage_bat {
    class { 'bacula::bat': }
  }
}
