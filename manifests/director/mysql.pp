# == Class: bacula::director::mysql
#
# Manage MySQL resources for the Bacula director.
#
# === Parameters
#
# All <tt>bacula+ classes are called from the main <tt>::bacula</tt> class.  Parameters
# are documented there.
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
class bacula::director::mysql (
  $db_database  = 'bacula',
  $db_host      = 'localhost',
  $db_password  = '',
  $db_port      = '3306',
  $db_user      = '',
  $db_user_host = undef,
  $manage_db    = false
){
  include bacula::params

  if $manage_db {
    if defined(Class['mysql::server']) {
      if defined(Class['mysql::config']) {
        $db_require = [
          Class['mysql::server'],
          Class['mysql::config'],
        ]
      } else {
        $db_require = Class['mysql::server']
      }
    } else {
      $db_require = undef
    }

    $db_user_host_real = $db_user_host ? {
      undef   => $::fqdn,
      default => $db_user_host,
    }

    mysql::db { $db_database:
      user      => $db_user,
      password  => $db_password,
      host      => $db_user_host,
      grant     => ['all'],
      require   => $db_require,
      notify    => Exec['make_db_tables'],
    }
  }

  $make_db_tables_command = $::operatingsystem ? {
    /(Ubuntu|Debian)/ => '/usr/lib/bacula/make_bacula_tables',
    default           => '/usr/libexec/bacula/make_mysql_tables',
  }
  $db_parameters = "--host=${db_host} --user=${db_user} --password=${db_password} --port=${db_port} --database=${db_database}"

  exec { 'make_db_tables':
    command     => "${make_db_tables_command} ${db_parameters}",
    refreshonly => true,
    logoutput   => true,
    require     => Package[$bacula::params::director_mysql_package],
    notify      => Service['bacula-dir'],
  }
}
