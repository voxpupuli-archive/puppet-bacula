define bacula::config::storagepool (
	$pooltype = 'Backup',
        $recycle = 'yes',
        $prune = 'yes',
        $retention = '365 days',
        $maxbytes = '5G',
        $maxvolumes = '100',
        $label = '',
        $maxjobs = ''
) {
$fname = regsubst($name, ' ', '_', 'G')
 file { "/etc/bacula/bacula-dir.d/${fname}-pool.conf":
   ensure  => file,
   content => template('bacula/storagepool_config.erb'),
   notify  => Service['bacula-dir'],
 }
}
