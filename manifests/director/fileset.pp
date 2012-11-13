# == Define: bacula::director::fileset
#
# Configure an additional file set to be used by the Bacula clients. See the {FileSet
# Resource}[http://www.bacula.org/5.0.x-manuals/en/main/main/Configuring_Director.html#SECTION001870000000000000000] documentation
# for information on the options.
#
# === Parameters
#
# [*exclude_files*]
#   *Required*: An array of strings consisting of one file or directory name per entry. Directory names should be specified without
#   a trailing slash with Unix path notation.
# [*include_files*]
#   *Required*: An array of strings consisting of one file or directory name per entry. Directory names should be specified without
#   a trailing slash with Unix path notation.
#
# === Examples
#
#   $servicename_include_files = [
#     '/etc/servicename',
#     '/var/lib/servicename',
#     '/var/log/servicename',
#     '/var/spool/servicename',
#   ]
#   $servicename_exclude_files = [
#     '/var/lib/servicename/tmp'
#   ]
#
#   bacula::director::fileset { 'servicename' :
#     include_files => $servicename_include_files,
#     exclude_files => $servicename_exclude_files,
#   }
#
define bacula::director::fileset (
  $exclude_files = undef,
  $include_files = undef
) {
  file { "/etc/bacula/bacula-dir.d/fileset-${name}.conf":
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0640',
    content => template('bacula/fileset.conf.erb'),
    require => File['/etc/bacula/bacula-dir.conf'],
    notify  => Service['bacula-dir'],
  }
}
