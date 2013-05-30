# == Class: bacula::director::sqlite
#
# Manage SQLite resources for the Bacula director
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
class bacula::director::sqlite (
  $db_database  = 'bacula'
){
  sqlite::db { $db_database:
    ensure    => present,
    location  => "/var/lib/bacula/${db_database}.db",
    owner     => 'bacula',
    group     => 'bacula',
    require   => File['/var/lib/bacula'],
    notify    => Exec['make_db_tables'],
  }

  file { '/usr/local/libexec/bacula':
    ensure  => directory,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
  }

  file { '/usr/local/libexec/bacula/make_sqlite3_tables.sh':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    content => template('bacula/make_sqlite3_tables.sh.erb'),
    require => Package[$::bacula::params::director_sqlite_package],
  }

  $make_db_tables_command = $::operatingsystem ? {
    /(Ubuntu|Debian)/ => '/usr/lib/bacula/make_bacula_tables',
    default           => '/usr/local/libexec/bacula/make_sqlite3_tables.sh',
  }

  exec { 'make_db_tables':
    command     => $make_db_tables_command,
    refreshonly => true,
    require     => File['/usr/local/libexec/bacula/make_sqlite3_tables.sh'],
    before      => Service['bacula-dir'],
  }
}
