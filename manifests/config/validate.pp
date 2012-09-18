# == Class: bacula::config::validate
#
# This class takes parameters which values need to be validated in some way
#
class bacula::config::validate(
    $db_backend         = undef,
    $db_database        = undef,
    $db_port            = undef,
    $db_host            = undef,
    $db_user            = undef,
    $db_password        = undef,
    $mail_to            = undef,
    $is_director        = undef,
    $is_client          = undef,
    $is_storage         = undef,
    $director_password  = undef,
    $console_password   = undef,
    $director_server    = undef,
    $storage_server     = undef,
    $manage_console     = undef,
    $manage_bat         = undef,
    $console_password   = undef,
    $use_console        = undef,
    $manage_db          = undef,
    $manage_db_tables   = undef
  ) {

  #Validate our booleans
  validate_bool($manage_console)
  validate_bool($manage_bat)
  validate_bool($is_director)
  validate_bool($is_storage)
  validate_bool($is_client)
  validate_bool($use_console)
  validate_bool($manage_db_tables)
  validate_bool($manage_db)

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
    fail '$director_server cannot be empty'
  }
  if empty($storage_server) {
    fail '$storage_server cannot be empty'
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

  if empty($db_database) {
    fail '$db_database cannot be empty'
  }

  if $db_backend != 'sqlite' {
    if empty($db_host) {
      fail '$db_host cannot be empty'
    }
    if empty($db_user) {
      fail '$db_user cannot be empty'
    }
    if ! is_integer($db_port) {
      fail '$db_port must be a port number'
    }
    if empty($db_password) {
      fail '$db_password cannot be empty'
    }
  }
}
