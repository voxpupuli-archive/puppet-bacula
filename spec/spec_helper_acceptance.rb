require 'beaker-rspec/spec_helper'
require 'beaker-rspec/helpers/serverspec'

hosts.each do |host|
  # Install Puppet 4 on CentOS 7
  if host['platform'] =~ %r{el-7}
    on host, 'yum install -y http://yum.puppetlabs.com/puppetlabs-release-pc1-el-7.noarch.rpm'
    on host, 'yum install -y install puppet-agent'
  else
    # Install Puppet 3.x on any other OS
    install_puppet
  end
end

RSpec.configure do |c|
  # Project root
  proj_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))

  # Readable test descriptions
  c.formatter = :documentation

  # Configure all nodes in nodeset
  c.before :suite do
    # Install module and dependencies
    puppet_module_install(source: proj_root, module_name: 'bacula')
    hosts.each do |host|
      on host, puppet('module', 'install', 'puppetlabs-stdlib'), acceptable_exit_codes: [0, 1]
    end
  end
end
