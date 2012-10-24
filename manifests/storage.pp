# == Class: bacula::storage
#
# This class manages the bacula storage daemon (bacula-sd)
#
# === Parameters
#
# All +bacula+ classes are called from the main +::bacula+ class.  Parameters
# are documented there.
#
# === Actions:
# * Enforce the DB component package package be installed
# * Manage the +/etc/bacula/bacula-sd.conf+ file
# * Manage the +/mnt/bacula+ and +/mnt/bacula/default+ directories
# * Manage the +/etc/bacula/bacula-sd.conf+ file
# * Enforce the +bacula-sd+ service to be running
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
class bacula::storage(
    $console_password   = '',
    $db_backend         = 'sqlite',
    $director_password  = '',
    $director_server    = undef,
    $storage_server     = undef,
    $storage_template   = 'bacula/bacula-sd.conf.erb'
  ) {
  include bacula::params

  $director_server_real = $director_server ? {
    undef   => $bacula::params::director_server_default,
    default => $director_server,
  }
  $storage_server_real = $storage_server ? {
    undef   => $bacula::params::storage_server_default,
    default => $storage_server,
  }

  # This is necessary because the bacula-common package will
  # install the bacula-storage-mysql package regardless of
  # wheter we're installing the bacula-storage-sqlite package
  # This causes the bacula storage daemon to use mysql no
  # matter what db backend we want to use.
  #
  # However, if we install only the db compoenent package,
  # it will install the bacula-common package without
  # necessarily installing the bacula-storage-mysql package
  $db_package = $db_backend ? {
    'mysql'       => $bacula::params::storage_mysql_package,
    'pgsql'       => $bacula::params::storage_pgsql_package,
    default       => $bacula::params::storage_sqlite_package,
  }

  package { $db_package:
    ensure => present,
  }

  file { ['/mnt/bacula', '/mnt/bacula/default']:
    ensure  => directory,
    owner   => 'bacula',
    group   => 'bacula',
    mode    => '0750',
    require => Package[$db_package],
  }

  file { '/etc/bacula/bacula-sd.d':
    ensure  => directory,
    owner   => 'bacula',
    group   => 'bacula',
    mode    => '0750',
    require => Package[$db_package],
  }

  file { '/etc/bacula/bacula-sd.d/empty.conf':
    ensure  => file,
    owner   => 'bacula',
    group   => 'bacula',
    mode    => '0640',
  }

  file { '/etc/bacula/bacula-sd.conf':
    ensure  => file,
    owner   => 'bacula',
    group   => 'bacula',
    mode    => '0640',
    content => template($storage_template),
    require => File[
      '/etc/bacula/bacula-sd.d/empty.conf',
      '/mnt/bacula/default',
      '/var/lib/bacula',
      '/var/run/bacula'
    ],
    notify  => Service['bacula-sd'],
  }

  # Register the Service so we can manage it through Puppet
  service { 'bacula-sd':
    ensure     => running,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
  }
}
