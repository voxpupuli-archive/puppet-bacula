# == Class: bacula::params
#
# Default values for parameters needed to configure the bacula class.
#
# === Parameters
#
# None
#
# === Examples
#
#  include bacula::params
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
class bacula::params {

  $bat_console_package = $::operatingsystem ? {
    /(Debian|Ubuntu)/ => 'bacula-console-qt',
    default           => 'bacula-console-bat',
  }
  $console_package = 'bacula-console'
  $director_mysql_package = 'bacula-director-mysql'
  $director_postgresql_package = 'bacula-director-pgsql'
  $director_server_default = "bacula.${::domain}"
  $director_service = $::operatingsystem ? {
    /(Debian|Ubuntu)/ => 'bacula-director',
    default           => 'bacula-dir',
  }
  $director_sqlite_package = 'bacula-director-sqlite'
  $mail_to_default= "root@${::fqdn}"

  $storage_package_prefix = $::operatingsystem ? {
    /(Debian|Ubuntu)/ => 'bacula-sd',
    default           => 'bacula-storage',
  }

  $storage_mysql_package = "${storage_package_prefix}-mysql"
  $storage_postgresql_package = "${storage_package_prefix}-pgsql"
  $storage_server_default = "bacula.${::domain}"
  $storage_sqlite_package = 'bacula-storage-sqlite'

}
