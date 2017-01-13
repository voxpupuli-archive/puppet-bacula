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
  $backup_catalog        = undef,
  $console_password      = undef,
  $db_backend            = undef,
  $db_database           = undef,
  $db_host               = undef,
  $db_password           = undef,
  $db_port               = undef,
  $db_user               = undef,
  $director_password     = undef,
  $director_server       = undef,
  $is_client             = undef,
  $is_director           = undef,
  $is_storage            = undef,
  $logwatch_enabled      = undef,
  $mail_to               = undef,
  $mail_to_daemon        = undef,
  $mail_to_on_error      = undef,
  $mail_to_operator      = undef,
  $manage_bat            = undef,
  $manage_config_dir     = undef,
  $manage_console        = undef,
  $manage_db             = undef,
  $manage_db_tables      = undef,
  $manage_logwatch       = undef,
  $plugin_dir            = undef,
  $storage_default_mount = undef,
  $storage_server        = undef,
  $tls_allowed_cn        = undef,
  $tls_ca_cert           = undef,
  $tls_ca_cert_dir       = undef,
  $tls_cert              = undef,
  $tls_key               = undef,
  $tls_require           = undef,
  $tls_verify_peer       = undef,
  $use_console           = undef,
  $use_tls               = undef,
  $use_vol_purge_script  = false,
  $use_vol_purge_mvdir   = undef,
  $volume_autoprune      = undef,
  $volume_autoprune_diff = undef,
  $volume_autoprune_full = undef,
  $volume_autoprune_incr = undef
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

    validate_bool($use_vol_purge_script)
    if $use_vol_purge_script {
      unless $is_director and $is_storage {
        fail('The automatic volume script requires that the director and storage daemon be on the same host')
      }
      if $use_vol_purge_mvdir != undef {
        validate_absolute_path($use_vol_purge_mvdir)
      }
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
      'mysql', 'postgresql'  : {
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
      'sqlite': {
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
