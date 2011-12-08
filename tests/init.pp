class { 'bacula':
  is_storage        => true,
  is_director       => true,
  is_client         => true,
  manage_console    => true,
  director_password => 'XXXXXXXXX',
  console_password  => 'XXXXXXXXX',
  director_server   => 'bacula.domain.com',
  mail_to           => 'bacula-admin@domain.com',
  storage_server    => 'bacula.domain.com',
}
