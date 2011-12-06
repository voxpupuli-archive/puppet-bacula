class bacula::config {

  #If we have a top scope variable defined, use it.
  #Fall back to a hardcoded value.
  #
  #Since the top scope variable could be a string
  #(if from an ENC), we might need to convert it
  #to a boolean
  $manage_console = $::bacula_manage_console ? {
    undef   => false,
    default => $::bacula_manage_console,
  }
  if is_string($manage_console) {
    $safe_manage_console = str2bool($manage_console)
  } else {
    $safe_manage_console = $manage_console
  }

  $manage_bat = $::bacula_manage_bat ? {
    undef   => false,
    default => $::bacula_manage_bat,
  }
  if is_string($manage_bat) {
    $safe_manage_bat = str2bool($manage_bat)
  } else {
    $safe_manage_bat = $manage_bat
  }


  $is_director = $::bacula_is_director ? {
    undef   => false, 
    default => $::bacula_is_director,
  }
  if is_string($is_director) {
    $safe_is_director = str2bool($is_director)
  } else {
    $safe_is_director = $is_director
  }

  $is_client = $::bacula_is_client ? {
    undef   => true,
    default => $::bacula_is_client,
  }
  if is_string($is_client) {
    $safe_is_client = str2bool($is_client)
  } else {
    $safe_is_client = $is_client
  }

  $is_storage = $::bacula_is_storage ? {
    undef   => false,
    default => $::bacula_is_storage,
  }
  if is_string($is_storage) {
    $safe_is_storage = str2bool($is_storage)
  } else {
    $safe_is_storage= $is_storage
  }

  $use_console = $::bacula_use_console ? {
    undef   => false,
    default => $::bacula_use_console,
  }
  if is_string($use_console) {
    $safe_use_console = str2bool($use_console)
  } else {
    $safe_use_console = $use_console
  }

  $db_backend =  $::bacula_db_backend ? {
    undef   => 'sqlite',
    default => $::bacula_db_backend,
  }

  $mail_to = $::bacula_mail_to ? {
    undef   => "root@${domain}",
    default => $::bacula_mail_to,
  }

  $director_password = $::bacula_director_password ? {
    undef   => '',
    default => $::bacula_director_password,
  }

  $console_password = $::bacula_console_password ? {
    undef   => '',
    default => $::bacula_console_password,
  }

  $director_server = $::bacula_director_server ? {
    undef   => '',
    default => $::bacula_director_server,
  }

  $storage_server = $::bacula_storage_server ? {
    undef   => '',
    default => $::bacula_storage_server,
  }

  $director_package = $::bacula_director_package ? {
    undef   => 'bacula-director-common',
    default => $::bacula_director_package,
  }

  $storage_package = $::bacula_storage_package ? {
    undef   => 'bacula-storage-common',
    default => $::bacula_storage_package,
  }

  $client_package = $::bacula_client_package ? {
    undef   => 'bacula-client',
    default => $::bacula_client_package,
  }

  $director_sqlite_package = $::bacula_director_sqlite_package ? {
    undef   => 'bacula-director-sqlite3',
    default => $::bacula_director_sqlite_package,
  }

  $storage_sqlite_package = $::bacula_storage_sqlite_package ? {
    undef   => 'bacula-storage-sqlite3',
    default => $::bacula_storage_sqlite_package,
  }

  $director_mysql_package = $::bacula_director_mysql_package ? {
    undef   => 'bacula-director-mysql',
    default => $::bacula_director_mysql_package,
  }

  $storage_mysql_package = $::bacula_storage_mysql_package ? {
    undef   => 'bacula-storage-mysql',
    default => $::bacula_director_mysql_package,
  }

  #If it's undef, that's fine
  $director_template = $::bacula_director_template
  $storage_template  = $::bacula_storage_template
  $console_template  = $::bacula_console_template
}
