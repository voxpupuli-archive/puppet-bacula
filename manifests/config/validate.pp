class bacula::config::validate(
    $db_backend,
    $mail_to,
    $is_director,
    $is_client,
    $is_storage,
    $director_password,
    $console_password,
    $director_server,
    $storage_server,
    $manage_console,
    $manage_bat,
    $manage_mysql,
    $manage_sqlite,
    $console_password,
    $use_console
  ) {

  #Validate our booleans
  validate_bool($manage_console)
  validate_bool($manage_bat)
  validate_bool($is_director)
  validate_bool($is_storage)
  validate_bool($is_client)
  validate_bool($manage_mysql)
  validate_bool($manage_sqlite)
  validate_bool($use_console)

  if $use_console {
    if empty($console_password) {
      fail 'console_password cannot be empty'
    }
  }

  #Validate mail_to is an email address
  if $is_director {
    validate_re($mail_to, '^[\w-]+@([\w-]+\.)+[\w-]+$')
  }
  
  #Validate the director and storage servers given are fully qualified domain names
  validate_re($director_server, '^[a-z0-9_-]+(\.[a-z0-9_-]+){2,}$')
  validate_re($storage_server, '^[a-z0-9_-]+(\.[a-z0-9_-]+){2,}$')

  #Validate server values aren't empty
  if empty($director_server) {
    failse '$director_server cannot be empty'
  }
  if empty($storage_server) {
    fail '$storage_server cannot be empty'
  }

  #Validate we support db_backend
  if $is_director or $is_storage {
    if ! ($db_backend in ['mysql','sqlite']) {
      fail 'Bacula db_backend must be either mysql or sqlite'
    }
  }

  #Validate the passwords aren't empty
  if $is_director {
    if empty($director_password) {
      fail '$director_password cannot be empty'
    }
  }

  if $manage_console {
    if empty($console_password) {
      fail '$console_password cannot be empty'
    }
  }
}
