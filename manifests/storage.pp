# == Class: bacula::storage
#
# This class manages the bacula storage daemon (bacula-sd)
#
# === Parameters
#
# All <tt>bacula+ classes are called from the main <tt>::bacula</tt> class.  Parameters
# are documented there.
#
# === Actions:
# * Enforce the DB component package package be installed
# * Manage the <tt>/etc/bacula/bacula-sd.conf</tt> file
# * Manage the <tt>${storage_default_mount}+ and <tt>${storage_default_mount}/default</tt> directories
# * Manage the <tt>/etc/bacula/bacula-sd.conf</tt> file
# * Enforce the <tt>bacula-sd</tt> service to be running
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
class bacula::storage (
  $console_password      = '',
  $db_backend            = 'sqlite',
  $director_password     = '',
  $director_server       = undef,
  $plugin_dir            = undef,
  $storage_default_mount = '/mnt/bacula',
  $storage_server        = undef,
  $storage_template      = 'bacula/bacula-sd.conf.erb',
  $tls_allowed_cn        = [],
  $tls_ca_cert           = undef,
  $tls_ca_cert_dir       = undef,
  $tls_cert              = undef,
  $tls_key               = undef,
  $tls_require           = 'yes',
  $tls_verify_peer       = 'yes',
  $use_tls               = false
) {
  include ::bacula::params

  $director_server_real = $director_server ? {
    undef   => $::bacula::params::director_server_default,
    default => $director_server,
  }
  $storage_server_real  = $storage_server ? {
    undef   => $::bacula::params::storage_server_default,
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
  $db_package           = $db_backend ? {
    'mysql'      => $::bacula::params::storage_mysql_package,
    'postgresql' => $::bacula::params::storage_postgresql_package,
    default      => $::bacula::params::storage_sqlite_package,
  }

  package { $db_package:
    ensure => present,
  }

  file { [$storage_default_mount, "${storage_default_mount}/default"]:
    ensure  => directory,
    owner   => 'bacula',
    group   => 'bacula',
    mode    => '0755',
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
    ensure => file,
    owner  => 'bacula',
    group  => 'bacula',
    mode   => '0640',
  }

  $file_requires = $plugin_dir ? {
    undef   => File[
      '/etc/bacula/bacula-sd.d/empty.conf',
      "${storage_default_mount}/default",
      '/var/lib/bacula',
      '/var/run/bacula'
    ],
    default => File[
      '/etc/bacula/bacula-sd.d/empty.conf',
      "${storage_default_mount}/default",
      '/var/lib/bacula',
      '/var/run/bacula',
      $plugin_dir
    ],
  }

  file { '/etc/bacula/bacula-sd.conf':
    ensure  => file,
    owner   => 'bacula',
    group   => 'bacula',
    mode    => '0640',
    content => template($storage_template),
    require => $file_requires,
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
