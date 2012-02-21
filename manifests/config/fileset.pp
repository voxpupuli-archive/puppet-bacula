define bacula::config::fileset (
	$files = '',
	$exclude = '',
	$compression = '',
	$signature = ''
) {

 $name_array = split($name, '[.]')
 $filesetname   = $name_array[0]
 file { "/etc/bacula/bacula-dir.d/${name}-fset.conf":
   ensure  => file,
   content => template('bacula/fileset_config.erb'),
   notify  => Service['bacula-dir'],
 }
}
