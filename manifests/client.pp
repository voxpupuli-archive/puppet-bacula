# == Class: bacula::client
#
# This class manages the bacula client (bacula-fd)
#
# === Parameters
#
# All <tt>bacula+ classes are called from the main <tt>::bacula</tt> class.  Parameters
# are documented there.
#
# === Actions:
# * Enforce the client package package be installed
# * Manage the <tt>/etc/bacula/bacula-fd.conf</tt> file
# * Enforce the <tt>bacula-fd</tt> service to be running
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
class bacula::client (
  $director_password = '',
  $director_server   = undef,
  $plugin_dir        = undef,
  $tls_allowed_cn    = [],
  $tls_ca_cert       = undef,
  $tls_ca_cert_dir   = undef,
  $tls_cert          = undef,
  $tls_key           = undef,
  $tls_require       = 'yes',
  $tls_verify_peer   = 'yes',
  $use_tls           = false
) {
  include ::bacula::params

  $director_server_real = $director_server ? {
    undef   => $::bacula::params::director_server_default,
    default => $director_server,
  }

  package { 'bacula-client':
    ensure => present,
  }

  $file_requires = $plugin_dir ? {
    undef   => File['/var/lib/bacula', '/var/run/bacula'],
    default => File['/var/lib/bacula', '/var/run/bacula', $plugin_dir]
  }

  file { '/etc/bacula/bacula-fd.conf':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0640',
    content => template('bacula/bacula-fd.conf.erb'),
    require => [
      Package['bacula-client'],
      $file_requires,
    ],
    notify  => Service['bacula-fd'],
  }

  service { 'bacula-fd':
    ensure     => running,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
  }
}
