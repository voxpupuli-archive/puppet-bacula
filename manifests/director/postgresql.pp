# == Class: bacula::director::postgresql
#
# Manage postgresql resources for the Bacula director.
#
# === Parameters
#
# All <tt>bacula+ classes are called from the main <tt>::bacula</tt> class.  Parameters
# are documented there.
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
class bacula::director::postgresql (
  $db_database  = 'bacula',
  $db_host      = 'localhost',
  $db_password  = '',
  $db_port      = '5432',
  $db_user      = '',
  $db_user_host = undef,
  $manage_db    = false,
) {
  include ::bacula::params

  if $manage_db {
    if defined(Anchor['::postgresql::server::end']) {
      $db_require = Anchor['::postgresql::server::end']
    } else {
      $db_require = undef
    }

    $db_user_host_real = $db_user_host ? {
      undef   => $::fqdn,
      default => $db_user_host,
    }

    postgresql::server::role { $db_user:
      password_hash => postgresql_password($db_user, $db_password),
      require       => $db_require,
      notify        => Exec['make_db'],
    }
  }

  $make_db_command = $::operatingsystem ? {
    /(Ubuntu|Debian)/ => '/usr/lib/bacula/create_bacula_database',
    default           => '/usr/libexec/bacula/create_postgresql_database',
  }
  $make_db_tables_command = $::operatingsystem ? {
    /(Ubuntu|Debian)/ => '/usr/lib/bacula/make_bacula_tables',
    default           => '/usr/libexec/bacula/make_postgresql_tables',
  }
  $grant_privs_command = $::operatingsystem ? {
    /(Ubuntu|Debian)/ => '/usr/lib/bacula/grant_bacula_privileges',
    default           => '/usr/libexec/bacula/grant_postgresql_privileges',
  }
  $db_parameters = ''

  exec { 'make_db':
    command     => "${make_db_command} ${db_parameters}",
    user        => 'postgres',
    refreshonly => true,
    logoutput   => true,
    require     => Package[$::bacula::params::director_postgresql_package],
    before      => Service['bacula-dir'],
    notify      => Exec['make_db_tables'],
  }
  exec { 'make_db_tables':
    command     => "${make_db_tables_command} ${db_parameters}",
    user        => 'postgres',
    refreshonly => true,
    logoutput   => true,
    require     => Package[$::bacula::params::director_postgresql_package],
    before      => Service['bacula-dir'],
    notify      => Exec['grant_db_privs'],
  }
  exec { 'grant_db_privs':
    command     => "${grant_privs_command} ${db_parameters}",
    user        => 'postgres',
    refreshonly => true,
    logoutput   => true,
    require     => Package[$::bacula::params::director_postgresql_package],
    before      => Service['bacula-dir'],
  }
}
