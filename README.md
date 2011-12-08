bacula
=============

Author: Carl Caum <carl@puppetlabs.com>
Copyright (c) 2011, Puppet Labs Inc.


ABOUT
=====

This module manages [Bacula](http://bacula.org).  Through declaration of the `bacula` class, you can configure Directors, Storage Daemons, Clients, and consoles.


REQUIREMENTS
============

 * Puppet >=2.6 if using parameterized classes
 * Puppetlabs/stdlib module.  Can be obtained here http://forge.puppetlabs.com/puppetlabs/stdlib or with the command `puppet-module install puppetlabs/stdlib`


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
    db_backend                    bacula_db_backend               Currently only supports sqlite
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


    UNCOMMON PARAMETERS:
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
 * Add support mysql backend
 * Add ability to manage the DB backend instead of just using it

