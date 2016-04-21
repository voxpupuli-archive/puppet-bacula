require 'spec_helper'

describe 'bacula' do
  context 'with default parameters' do
    let(:params) {
      {
        is_storage: true,
        is_director: true,
        is_client: true,
        manage_console: true,
        director_password: 'XXXXXXXXX',
        console_password: 'XXXXXXXXX',
        director_server: 'bacula.domain.com',
        mail_to: 'bacula-admin@domain.com',
        storage_server: 'bacula.domain.com',
      }
    }

    let(:facts) {
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
        bacula_packages: 'bacula-console',
      }
    }
    it { should contain_class('bacula') }
    it { should contain_class('bacula::common') }
    it { should contain_class('bacula::config') }
    it { should contain_class('bacula::config::validate') }
    it { should contain_class('bacula::director') }
    it { should contain_class('bacula::storage') }
    it { should contain_class('bacula::client') }
    it { should contain_class('bacula::console') }

    it { should contain_exec('make_db_tables') }

    it { should contain_file '/etc/bacula/' }
    it { should contain_file '/etc/bacula/bacula-dir.conf' }
    it { should contain_file '/etc/bacula/bacula-dir.d/empty.conf' }
    it { should contain_file '/etc/bacula/bacula-dir.d' }
    it { should contain_file '/etc/bacula/bacula-fd.conf' }
    it { should contain_file '/etc/bacula/bacula-sd.conf' }
    it { should contain_file '/etc/bacula/bacula-sd.d/empty.conf' }
    it { should contain_file '/etc/bacula/bacula-sd.d' }
    it { should contain_file '/etc/bacula/bconsole.conf' }
    it { should contain_file '/mnt/bacula' }
    it { should contain_file '/mnt/bacula/default' }
    it { should contain_file '/var/lib/bacula' }
    it { should contain_file '/var/log/bacula' }
    it { should contain_file '/var/run/bacula' }
    it { should contain_file '/var/spool/bacula' }

    it { should contain_group 'bacula' }

    it { should contain_package 'bacula-client' }
    it { should contain_package 'bacula-console' }
    it { should contain_package 'bacula-director-sqlite3' }
    it { should contain_package 'bacula-sd-sqlite3' }

    it { should contain_service 'bacula-director' }
    it { should contain_service 'bacula-fd' }
    it { should contain_service 'bacula-sd' }

    it { should contain_user 'bacula' }
  end
end
