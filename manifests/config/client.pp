define bacula::config::client (
   $fileset  = 'Basic:noHome',
   $schedule = 'WeeklyCycle',
   $template = 'bacula/client_config.erb',
   $director_service = $bacula::config::director_service,
 ) {

 if ! is_domain_name($name) {
   fail "Name for client ${name} must be a fully qualified domain name"
 }

 $name_array = split($name, '[.]')
 $hostname   = $name_array[0]

 $bacula_director_service = $osfamily ? {
   /(RedHat|Suse)/ => 'bacula-dir',
   default  => 'bacula-director',
 }

 file { "/etc/bacula/bacula-dir.d/${name}.conf":
   ensure  => file,
   content => template($template),
   notify  => Service["$bacula_director_service"],
 }
}
