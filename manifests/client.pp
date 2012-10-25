# == Class: bacula::client
#
# This class manages the bacula client (bacula-fd)
#
# === Parameters
#
# All +bacula+ classes are called from the main +::bacula+ class.  Parameters
# are documented there.
#
# === Actions:
# * Enforce the client package package be installed
# * Manage the +/etc/bacula/bacula-fd.conf+ file
# * Enforce the +bacula-fd+ service to be running
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
class bacula::client(
    $director_password  = '',
    $director_server    = undef
  ) {
  include bacula::params

  $director_server_real = $director_server ? {
    undef   => $bacula::params::director_server_default,
    default => $director_server,
  }

  package { 'bacula-client':
    ensure => present,
  }

  $plugin_dir = $::operatingsystem ? {
    /(?i:RedHat|CentOS|Scientific)/ => $::architecture ? {
      x86_64  => '/usr/lib64/bacula',
      default => '/usr/lib/bacula',
    },
    default => '/usr/lib/bacula'
  }

  file { '/etc/bacula/bacula-fd.conf':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0640',
    content => template('bacula/bacula-fd.conf.erb'),
    require => [
      Package['bacula-client'],
      File['/var/lib/bacula', '/var/run/bacula'],
    ],
    notify  => Service['bacula-fd'],
  }

  service { 'bacula-fd':
    ensure  => running,
    enable  => true,
  }
}
