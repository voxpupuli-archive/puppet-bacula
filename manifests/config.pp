# Class:: bacula::config
# 
# This class determines default values for parameters needed
# to configure the bacula class.  It looks for variables in 
# top scope (probably from an ENC such as Dashboard).
# If the variable doesn't exist in top scope, fall back to
# a hard coded default. 
# 
# Some of the variables in this class need to be booleans.
# However, if we get the value from top scope, it could 
# be a string since Dashboard can't express booleans.
# So we need to see if it's a string and attempt to
# convert it to a boolean
#
# Sample Usage:
#
# class { 'bacula::config': }
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

  $manage_db = $::bacula_manage_db ? {
    undef   => false,
    default => $::bacula_manage_db,
  }
  if is_string($manage_db) {
    $safe_manage_db = str2bool($manage_db)
  } else {
    $safe_manage_db = $manage_db
  }

  $manage_db_tables = $::bacula_manage_db_tables ? {
    undef   => true,
    default => $::bacula_manage_db_tables,
  }
  if is_string($manage_db_tables) {
    $safe_manage_db_tables = str2bool($manage_db_tables)
  } else {
    $safe_manage_db_tables = $manage_db_tables
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
    undef   => '', # By default, let the db package handle this
    default => $::bacula_director_package,
  }

  $storage_package = $::bacula_storage_package ? {
    undef   => '', # By default, let the db package handle this
    default => $::bacula_storage_package,
  }

  $client_package = $::bacula_client_package ? {
    undef   => 'bacula-client',
    default => $::bacula_client_package,
  }

  $director_mysql_package  = $::bacula_director_mysql_package ? {
    undef   => 'bacula-director-mysql',
    default => $::bacula_director_mysql_package,
  }

  $storage_mysql_package  = $::bacula_storage_mysql_package ? {
    undef   => 'bacula-sd-mysql',
    default => $::bacula_storage_mysql_package,
  }

  $director_sqlite_package = $::bacula_director_sqlite_package ? {
    undef   => 'bacula-director-sqlite3',
    default => $::bacula_director_sqlite_package,
  }

  $storage_sqlite_package = $::bacula_storage_sqlite_package ? {
    undef   => 'bacula-sd-sqlite3',
    default => $::bacula_storage_sqlite_package,
  }

  $director_db_package = $::bacula_director_db_package ? {
    undef   => '',
    default => $::bacula_director_db_package,
  }

  $console_package = $::bacula_console_package ? {
    undef   => 'bacula-console',
    default => $::bacula_console_package,
  }

  $storage_db_package = $::bacula_storage_db_package ? {
    undef   => '',
    default => $::bacula_director_db_package,
  }

  $db_user = $::bacula_db_user ? {
    undef   => '',
    default => $::bacula_db_user,
  }
 
  $db_port = $::bacula_db_port ? {
    undef   => '3306',
    default => $::bacula_db_user,
  }

  $db_password = $::bacula_db_password ? {
    undef   => '',
    default => $::bacula_db_password,
  }

  $db_host = $::bacula_db_host ? {
    undef   => 'localhost',
    default => $::bacula_db_host,
  }

  $db_database = $::bacula_db_database ? {
    undef   => 'bacula',
    default => $::bacula_db_database,
  }


  #If it's undef, that's fine
  $director_template = $::bacula_director_template
  $storage_template  = $::bacula_storage_template
  $console_template  = $::bacula_console_template
}
