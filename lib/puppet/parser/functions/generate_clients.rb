module Puppet::Parser::Functions
  newfunction(:generate_clients) do |args|
    Puppet::Parser::Functions.autoloader.loadall

    # This searches top scope for variables in the style
    # $bacula_client_mynode with values in format
    # fileset=Basic:noHome,schedule=Hourly
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

        function_create_resources('bacula::config::client', {client => parameters})
      end
    end

    begin
      function_create_resources('bacula::config::client', args[0])
    rescue => e
      raise Puppet::ParseError, e
    end
  end
end
