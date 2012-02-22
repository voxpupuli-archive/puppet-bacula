define bacula::config::fileset (
	$files = '',
	$exclude = '',
	$compression = '',
	$signature = ''
) {
 file { "/etc/bacula/bacula-dir.d/${name}-fset.conf":
   ensure  => file,
   content => template('bacula/fileset_config.erb'),
   notify  => Service['bacula-dir'],
 }
}
