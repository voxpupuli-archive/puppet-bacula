bacula
=============

Author: Carl Caum <carl@puppetlabs.com>
Copyright (c) 2011, Puppet Labs Inc.


ABOUT
=====

This module manages [Bacula](http://bacula.org).  Through declaration of the `bacula` class, you can configure Directors, Storage Daemons, Clients, and consoles.

INSTALLATION
============

The module can be obtained from the [Puppet Forge](http://forge.puppetlabs.com/puppetlabs/bacula).  Select `Download` which downloads a tar.gz file.  Upload the tar.gz file to your Puppet Master.  Untar the file.  This will create a new directory called `puppetlabs-bacula-${version_number}`.  Rename this directory to just **bacula** and place it in your [modulepath](http://docs.puppetlabs.com/learning/modules1.html#modules). 

You can also use the [puppet-module tool](https://github.com/puppetlabs/puppet-module-tool).  Just run this command from your modulepath.
`puppet-module install puppetlabs/bacula`

REQUIREMENTS
============

 * Puppet >=2.6 if using parameterized classes
 * Puppetlabs/stdlib module.  Can be obtained here http://forge.puppetlabs.com/puppetlabs/stdlib or with the command `puppet-module install puppetlabs/stdlib`
 * Puppetlabs/mysql module.  Can be obtained here http://forge.puppetlabs.com/puppetlabs/mysql or with the command `puppet-module install puppetlabs/mysql`
   Declare the mysql::server class to set up a mysql server on the bacula director node and set `manage_db` to true to have bacula manage the mysql database.
 * Puppetlabs/sqlite module.  Can be obtained here http://forge.puppetlabs.com/puppetlabs/sqlite or with the command `puppet-module install puppetlabs/sqlite`
   Declare the mysql::sqlite class so it's available for the bacula class to use.


CONFIGURATION
=============

There is one class (bacula) that needs to be declared on all nodes managing any component of bacula.
These nodes are configured using one of two methods.

 1. Using Top Scope (e.g. Dashboard) parameters 
 2. Declare the bacula class on node definitions in your manifest.

NOTE: The two methods can be mixed and matched, but take care not to create the same Top Scope parameter and class parameter simultaneously (See below for class parameters and their matching Top Scope parameter) as you may get unexpected results.
Order of parameter precendence:

 * Class Parameter
 * Top Scope Parameter
 * Hard Coded value

Using Top Scope (Dashboard)
---------------------------
Steps:

 1. Add the `bacula` class to the nodes or groups you want to manage any bacula component on.
 2. Add the parameters (See below) to the nodes or groups to configure the bacula class

[Grouping and Classifying Nodes](http://docs.puppetlabs.com/pe/2.0/console_classes_groups.html)


Using Parameterized Classes
---------------------------
Declaration example:

```puppet
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
```

[Using Parameterized Classes](http://docs.puppetlabs.com/guides/parameterized_classes.html)

Parameters
----------

The following lists all the class parameters the bacula class accepts as well as their Top Scope equivalent.

    BACULA CLASS PARAMETER        TOP SCOPE EQUIVALENT            DESCRIPTION
    -------------------------------------------------------------------------

    COMMON PARAMETERS:
    db_backend                    bacula_db_backend               Which database backend system you want to use to store the catalog data
    mail_to                       bacula_mail_to                  Address to email reports to
    is_director                   bacula_is_director              Whether the node should be a director
    is_client                     bacula_is_client                Whether the node should be a client
    is_storage                    bacula_is_storage               Whether the node should be a storage server
    director_password             bacula_director_password        The director's password
    console_password              bacula_console_password         The console's password
    director_server               bacula_director_server          The FQDN of the bacula director
    storage_server                bacula_storage_server           The FQDN of the storage server
    manage_console                bacula_manage_console           Whether the bconsole should be managed on the node
    manage_bat                    bacula_manage_bat               Whether the bat should be managed on the node
    clients                       *See Adding Clients section*    


    UNCOMMON PARAMETERS:
    manage_db_tables              bacula_manage_db_tables         Whether to manage the SQL tables in te database specified in db_backend. Defaults to true
    manage_db                     bacula_manage_db                Whether to manage creation of the database specified by db_database. Default to false. In order
                                                                  for this to work, you must declare the `mysql::server` class
    director_package              bacula_director_package         The name of the package to install the director
    storage_package               bacula_storage_package          The name of the package to install the storage
    client_package                bacula_client_package           The name of the package to install the client
    director_sqlite_package       bacula_director_sqlite_package  The name of the package to install the director's sqlite functionality
    storage_sqlite_package        bacula_storage_sqlite_package   The name of the package to install the storage daemon's sqlite functionality
    director_mysql_package        bacula_director_mysql_package   The name of the package to install the director's mysql functionality
    storage_mysql_package         bacula_storage_mysql_package    The name of the package to install the storage's sqlite functionality
    director_template             bacula_director_template        The ERB template to use for configuring the director instead of the one included with the module
    storage_template              bacula_storage_template         The ERB template to use for configuring the storage daemon instead of the one included with the module
    console_template              bacula_console_template         The ERB template to use for configuring the bconsole instead of the one included with the module
    use_console                   bacula_use_console              Whether to configure a console resource on the director
    console_password              bacula_console_password         The password to use for the console resource on the director

CLIENTS
=======

To back up clients on your network, you need to tell the director about them. The director is whichever node you included the 
`bacula` class and you specifed the parameter `is_director` to true.  The way to add clients is different depending on if 
you're using an ENC such as Dashboard or if you're using parameterized classes.  Both need to know the parameters of the client

Client Parameters
-----------------

    PARAMETERS   DESCRIPTION

    fileset      Which FileSet to assign to the client
    schedule     Which schedule to assign to the client

Using Parameterized Classes
---------------------------

The `bacula` class takes a `clients` parameter.  The value for `clients` must be a hash with the keys of the hash being
the FQDN of the client.  The value of the client needs to be a hash containing the parameters for the client.

```puppet
  $clients = {
    'node1.domain.com' = {
      'fileset'  => 'Basic:noHome',
      'schedule' => 'Weekly'
    }
  }

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
    clients           => $clients,
  }
```

Using Top Scope (Dashboard)
---------------------------

The bacula module will look for parameters of a certain format to build its clients list. For each client, make a parmaeter of this
format:
  bacula_client_client1.domain.com 
with value:
  fileset=MyFileSet,schedule=MySchedule


Included FileSets
=================

 * Basic:noHome:
   Include:
    * /boot
    * /etc
    * /usr/local
    * /var
    * /opt
    * /srv

   Exclude:
    * /var/cache
    * /var/tmp
    * /var/lib/apt
    * /var/lib/dpkg
    * /var/lib/puppet
    * /var/lib/mysql
    * /var/lib/postgresql
    * /var/lib/ldap
    * /var/lib/bacula

 * Basic:withHome
   Include:
    * /home
    * /boot
    * /etc
    * /usr/local
    * /var
    * /opt
    * /srv

   Exclude:
    * /var/cache
    * /var/tmp
    * /var/lib/apt
    * /var/lib/dpkg
    * /var/lib/puppet
    * /var/lib/mysql
    * /var/lib/postgresql
    * /var/lib/ldap
    * /var/lib/bacula

Included Schedules
==================

 * WeeklyCycle  
   * Full First Sun at 23:05
   * Differential Second-Fifth Sun at 23:05
   * Incremental Mon-Sat at 23:05
 
 * WeeklyCycleAfterBackup
   * Full Mon-Sun at 23:10

 * Weekly:onFriday
   * Full First Fri at 18:30
   * Differential Second-Fifth Fri at 18:30
   * Incremental Sat-Thu at 20:00

 * Weekly:onSaturday
   * Full First Sat at 15:30
   * Differential Second-Fifth Sat at 15:30
   * Incremental Sun-Fri at 20:00

 * Weekly:onSunday
   * Full First Sun at 15:30
   * Differential Second-Fifth Sun at 15:30
   * Incremental Mon-Sat at 20:00
   
 * Weekly:onMonday
   * Full First Mon at 18:30 
   * Differential Second-Fifth Mon at 18:30
   * Incremental Tue-Sun at 20:00

 * Weekly:onTuesday
   * Full First Tue at 18:30
   * Differential Second-Fifth Tue at 18:30
   * Incremental Wed-Mon at 20:00

 * Weekly:onWednesday
   * Full First Wed at 18:30
   * Differential Second-Fifth Wed at 18:30
   * Incremental Thu-Tue at 20:00

 * Weekly:onThursday
   * Full First Thu at 18:30
   * Differential Second-Fifth Thu at 18:30
   * Incremental Fri-Wed at 20:00

 * Hourly
   * Incremental hourly at 0:30

TEMPLATES
=========

The Bacula module comes with templates that set default Fileset resources.  To configure different Filesets, copy the
bacula-dir.conf.erb file out of the bacula/templates directory to another location in your manifests (can be another
module).  Make the modifications you want and set the director_template parameter (listed above) to point to the path where you have
stored the custom template.

[Using Puppet Templates](http://docs.puppetlabs.com/guides/templating.html)

TODO
====

 * Add ability to set custom Filesets for clients.

