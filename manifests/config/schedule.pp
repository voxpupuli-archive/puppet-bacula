define bacula::config::schedule (
	$run = '',
) {
$fname = regsubst($name, ' ', '_', 'G')
 file { "/etc/bacula/bacula-dir.d/${fname}-sched.conf":
   ensure  => file,
   content => template('bacula/schedule_config.erb'),
   notify  => Service['bacula-dir'],
 }
}
