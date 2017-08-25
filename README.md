
# ISAM to SQL Replication via I/O Hooks

Author: Steve Ives, Synergex Professional Services Group (steve.ives@synergex.com)

***

This repository contains an example of how to implement the replication of a
Synergy applications ISAM data to a relational database in near-to-real-time.

The techniques demonstrated in this example are based in large part on code
that is automatically generated using CodeGen. It is therefore a requirement
that the data structures and files that are to be replicated, including key
definitions, are acurately described in a Synergy repository.

Once the bulk of the code that is required to achieve the replication of data
has been generated, the underlying application is modified by the addition of
an I/O hooks object to any channels that are opened for update to files that
are to be replicated. If your application already uses one or more subroutines
to open its data files then those subroutines will be the only places that you
need to alter, and the required change will typically be the addition of just
a few lines of code to those routines. The code in the generated I/O hooks
class detects and records changes to the ISAM files that are being replicated.

Once this change information is being recorded a single process called the
"replicator" is used to cause those changes to be mirrored to corresponding
tables in the relational database.

There are several advantages to taking this kind of approach, some of the
major ones being:

* You don't need to re-design your Synergy applications to store the actual
  application data in an SQL database. To do this properly would be a very
  major re-write of any application.

* You don't put the overhead of writing the data to both ISAM and SQL Server
  into your actual user applications, the performance overhead of which
  would be very significant.

* You don't make your user applications directly dependent on the database
  being started. If the database, or replication server are not started then
  the transactions will simply build up in the log file until such time
  as they are started.

Following the code in this examples will mean that you can implement data
replication with only minimal changes to the original Synergy applications.
This is not a project that will happen overnight. In order to be successful
with this type of project, the major requirements are:

* Each of the ISAM files that you wish to replicate to the database must
  have at least one unique key.

* In the extremely rare situation where a data file does not have any unique
  key then you will need to add a new field and unique key in order to
  replicate the data from that file to a relational database.

* You will need to add a couple of lines of code each time you OPEN for update
  the ISAM files that you wish to replicate. Typically this change takes place
  in one or more external subroutines that are already used to open channels. 

***

## Requirements

This example environment was originally developed using Synergy/DE V10.3.3
on a Windows system and should work on any higher version. The example
software should also work on UNIX, Linux and OpenVMS systems, although
some environment setup would be required. The database used during testing
was Microsoft SQL Server 2014 and the code should work with any subsequent
version of SQL Server, and probably some earlier versions also.

## Code Generation

The majority of the code the is included in this example (and indeed the
majority of the code that would be needed to implement replication in your
own environment) is produced by CodeGen.

If you wish to regenerate the included code, or use the supplied templates
to generate code for your own environment then you must have CodeGen 5.2.1
or higher installed. You can always download the latest version of CodeGen
can always be downloaded from:

https://github.com/Synergex/CodeGen/releases

***

## Setup

If you wish to actually configure and execute this demo you will need:

* A Synergy/DE development environment (V10.3.3 or higher) on Windows

* If you wish to use Visual Studio then you must have Visual Studio 2015
  or higher) and have Synergy DBL Integration for Visual Studio installed.

* A SQL Server 2014 or higher database and at least one Synergy/DE SQL
  Connection license available. If you wish to avoid editing the supplied
  example code then use a SQL Server database on the same computer that you
  intend to run the Synergy code on, and make sure that database is
  configured to accept Windows Authentication. If you do not use a local
  database then you will need change the value of the REPLICATOR_DATABASE
  environment variable that is defined in the project properties of the
  application.vpj project, or within the common properties of the Visual
  Studio environment.

* Create a new SQL Server database and make sure that the account that you
  will be using to connect to the database server has access to the new
  database. If you wish to avoid editing the supplied example code then
  name the database "SqlReplicationIoHooks". If you do not use this
  default database name then you will need to change the value of the
  REPLICATOR_DATABASE environment variable that is defined in the project
  properties of the Workbench application.vpj project, or within the common
  properties of the Visual Studio environment.

* You will find a batch file named setup.bat in the root folder. Execute
  it once to load the repository schema into a repository database and
  create various ISAM files required by the demo environment.

## Development Environment

This sample includes both Workbench and Visual Studio based development
environments. If you wish to use use Workbench, you should start by opening
the workspace file SQLReplicaitonIoHooks.vpw. If you wish to use Visual
Studio, you should start by opening the solution file SqlReplicationIoHools.sln.
Both of these environments contain several projects, as follows:

### Application Project

Contains a UI Toolkit application that includes an employee maintenance
function. The replicator program can also be started, stopped and controlled
via menu items in the sample application.

### Library Project

Contains subroutines, functions and classes that are used both by the UI
Toolkit application, and by the replicator program. Note that the main code
used to interact with ISAM files (EmployeeIO.dbl) and the relational database
(EmployeeSqlIO.dbl) are in this library. These files, and others, were
code-generated by using CodeGen.

### Replicator Project

Contains the replicator program as well as several utility programs.

***

## Building the Code in Workbench

* Start Workbench and open the workspace called SQLReplicaitonIoHooks.vpw
  via the "Project > Open Workspace..." menu option.
* Make sure you can see the "Projects" window. If it is not active then make
  it active, if it is not displayed then display it by selecting "View ->
  Toolbars" from the menu and checking the "Projects" option.
* Right-click on the library.vpj project and select "Set Active Project"
* From the main menu, select "Build > Build" to build the library project
* Right-click on the replicator.vpj project and select "Set Active Project"
* From the main menu select "Build > Build" to build the replicator program.
* Right-click on the application.vpj project and select "Set Active Project"
* From the main menu select "Build > Build" to build the main application
* Right-click on the application.vpj project and select "Compile Scripts Setup..."
* Change the "Window Library" file spec so that the path to the EXE\tkapp.ism
  file is correct for your system, then click the OK button.
* Right-click on the application.vpj project and select "Compile Scripts" to
  compile the UI Toolkit window library (creates EXE\tkapp.ism)

## Building the Code in Visual Studio

* Start Visual Studio and open the solution called SQLReplicaitonIoHooks.sln. 
* From the Build menu, select "Rebuild Solution".

## Preparing the Database

The code in this example is configured for use with a local default instance
of a recent version of Microsoft SQL Server (Express edition is OK) that is
configured to accept Windows authentication. The only database preparation
that is necessary is to create an empty database named "SqlReplicationIoHooks".

If your SQL Server database is not local, is is a "named instance", or does
not accept Windows authentication, you will need to change the SQL Connection
"connect string" that is used to identify and authenticate against the database.
To do this, depending on how you are starting the replicator program, you need
to either change the value of the REPLICATOR_DATABASE environment variable, or
the value of the -database command line option. If you are running replicator
from the supplied Visual Studio project you will find that REPLICATOR_DATABASE
se set in "common properties" in the Visual Studio projects; change the value
and then restart Visual Studio. If you are running replicator from the supplied
Workbench projects you will fins that REPLICATOR_DATABASE is set in the project
properties of both the application and replicator projects. If you are running
replicator as a Windows Service using the included RegisterReplicatorService
batch file you will fins that the -database command option is used.

You can find information about connect strings in the SQL Connection manual:

http://docs.synergyde.com/sql/sqlChap2Buildingconnectstrings.html

***

## Configuration Options

The replicator process can be configured either via command line parameters or
by setting environment variables. In all cases the command line parameters 
will override the equivalent environment variables.

### Command Line Parameters

| Parameter                           | Description   |
| ----------------------------------- | ------------- |
| -database <connect_string>          | SQL connection connect string identifying the database to connect to. |
| -logdir <directory>                 | The location where the log file should be created. A full or relative path, or an environment variable followed by a colon. |
| -interval <seconds>                 | The number of seconds the replicator should sleep if it finds no instructions to process. |
| -verbose                            | Enable verbose logging. |
| -keyvalues                          | Record the key values being used to relate ISAM records to SQL rows. |
| -loaderrors                         | Log failing records during a bulk load operation to a file. |
| -exportdir <directory>              | The location where bulk export files will be created. |
| -erroremail <email_address>         | The email address that start, error and stop messages should be sent TO. |
| -mailfrom <email_address>           | The email address that replicator messages should be sent FROM. |
| -maildomain <domain_name>           | The domain associated with the sender email address (e.g. synergex.com).|
| -stoponerror                        | Set to YES to cause the replicator to stop if an error is encountered. |
| -mailserver <smtp_server>           | The DNS name or IP address of the SMTP mail server that will be used to send messages. |
| -instance <name>                    | The name of this replicator instance. |

### Environment Variables

| Environment Variable                | Description                                                                                                                 |
| ----------------------------------- | -------------                                                                                                               |
| REPLICATOR_DATABASE                 | SQL connection database connection string identifying the SQL Server database to connect to.                                |
| REPLICATOR_LOGDIR                   | The location where the log file should be created. A full or relative path, or an environment variable followed by a colon. |
| REPLICATOR_INTERVAL                 | The number of seconds the replicator should sleep if it finds no instructions to process.                                   |
| REPLICATOR_FULL_LOG                 | Set to YES to cause more verbose logging to be used.                                                                        |
| REPLICATOR_LOG_KEYS                 | Set to YES to cause the key values being used to relate ISAM records to SQL rows.                                           |
| REPLICATOR_LOG_BULK_LOAD_EXCEPTIONS | Set to YES to cause failing records during a bulk load operation to be logged to a file.                                    |
| REPLICATOR_EXPORT                   | The location where buld export files will be created.                                                                       |
| REPLICATOR_ERROR_EMAIL              | The email address that start, error and stop messages should be sent TO.                                                    |
| REPLICATOR_EMAIL_SENDER             | The email address that replicator messages should be sent FROM.                                                             |
| REPLICATOR_EMAIL_DOMAIN             | The domain associated with the sender email address (e.g. synergex.com).                                                    |
| REPLICATOR_ERROR_STOP               | Set to YES to cause the replicator to stop if an error is encountered.                                                      |
| REPLICATOR_SMTP_SERVER              | The DNS name or IP address of the SMTP mail server that will be used to send messages.                                      |
| REPLICATOR_INSTANCE                 | The name of this replicator instance.                                                                                       |

***

## Running the Demo

In order to see the replication happenning use SQL Server Management Studio to
connect to the SqlReplicationIoHooks database and display the list of tables
in the database - there aren't any at the moment. Run the Synergy client
application by ensuring that application.vpj is the current project, and then
selecting "Build > Execute" from the Workbench menu.

Start the replicator process by selecting select Replicator -> Start Replicator
from the application menu. You should see some messages, including:

    SQL Replicator Log
    Sleep interval is 2 seconds
    --- Processing instructions ------------------

Next pick Applications -> Employee Maintenance, then cick on the search button
to show a list of all of the employees in the ISAM file. Double click an
employee to edit it, then change something and click OK.

This will record an update operation in the replication servers transaction
log. Within a few seconds it should pick up the entry, realize there is an
update to the database, and try to replicate the change. The first time this
happens it will realize that the EMPLOYEE table doesn't exist in the database
as yet, so it should create the table, and then initiate a full load of the
table from the ISAM file.

Check Management studio, is the table and data there yet? If not then you
probably got error messages from the replicator and need to debug the
environment.

From now on, as you create, amend and delete employee records, those changes
should be replicated to the EMPLOYEE table in SQL server. The example
replicator goes to sleep for five seconds if there is nothing to do, so you
should see any changes within that time frame. If you are sitting looking at
the table in Management studio however, the table is not automatically
refreshed, you you'll have to refresh it manually each time you want to see
a change.

The replicator process would generally be run as a Windows service or detached
process, and can be controlled by putting instructions into it's ISAM file.
There are various options on the Replicator menu to do this. For example,
to stop the replicator, select Replicator -> Stop Replicator.

***

## Running Replicator as a Windows Service

The replicator can be registered and started as a Windows Service, via the
dbssvc.exe service runtime. An example of doing so can be round in the batch
file RegisterReplicatorService.bat, and an example of un-registering the
service can be found in UnregisterReplicatorService.bat.

Once registered the service may be stopped and started via the Windows
Services application or via shell conmmands, e.g.:

    net start SynergyReplicator
    net stop SynergyReplicator

The connect string used in the example command assumes a SQL server database
named SqlReplicationIoHooks running on the local system, and Windows
Authentication is used to authenticate the user. The service that is registered
by dbssvc will run under the context of the Local System account, so you must
authorize that account to access the SQL Server database. To do this, use
SQL Server Enterprise Manager:

* Go to Secutiry / Logins
* Right-click NT AUTHORITY\SYSTEM and select Properties
* Go to "User Mapping" and check the Map checkbox next to your database, and
  then check the "db_owner" role.
* Click OK to save the change

You must also ensure that the EXE logical name is specified in a way that it
is available to the replicator when it runs under the contect of the Local
System account. There are a copuple of ways of doing that:

* Use the Windows System Properties dialog to set EXE as an actual system
  wide environment variable.
* Set the value in the [replicator] section of your synergy.ini file like this:

    [replicator] 

	EXE=C:\path\to\replicator\exe

#### IMPORTANT Note

Due to a bug (related to the maximum length of a windows command line) in the
10.3.3c and earlier versions of the dbssvc.exe runtime, if you wish to register
replicator as a windows service in conjunction with useing the command-line
configuration options, you must be running Synergy 10.3.3c with the HotFix
dated July 31st 2017 or later, or with a later version of Synergy/DE. You
can obtain the required hotfix from Synergex Support. As an alternative,
use the environment variables method of configuring the service (in
synergy.ini as shown above).

