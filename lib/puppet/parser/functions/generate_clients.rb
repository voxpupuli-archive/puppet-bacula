#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
module Puppet::Parser::Functions
  newfunction(:generate_clients) do |args|
    Puppet::Parser::Functions.autoloader.loadall

    # This searches top scope for variables in the style
    # $bacula_client_mynode with values in format
    # fileset=Basic:noHome,client_schedule=Hourly
    self.to_hash.each do |variable,value|
      if variable =~ /^bacula_client_.*$/
        client = variable[14..-1]

        begin
          parameters = Hash[ value.split(',').map do |val|
            val_array = val.split('=',2)
            if val_array.size != 2
              raise Puppet::ParseError, 'Could not parse parameters given. Please check your format'
            end
            if [nil,''].include? val_array[0] or [nil,''].include? val_array[1]
              raise Puppet::ParseError, 'Could not parse parameters given. Please check your format'
            end
            val_array
          end ]
        rescue
          raise Puppet::ParseError, 'Could not parse parameters given. Please check your format'
        end

        function_create_resources('bacula::client::config', {client => parameters})
      end
    end

    begin
      function_create_resources('bacula::client::config', args[0])
    rescue => e
      raise Puppet::ParseError, e
    end
  end
end
