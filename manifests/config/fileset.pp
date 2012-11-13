define bacula::config::fileset (
	$files = '',
	$exclude = '',
	$compression = '',
	$signature = ''
) {
$fname = regsubst($name, ' ', '_', 'G')
 file { "/etc/bacula/bacula-dir.d/${fname}-fset.conf":
   ensure  => file,
   content => template('bacula/fileset_config.erb'),
   notify  => Service['bacula-dir'],
 }
}
