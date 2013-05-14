# == Class: bacula::console::bat
#
# This class installs the BAT (Bacula Admin Tool) application for QT supported
# systems
#
# === Parameters
#
# None
#
# === Actions:
# * Enforce the BAT system package is installed
# * Enforce <tt>/etc/bacula/bat.conf</tt> points to <tt>/etc/bacula/bconsole.conf</tt>
#
# === Sample Usage:
#
#  class { '::bacula::console::bat': }
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
class bacula::console::bat {
  Class['::bacula::console'] -> Class['::bacula::console::bat']
  include ::bacula::params

  package { $::bacula::params::bat_console_package:
    ensure  => present,
  }

  file { '/etc/bacula/bat.conf':
    ensure  => 'symlink',
    target  => 'bconsole.conf',
    require => [
      Package[$::bacula::params::bat_console_package],
      File['/etc/bacula/bconsole.conf'],
    ],
  }
}
