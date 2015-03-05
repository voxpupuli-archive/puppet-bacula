require 'spec_helper'

describe 'bacula' do

  context 'with standard parameters' do
    let(:params) {
      {
        :is_storage        => true,
        :is_director       => true,
        :is_client         => true,
        :manage_console    => true,
        :director_password => 'XXXXXXXXX',
        :console_password  => 'XXXXXXXXX',
        :director_server   => 'bacula.domain.com',
        :mail_to           => 'bacula-admin@domain.com',
        :storage_server    => 'bacula.domain.com',
      }
    }
    it { should contain_class('bacula::common') }
    it { should contain_class('bacula::config::validate') }
    it { should contain_class('bacula::director') }
    it { should contain_class('bacula::storage') }
    it { should contain_class('bacula::client') }
    it { should contain_class('bacula::console') }
  end

end
