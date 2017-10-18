require 'spec_helper'

describe 'bacula' do
  context 'with default parameters' do
    let(:params) do
      {
        is_storage: true,
        is_director: true,
        is_client: true,
        manage_console: true,
        director_password: 'XXXXXXXXX',
        console_password: 'XXXXXXXXX',
        director_server: 'bacula.domain.com',
        mail_to: 'bacula-admin@domain.com',
        storage_server: 'bacula.domain.com'
      }
    end

    let(:facts) do
      {
        bacula_manage_console: '',
        bacula_manage_bat: '',
        bacula_is_director: '',
        bacula_is_client: '',
        bacula_is_storage: '',
        bacula_use_console: '',
        bacula_manage_db: '',
        bacula_manage_db_tables: '',
        bacula_db_backend: 'mysql',
        bacula_mail_to: '',
        bacula_director_password: '',
        bacula_console_password: '',
        bacula_director_server: '',
        bacula_storage_server: '',
        bacula_director_package: 'bacula-director',
        bacula_storage_package: 'bacula-storage',
        bacula_client_package: 'bacula-client',
        bacula_director_sqlite_package: '',
        bacula_storage_sqlite_package: '',
        bacula_director_mysql_package: '',
        bacula_storage_mysql_package: '',
        bacula_director_template: '',
        bacula_storage_template: '',
        bacula_console_template: '',
        bacula_director_db_package: '',
        bacula_console_package: '',
        bacula_storage_db_package: '',
        bacula_db_user: 'root',
        bacula_db_port: '3306',
        bacula_db_password: 'fakepw',
        bacula_db_host: 'localhost',
        bacula_db_database: 'testdb',
        bacula_packages: 'bacula-console'
      }
    end

    it { is_expected.to contain_class('bacula') }
    it { is_expected.to contain_class('bacula::common') }
    it { is_expected.to contain_class('bacula::config') }
    it { is_expected.to contain_class('bacula::config::validate') }
    it { is_expected.to contain_class('bacula::director') }
    it { is_expected.to contain_class('bacula::storage') }
    it { is_expected.to contain_class('bacula::client') }
    it { is_expected.to contain_class('bacula::console') }

    it { is_expected.to contain_exec('make_db_tables') }

    it { is_expected.to contain_file '/etc/bacula/' }
    it { is_expected.to contain_file '/etc/bacula/bacula-dir.conf' }
    it { is_expected.to contain_file '/etc/bacula/bacula-dir.d/empty.conf' }
    it { is_expected.to contain_file '/etc/bacula/bacula-dir.d' }
    it { is_expected.to contain_file '/etc/bacula/bacula-fd.conf' }
    it { is_expected.to contain_file '/etc/bacula/bacula-sd.conf' }
    it { is_expected.to contain_file '/etc/bacula/bacula-sd.d/empty.conf' }
    it { is_expected.to contain_file '/etc/bacula/bacula-sd.d' }
    it { is_expected.to contain_file '/etc/bacula/bconsole.conf' }
    it { is_expected.to contain_file '/mnt/bacula' }
    it { is_expected.to contain_file '/mnt/bacula/default' }
    it { is_expected.to contain_file '/var/lib/bacula' }
    it { is_expected.to contain_file '/var/log/bacula' }
    it { is_expected.to contain_file '/var/run/bacula' }
    it { is_expected.to contain_file '/var/spool/bacula' }

    it { is_expected.to contain_group 'bacula' }

    it { is_expected.to contain_package 'bacula-client' }
    it { is_expected.to contain_package 'bacula-console' }
    it { is_expected.to contain_package 'bacula-director-sqlite3' }
    it { is_expected.to contain_package 'bacula-sd-sqlite3' }

    it { is_expected.to contain_service 'bacula-director' }
    it { is_expected.to contain_service 'bacula-fd' }
    it { is_expected.to contain_service 'bacula-sd' }

    it { is_expected.to contain_user 'bacula' }
  end
end
