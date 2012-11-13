define bacula::config::jobs (
	$jobtype = 'backup',
	$level = 'Incremental',
	$client = '',
	$fileset = '',
	$schedule = 'WeeklyCycle',
	$storage = '',
	$pool = '',
	$messages = 'Standard',
	$priority = '',
	$runbefore = '',
	$runafter = '',
	$clientrunbefore = '',
	$clientrunafter = ''
) {
$fname = regsubst($name, ' ', '_', 'G')
 file { "/etc/bacula/bacula-dir.d/${fname}-job.conf":
   ensure  => file,
   content => template('bacula/jobs_config.erb'),
   notify  => Service['bacula-dir'],
 }
}
