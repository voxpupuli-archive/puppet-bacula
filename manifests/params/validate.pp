# == Class: bacula::params::validate
#
# This class takes parameters which values need to be validated in some way.
# Because the class should only be called from the main <tt>bacula</tt> class the
# default values are intended to fail.
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
class bacula::params::validate (
  $backup_catalog        = '',
  $console_password      = '',
  $db_backend            = '',
  $db_database           = '',
  $db_host               = '',
  $db_password           = '',
  $db_port               = '',
  $db_user               = '',
  $director_password     = '',
  $director_server       = '',
  $is_client             = '',
  $is_director           = '',
  $is_storage            = '',
  $logwatch_enabled      = '',
  $mail_to               = '',
  $mail_to_daemon        = '',
  $mail_to_on_error      = '',
  $mail_to_operator      = '',
  $manage_bat            = '',
  $manage_config_dir     = '',
  $manage_console        = '',
  $manage_db             = '',
  $manage_db_tables      = '',
  $manage_logwatch       = '',
  $plugin_dir            = '',
  $storage_default_mount = '',
  $storage_server        = '',
  $tls_allowed_cn        = '',
  $tls_ca_cert           = '',
  $tls_ca_cert_dir       = '',
  $tls_cert              = '',
  $tls_key               = '',
  $tls_require           = '',
  $tls_verify_peer       = '',
  $use_console           = '',
  $use_tls               = '',
  $volume_autoprune      = '',
  $volume_autoprune_diff = '',
  $volume_autoprune_full = '',
  $volume_autoprune_incr = ''
) {
  include ::bacula::params
  # Validate our booleans
  validate_bool($backup_catalog)
  validate_bool($is_client)
  validate_bool($is_director)
  validate_bool($is_storage)
  validate_bool($logwatch_enabled)
  validate_bool($manage_bat)
  validate_bool($manage_config_dir)
  validate_bool($manage_console)
  validate_bool($manage_db)
  validate_bool($manage_db_tables)
  validate_bool($manage_logwatch)
  validate_bool($use_console)
  validate_bool($use_tls)

  if $use_console {
    if empty($console_password) {
      fail 'console_password cannot be empty'
    }
  }

  if $is_director {
    validate_re($volume_autoprune, '^(Yes|yes|No|no)$')
    validate_re($volume_autoprune_diff, '^(Yes|yes|No|no)$')
    validate_re($volume_autoprune_full, '^(Yes|yes|No|no)$')
    validate_re($volume_autoprune_incr, '^(Yes|yes|No|no)$')

    # Validate mail_to variables are email address
    if $mail_to != undef {
      validate_re($mail_to, '^[\w-]+@([\w-]+\.)+[\w-]+$')
    } elsif $mail_to == undef and $mail_to_on_error == undef {
      validate_re($::bacula::params::mail_to_default, '^[\w-]+@([\w-]+\.)+[\w-]+$')
    }
    if $mail_to_daemon != undef {
      validate_re($mail_to_daemon, '^[\w-]+@([\w-]+\.)+[\w-]+$')
    }
    if $mail_to_on_error != undef {
      validate_re($mail_to_on_error, '^[\w-]+@([\w-]+\.)+[\w-]+$')
    }
    if $mail_to_operator != undef {
      validate_re($mail_to_operator, '^[\w-]+@([\w-]+\.)+[\w-]+$')
    }
  }

  # Validate the director and storage servers given are fully qualified
  # domain names
  validate_re($director_server, '^[a-z0-9_-]+(\.[a-z0-9_-]+){2,}$')
  validate_re($storage_server, '^[a-z0-9_-]+(\.[a-z0-9_-]+){2,}$')

  # Validate server values aren't empty
  if empty($director_server) {
    fail '$director_server cannot be empty'
  }

  if empty($storage_server) {
    fail '$storage_server cannot be empty'
  }

  # Validate the passwords aren't empty
  if empty($director_password) {
    fail '$director_password cannot be empty'
  }

  if $is_director {

    if empty($db_database) {
      fail '$db_database cannot be empty'
    }

    case $db_backend {
      'sqlite', 'postgresql' : {
      }
      'mysql'                : {
        if empty($db_host) {
          fail '$db_host cannot be empty'
        }

        if empty($db_user) {
          fail '$db_user cannot be empty'
        }

        if !is_integer($db_port) {
          fail '$db_port must be a port number'
        }

        if empty($db_password) {
          fail '$db_password cannot be empty'
        }
      }
      default                : {
        fail '$db_backend must be either \'sqlite\', \'postgresql\', or \'mysql\''
      }
    }
  }

  if $manage_console {
    if empty($console_password) {
      fail '$console_password cannot be empty'
    }
  }

  validate_absolute_path($storage_default_mount)

  if $plugin_dir != undef {
    validate_absolute_path($plugin_dir)
  }

  if $use_tls {
    case $tls_allowed_cn {
      undef   : { }
      default : { validate_array($tls_allowed_cn) }
    }

    if $tls_ca_cert {
      validate_absolute_path($tls_ca_cert)
    }

    if $tls_ca_cert_dir {
      validate_absolute_path($tls_ca_cert_dir)
    }
    validate_absolute_path($tls_cert)
    validate_absolute_path($tls_key)

    if !($tls_require in ['yes', 'no']) {
      fail '$tls_require must be either \'yes\' or \'no\''
    }

    if !($tls_verify_peer in ['yes', 'no']) {
      fail '$tls_verify_peer must be either \'yes\' or \'no\''
    }
  }
}
