define bacula::config::schedule (
	$run = '',
) {
 file { "/etc/bacula/bacula-dir.d/${name}-sched.conf":
   ensure  => file,
   content => template('bacula/schedule_config.erb'),
   notify  => Service['bacula-dir'],
 }
}
