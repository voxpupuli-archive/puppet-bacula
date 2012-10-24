# bacula

Author: Carl Caum <carl@puppetlabs.com>
Copyright (c) 2011, Puppet Labs Inc.

Author: Russell Harrison <rharrison@fedoraproject.org>
Copyright (c) 2012, Russell Harrison

# About

This module manages the [Bacula](http://bacula.org) backup solution.  Through
declaration of the `bacula` class, you can configure Directors, Storage Daemons,
Clients, and consoles.

This module is a fork of the [Puppet Labs](http://puppetlabs.com/)
[Bacula](http://forge.puppetlabs.com/puppetlabs/bacula) module.

# Requirements

* Puppet >=2.6
* Puppetlabs/stdlib module.  Can be obtained
  [here](http://forge.puppetlabs.com/puppetlabs/stdlib) or with the command
  `puppet-module install puppetlabs/stdlib`

## MySQL Database Backend
* Puppetlabs/mysql module.  Can be obtained
  [here](http://forge.puppetlabs.com/puppetlabs/mysql) or with the command
  `puppet-module install puppetlabs/mysql`
* Declare the `mysql::server` class to set up a MySQL server on the Bacula
  director node and set `manage_db` to true to have the bacula module manage the
  MySQL database.

## SQLite Database backend
* Puppetlabs/sqlite module.  Can be obtained
  [here](http://forge.puppetlabs.com/puppetlabs/sqlite) or with the command
  `puppet-module install puppetlabs/sqlite`

# Installation

The module can be obtained from the
[github repository](https://github.com/rharrison10/rharrison-bacula).

1. Select `Downloads` and then `Download as tar.gz` which downloads a tar.gz
   archive.
1. Upload the tar.gz file to your Puppet Master.
1. Untar the file.  This will create a new directory called
1. `rharrison10-rharrison-bacula-${commit_hash}`.
1. Rename this directory to just `bacula` and place it in your
   [modulepath](http://docs.puppetlabs.com/learning/modules1.html#modules).

<!---
You can also use the
[puppet-module tool](https://github.com/puppetlabs/puppet-module-tool). Just
run this command from your modulepath. `puppet-module install puppetlabs/bacula`
--->

# Configuration

There is one class (`bacula`) that needs to be declared on all nodes managing
any component of Bacula. These nodes are configured using the parameters of
this class.

## Using Parameterized Classes

[Using Parameterized Classes](http://docs.puppetlabs.com/guides/parameterized_classes.html)

Declaration example:

```puppet
  class { 'bacula':
    console_password  => 'consolepassword',
    director_password => 'directorpassword',
    director_server   => 'bacula.example.com',
    is_client         => true,
    is_director       => true,
    is_storage        => true,
    mail_to           => 'bacula-admin@example.com',
    manage_console    => true,
    storage_server    => 'bacula.example.com',
  }
```

## Parameters

The following lists all the class parameters the `bacula` class accepts.

### clients

For directors, `clients` is a hash of clients.  The keys are the clients while
the values are a hash of parameters. The parameters accepted are the same as
the `bacula::client::config` define.

### console_password

The password to use for the console resource on the director

### console_template

The ERB template to use for configuring the `bconsole` instead of the one
included with the module

### db_backend

Which database back end system you want to use to store the catalog data

### director_password

The director's password

### director_server

The FQDN of the Bacula director

### director_template

The ERB template to use for configuring the director instead of the one
included with the module

### is_client

Whether the node should be a client

### is_director

Whether the node should be a director

### is_storage

Whether the node should be a storage server

### mail_to

Address to email reports to

### manage_bat

Whether the bat should be managed on the node

### manage_console

Whether the `bconsole` should be managed on the node

### manage_db

Whether to manage creation of the database specified by `db_database`. Defaults
to false. In order for this to work, you must declare the `mysql::server` class

### manage_db_tables

Whether to manage the SQL tables in the database specified by `db_backend`.
Defaults to `true`.

### storage_server

The FQDN of the storage server

### storage_template

The ERB template to use for configuring the storage daemon instead of the one
included with the module

### use_console

Whether to configure a console resource on the director

# Clients

To back up clients on your network, you need to tell the director about them.
The director is whichever node you included the `bacula` class and you specified
the parameter `is_director` to `true`.  The way to add clients is different
depending on if you're using
[exported resources](http://docs.puppetlabs.com/guides/exported_resources.html),
or a hash of client information provided to the `bacula` class's `clients`
parameter on the director node. Each will need to know the parameters of the
`bacula::client::config` defined resource.

## `bacula::client::config` Parameters

### client_schedule

The schedule for backups to be performed.

### db_backend

The database back end of the catalog storing information about the backup

### director_password

The director's password the client is connecting to.

### director_server

The FQDN of the director server the client will connect to.

### fileset

The file set used by the client for backups

### pool

The pool used by the client for backups

### storage_server

The storage server hosting the pool this client will backup to

## Using Exported Resources

Exported resources are probably the most flexible way of deploying this module
involving the least amount of admin interaction to be successful.  The drawback
is the intense overhead of
[stored configurations](http://projects.puppetlabs.com/projects/1/wiki/Using_Stored_Configuration)
on your Puppet master.

### Example

```puppet
node /web-server\d+/ {
  $director_password = 'directorpassword'
  $director_server   = "bacula-dir1.${::domain}"

  # First install and configure bacula-fd pointing to the director.
  class { 'bacula':
    director_password => $director_password,
    director_server   => $director_server,
    is_client         => true,
    storage_server    => $director_server,
  }

  # Now we declare the exported resource so that it will be available to
  # install the needed configuration on the director server
  @@bacula::client::config { $::fqdn:
    client_schedule   => 'WeeklyCycle',
    director_password => $director_password,
    director_server   => $director_server,
    fileset           => 'Basic:noHome',
    storage_server    => $director_server,
  }
}

node /bacula-dir\d+/ {
  $director_password = 'directorpassword'
  $director_server   = $::fqdn

  # Lets set up the director server.
  class { '::bacula':
    console_password  => 'consolepassword',
    director_password => $director_password,
    director_server   => $director_server,
    is_client         => false,
    is_director       => true,
    is_storage        => true,
    mail_to           => "admin@${::domain}",
    storage_server    => $director_server,
  }

  # Now lets realize all of the exported client config resources configured to
  # backup to this director server.
  Bacula::Client::Config <<| director_server == $::fqdn |>>
}
```

## Using `clients` Parameter Hash

The `bacula` class takes a `clients` parameter.  The value for `clients` must
be a hash with the keys of the hash being the FQDN of the client.  The value of
the client needs to be a hash containing the parameters for each client.

The advantage of this approach is that it can be implemented without stored
configurations which will allow for scaling your Puppet masters much further.
The disadvantage is that the `clients` hash must be maintained by hand or by
an external provider such as an ENC, heira, or some other means which
introduces maintanance overhead and / or complexity in your environment.

### Example

```puppet
node /web-server\d+/ {
  $director_password = 'directorpassword'
  $director_server   = "bacula-dir1.${::domain}"

  # First install and configure bacula-fd pointing to the director.
  class { 'bacula':
    director_password => $director_password,
    director_server   => $director_server,
    is_client         => true,
    storage_server    => $director_server,
  }

}

node /bacula-dir\d+/ {
  $director_password = 'directorpassword'
  $director_server   = $::fqdn

  # Now we setup the clients hash so the configuration files can be created
  # for the director config.
  # Note the values for the director and storage parameters will be derived
  # from the values passed to the `bacula::director` class so they only have to
  # be provided if they are different.
  $bacula_clients = {
    "web-server1.${::domain}" => {
      client_schedule => 'WeeklyCycle',
      fileset         => 'Basic:noHome',
    },
    "web-server2.${::domain}" => {
      client_schedule => 'WeeklyCycle',
      fileset         => 'Basic:noHome',
    },
  }

  # Lets set up the director server.
  class { '::bacula':
    clients           => $bacula_clients,
    console_password  => 'consolepassword',
    director_password => $director_password,
    director_server   => $director_server,
    is_client         => false,
    is_director       => true,
    is_storage        => true,
    mail_to           => "admin@${::domain}",
    storage_server    => $director_server,
  }

  # Now lets realize all of the exported client config resources configured to
  # backup to this director server.
  Bacula::Client::Config <<| director_server == $::fqdn |>>
}
```

# Included FileSets

## Basic:noHome

### Include

* /boot
* /etc
* /usr/local
* /var
* /opt
* /srv

### Exclude

* /var/cache
* /var/tmp
* /var/lib/apt
* /var/lib/dpkg
* /var/lib/puppet
* /var/lib/mysql
* /var/lib/postgresql
* /var/lib/ldap
* /var/lib/bacula

## Basic:withHome

### Include

* /home
* /boot
* /etc
* /usr/local
* /var
* /opt
* /srv

### Exclude

* /var/cache
* /var/tmp
* /var/lib/apt
* /var/lib/dpkg
* /var/lib/puppet
* /var/lib/mysql
* /var/lib/postgresql
* /var/lib/ldap
* /var/lib/bacula

# Included Schedules

## WeeklyCycle

* Full First Sun at 23:05
* Differential Second-Fifth Sun at 23:05
* Incremental Mon-Sat at 23:05

## WeeklyCycleAfterBackup

* Full Mon-Sun at 23:10

## Weekly:onFriday

* Full First Fri at 18:30
* Differential Second-Fifth Fri at 18:30
* Incremental Sat-Thu at 20:00

## Weekly:onSaturday

* Full First Sat at 15:30
* Differential Second-Fifth Sat at 15:30
* Incremental Sun-Fri at 20:00

## Weekly:onSunday

* Full First Sun at 15:30
* Differential Second-Fifth Sun at 15:30
* Incremental Mon-Sat at 20:00

## Weekly:onMonday

* Full First Mon at 18:30
* Differential Second-Fifth Mon at 18:30
* Incremental Tue-Sun at 20:00

## Weekly:onTuesday

* Full First Tue at 18:30
* Differential Second-Fifth Tue at 18:30
* Incremental Wed-Mon at 20:00

## Weekly:onWednesday

* Full First Wed at 18:30
* Differential Second-Fifth Wed at 18:30
* Incremental Thu-Tue at 20:00

## Weekly:onThursday

* Full First Thu at 18:30
* Differential Second-Fifth Thu at 18:30
* Incremental Fri-Wed at 20:00

## Hourly

* Incremental hourly at 0:30

# Templates

The Bacula module comes with templates that set default Fileset resources.  To
configure different Filesets, copy the `bacula-dir.conf.erb` file out of the
`bacula/templates` directory to another location in your manifests (can be
another module).  Make the modifications you want and set the
`director_template` parameter (listed above) to point to the path where you have
stored the custom template.

[Using Puppet Templates](http://docs.puppetlabs.com/guides/templating.html)

# TODO

* Add ability to create custom Filesets.
* Add ability to create custom schedules.
* Add ability to configure storage servers external to the director.
* Add ability to configure multiple pools on a storage server
* PostgreSQL support
* [rspec-puppet](http://rspec-puppet.com/) unit tests.


