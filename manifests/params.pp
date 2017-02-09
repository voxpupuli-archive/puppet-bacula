# == Class: bacula::params
#
# Default values for parameters needed to configure the <tt>bacula</tt> class.
#
# === Parameters
#
# None
#
# === Examples
#
#  include ::bacula::params
#
# === Copyright
#
# Copyright 2012 Russell Harrison
# Copyright 2017 Dart Container
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
  $bat_console_package         = $::operatingsystem ? {
    /(Debian|Ubuntu)/ => 'bacula-console-qt',
    default           => 'bacula-console-bat',
  }

  $console_package             = 'bacula-console'

  $director_mysql_package      = $::operatingsystem ? {
    /(Debian|Ubuntu)/ => 'bacula-director-mysql',
    /(CentOS|Fedora)/ => 'bacula-director',
  }

  $director_postgresql_package = $::operatingsystem ? {
    /(Debian|Ubuntu)/ => 'bacula-director-pgsql',
    /(CentOS|Fedora)/ => 'bacula-director',
    default           => 'bacula-director-postgresql',
  }

  $director_server_default     = "bacula.${::domain}"

  $director_service            = $::operatingsystem ? {
    /(Debian|Ubuntu)/ => 'bacula-director',
    default           => 'bacula-dir',
  }

  $director_sqlite_package     = 'bacula-director-sqlite'

  $lib    = $::architecture ? {
    x86_64  => 'lib64',
    default => 'lib',
  }

  $libdir = $::operatingsystem ? {
    /(Debian|Ubuntu)/ => '/usr/lib',
    default           => "/usr/${lib}",
  }

  $mail_command    = "/usr/sbin/bsmtp -h localhost -f bacula@${::fqdn} -s \\\"Bacula %t %e (for %c)\\\" %r"
  $mail_to_default = "root@${::fqdn}"

  $manage_logwatch = $::operatingsystem ? {
    /(Debian|Ubuntu)/ => false,
    /(CentOS|Fedora)/ => false,
    default           => true,
  }

  $operator_command    = "/usr/sbin/bsmtp -h localhost -f bacula@${::fqdn} -s \\\"Bacula Intervention Required (for %c)\\\" %r"
  $plugin_dir           = "${libdir}/bacula"

  $storage_mysql_package       = $::operatingsystem ? {
    /(Debian|Ubuntu)/ => 'bacula-sd-mysql',
    /(CentOS|Fedora)/ => 'bacula-storage',
    default           => 'bacula-storage-mysql',
  }

  $storage_postgresql_package  = $::operatingsystem ? {
    /(Debian|Ubuntu)/ => 'bacula-sd-pgsql',
    /(CentOS|Fedora)/ => 'bacula-storage',
    default           => 'bacula-storage-postgresql',
  }

  $storage_server_default      = "bacula.${::domain}"

  $storage_sqlite_package = $::operatingsystem ? {
    /(Debian|Ubuntu)/ => 'bacula-sd-sqlite',
    /(CentOS|Fedora)/ => 'bacula-storage',
    default           => 'bacula-storage-sqlite',
  }

}
