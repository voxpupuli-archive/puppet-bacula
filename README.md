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
    filesets			  *See Adding Filesets section*


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

Fileset Parameters
------------------

    PARAMETERS   DESCRIPTION

    files        Which files to backup
    excludes     Which files to exclude from being backed up
    signature    Which signature to create to allow for varification
    compression  What compression to apply to the backup files

Schedule Parameters
-------------------

    PARAMETERS   DESCRIPTION
    run          What level to back up (Full, Differential, Incremental) and which schedule to do this on

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

  $filesets = { 'test1' => {
                'files' => ['/etc','/tmp'],
                'exclude' => ['/etc/steve','/etc/passwd','/etc/shadow'],
                'compression' => 'GZIP',
                'signature' => 'MD5',
           },
                      'test2' => {
                'files' => '/tmp/',
                'exclude' => '/var/tmp',
           }
        }

  $schedules = {
                'WeekleyCycle' => {
                 'run' => ['Level=Full 1st sun at 02:00', 'Level=Differential 2nd-5th sun at 02:00', 'Level=Incremental mon-sat at 02:00'],
           },
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
    filesets          => $filesets,
    schedules         => $schedules,
  }
```

Using Top Scope (Dashboard)
---------------------------

**TOP SCOPE HAS NOT BEEN TESTED WITH CUSTOM FILESETS OR SCHEDULES**

The bacula module will look for parameters of a certain format to build its clients listi, filesets, and schedules. For each client, make a parmaeter of this
format:
  bacula_client_client1.domain.com 
with value:
  fileset=MyFileSet,schedule=MySchedule

 For each fileset make a parameter of this format:
  bacula_fileset_name
with value
  files=[files],excludes=[excludes],signature=sig_type,compression=compression_type

 For each schedule make a parameter of this format:
  bacula_schedule_name
with value
  run=[level= schedule]

[Using Puppet Templates](http://docs.puppetlabs.com/guides/templating.html)
