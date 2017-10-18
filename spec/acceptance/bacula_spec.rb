require 'spec_helper_acceptance'

describe 'bacula class' do
  describe 'with sample parameters' do
    it 'idempotentlies run' do
      pp = <<-EOS
        class { 'bacula':
          is_storage        => false,
          is_director       => false,
          is_client         => true,
          manage_console    => true,
          director_password => 'xxxxxxxxx',
          console_password  => 'xxxxxxxxx',
          director_server   => 'bacula.domain.com',
          mail_to           => 'bacula-admin@domain.com',
          storage_server    => 'bacula.domain.com',
          clients           => $clients,
        }
      EOS

      apply_manifest(pp, catch_failures: true)
    end
  end
end
