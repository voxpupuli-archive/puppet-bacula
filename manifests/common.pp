# == Class: bacula::common
#
# This class enforces common resources needed by all bacula components
#
# === Parameters
#
# All <tt>bacula+ classes are called from the main <tt>::bacula</tt> class.  Parameters
# are documented there.
#
# === Actions:
# * Enforce the bacula user and groups exist
# * Enforce the <tt>/var/spool/bacula+ is a director and <tt>/var/lib/bacula</tt>
#   points to it
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
class bacula::common (
  $db_backend        = 'sqlite',
  $db_database       = 'bacula',
  $db_host           = 'localhost',
  $db_password       = '',
  $db_port           = '3306',
  $db_user           = '',
  $is_client         = true,
  $is_director       = false,
  $is_storage        = false,
  $manage_bat        = false,
  $manage_console    = false,
  $manage_config_dir = false,
  $manage_db_tables  = true,
  $packages          = undef,
  $plugin_dir        = undef
) {
  include ::bacula::params

  if $packages {
    $packages_notify = $manage_db_tables ? {
      true    => Exec['make_db_tables'],
      default => undef,
    }

    package { $packages:
      ensure => installed,
      notify => $packages_notify,
    }
  }

  # The user and group are actually created by installing the bacula-common
  # package which is pulled in when any other bacula package is installed.
  # To work around the issue where every package resource is a separate run of
  # yum we add requires for the packages we already have to the group resource.
  if $is_client {
    $require_package = 'bacula-client'
  } elsif $is_director {
    $require_package = $::bacula::director::db_package
  } elsif $is_storage {
    $require_package = $::bacula::storage::db_package
  } elsif $manage_console {
    $require_package = $::bacula::params::console_package
  } elsif $manage_bat {
    $require_package = $::bacula::params::bat_console_package
  }

  if $plugin_dir {
    file { $plugin_dir:
      ensure => directory,
      owner  => 'root',
      group  => 'root',
      mode   => '0755',
    }
  }

  # Specify the user and group are present before we create files.
  group { 'bacula':
    ensure  => present,
    require => Package[$require_package],
  }

  user { 'bacula':
    ensure  => present,
    gid     => 'bacula',
    require => Group['bacula'],
  }

  $config_dir_source = $manage_config_dir ? {
    true    => 'puppet:///modules/bacula/bacula-empty.dir',
    default => undef,
  }

  file { '/etc/bacula':
    ensure  => directory,
    owner   => 'bacula',
    group   => 'bacula',
    mode    => '0750',
    purge   => $manage_config_dir,
    force   => $manage_config_dir,
    recurse => $manage_config_dir,
    source  => $config_dir_source,
    require => Package[$require_package],
  }

  # This is necessary to prevent the object above from deleting the supplied scripts
  file { '/etc/bacula/scripts':
    ensure  => directory,
    owner   => 'bacula',
    group   => 'bacula',
    require => Package[$require_package],
  }

  file { '/var/lib/bacula':
    ensure  => directory,
    owner   => 'bacula',
    group   => 'bacula',
    mode    => '0755',
    require => Package[$require_package],
  }

  file { '/var/spool/bacula':
    ensure  => directory,
    owner   => 'bacula',
    group   => 'bacula',
    mode    => '0755',
    require => Package[$require_package],
  }

  file { '/var/log/bacula':
    ensure  => directory,
    recurse => true,
    owner   => 'bacula',
    group   => 'bacula',
    mode    => '0755',
    require => Package[$require_package],
  }

  file { '/var/run/bacula':
    ensure  => directory,
    owner   => 'bacula',
    group   => 'bacula',
    mode    => '0755',
    require => Package[$require_package],
  }
}
