
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

## Recent Changes

| Date | Changes |
| ---- | ------- |
| 25th September 2017 | Added support for integer fields in replicated record layouts (needs testing). |
|                     | Added an option that causes bulk load operations to report progress every 1000 rows when logging to the terminal. |
| 22nd September 2017 | Corrected a documentation error re REPLICATOR_MAX_COLS. |
| 7th September 2017  | Added an option to allow startup, shutdown and error messages to be written to the system event log. |
|                     | Changed replicator to write bulk load exception files in the same location as the log file. |
|                     | Added options to allow configuration of the SQL Connection max columns and max cursors values. |
|                     | Added more information about SQL Connection connect strings. |
| September 6th 2017  | Added several examples of valid database connect strings. |
| August 31st 2017    | Shortened the name of the generated routine that closes cursors. Used to be xxx_CLOSE_CURSORS, now it's xxx_CLOSE. |
|                     | Replicator now opens and closes its log file as necessary. If running on a terminal messages are now logged to both the terminal and the log file. The "cycle log file" option is now redundant and has been removed. |
|                     | Removed \<AUTHOR\> and \<COMPANY\> tokens from all templates and regenerated the sample code.  |

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

The code in this example is configured for the following database configuration:

* Local default instance of a recent version of SQL Server (Express is OK)
* An empty database named "SqlReplicationIoHooks"
* Windows authentication based on your current windows login allows full
  access to the database (ability to create and drop tables, etc.)

If your SQL Server database is not local, is not a default instance (i.e. it
is a "named instance"), or does not accept Windows authentication, then you will
need to change the SQL Connection "connect string" that is used to connect to
the database.

Depending on how you start the replicator program, you need will to either change
the value of the -database command line option, or change the value of the
REPLICATOR_DATABASE environment variable.

If you are running replicator from the supplied Visual Studio project you will
find that the REPLICATOR_DATABASE environment variable is set via the "common
properties" tab in the Visual Studio projects; change the value and then restart
Visual Studio.

If you are running replicator from the supplied Workbench projects you will find
that REPLICATOR_DATABASE environment variable is set in the project properties of
both the application and replicator projects.

If you are running replicator as a Windows Service using the supplied batch file
RegisterReplicatorService.bat you will finf that the -database command option is
used.

Here are a few examles of valid SQL Connection connect strings for use with SQL
Server databases.

| Database | Instance |Connect Via    | Authentication   | Connect String                                      |
| -------- | -------- |-------------- | ---------------- | --------------------------------------------------- |
| Local    | Either   | DSN name      | SQL Server login | VTX12_SQLNATIVE:uid/pwd/dsn                         |
| Local    | Default  | Database name | SQL Server login | VTX12_SQLNATIVE:uid/pwd/dbname/.///                 |
| Local    | Default  | Database name | Windows login    | VTX12_SQLNATIVE://dbname/.///Trusted_connection=yes |
| Local    | Named    | Database name | SQL Server login | VTX12_SQLNATIVE:uid/pwd/dbname/.\\\instance///                 |
| Local    | Named    | Database name | Windows login    | VTX12_SQLNATIVE://dbname/.\\\instance///Trusted_connection=yes |
| Remote   | Either   | DSN name      | SQL Server login | net:uid/pwd/dsn@port:server_ip!VTX12_SQLNATIVE |
| Remote   | Default  | Database name | SQL Server login | net:uid/pwd/dbname/server_name///@port:server_ip!VTX12_SQLNATIVE |
| Remote   | Default  | Database name | Windows login    | net://dbname/server_name///Trusted_connection=yes@port:server_ip!VTX12_SQLNATIVE |
| Remote   | Named    | Database name | SQL Server login | net:uid/pwd/dbname/server_name\\\instance///@port:server_ip!VTX12_SQLNATIVE |
| Remote   | Named    | Database name | Windows login    | net://dbname/server_name\\\instance///Trusted_connection=yes@port:server_ip!VTX12_SQLNATIVE |

A local connection should be used when the SQL Server database exists on the
same system that the replicator is running on. A remote connection should be
used when the SQL Server database is located on a different system to where
the replicator is running, and requires that the Synergy OpenNet server is
running on the database server system.

The various parts of the connect string are replaced as follows:

| Value       | Replaced With |
| ----------- | ------------- |
| uid         | Username of the SQL Server login to use. |
| pwd         | Password of the SQL Server login to use. |
| dsn         | Name of an ODBC datasource to use. |
| dbname      | Name of the SQL Server database to connect to. |
| port        | TCP/IP port number that the Synergy OpenNet server is listening on (usually 1958) on the remote database server. |
| server_name | Name of the remote SQL Server (Window server name). |
| instance    | Name of the SQL Server named instance. |
| server_ip   | The DNS name or TCP/IP address of the remote database server. |

If you are using an ODBC DSN to connect to the database then you should:

* Create the DSN wherever the database is located. For local databases the DSN
  should be defined on the local system. For remote databases the DSN should
  be created on the remote server system.
* For local databases, create the DSN to match the bit-size that you are building
  the replicator application with. If you are building replicator for x86 then
  create a 32-bit System DSN. If you are building replicator for x64 then create
  a 63-bit System DSN.
* For remote databases, create a DSN to match the bit size of the server that is
  hosting the database, and running the Synergy SQL OpenNet server. For 32-bit
  servers (rare), create a 32-bit System DSN on the server. For 64-bit servers
  (usual), create a 64-bit System DSN on the server.



You can find additional information about SQL Connection connect strings in the
SQL Connection documentation:

http://docs.synergyde.com/sql/sqlChap2Buildingconnectstrings.html

***

## Configuration Options

The replicator process can be configured either via command line parameters or
by setting environment variables. In all cases the command line parameters 
will override the equivalent environment variables.

### Command Line Parameters

| Parameter                           | Description   |
| ----------------------------------- | ------------- |
| -datadir <data_location>            | The location of the replication instruction file (REPLICATOR.ISM) |
| -database <connect_string>          | SQL connection connect string identifying the database to connect to. |
| -erroremail <email_address>         | The email address that start, error and stop messages should be sent TO. |
| -exportdir <export_location>        | The location where bulk export files will be created. |
| -instance <instance_name>           | The name of this replicator instance. |
| -interval <sleep_seconds>           | The number of seconds the replicator should sleep if it finds no instructions to process. |
| -keyvalues                          | Record the key values being used to relate ISAM records to SQL rows. |
| -loaderrors                         | Log failing records during a bulk load operation to a file. |
| -logdir <log_location>              | The location where the log file should be created. A full or relative path, or an environment variable followed by a colon. |
| -mailfrom <email_address>           | The email address that replicator messages should be sent FROM. |
| -mailserver <smtp_server>           | The DNS name or IP address of the SMTP mail server that will be used to send messages. |
| -maxcolumns <max_columns>           | The maximum number of columns in a database table. Default is 254. |
| -maxcursors <max_cursors>           | The maximum number of database cursors. Allow 4 per table. Default is 128. |
| -stoponerror                        | Cause the replicator to stop if an error is encountered. |
| -syslog                             | Log to the system log in addition to the log file. |
| -verbose                            | Enable verbose logging. |


### Environment Variables

| Environment Variable                | Description                                                                                                                 |
| ----------------------------------- | -------------                                                                                                               |
| REPLICATOR_DATA                     | The location of the replication instruction file (REPLICATOR.ISM)                                                           |
| REPLICATOR_DATABASE                 | SQL connection database connection string identifying the SQL Server database to connect to.                                |
| REPLICATOR_ERROR_EMAIL              | The email address that start, error and stop messages should be sent TO.                                                    |
| REPLICATOR_EXPORT                   | The location where buld export files will be created.                                                                       |
| REPLICATOR_INSTANCE                 | The name of this replicator instance.                                                                                       |
| REPLICATOR_INTERVAL                 | The number of seconds the replicator should sleep if it finds no instructions to process.                                   |
| REPLICATOR_LOG_KEYS                 | Set to YES to cause the key values being used to relate ISAM records to SQL rows.                                           |
| REPLICATOR_LOG_BULK_LOAD_EXCEPTIONS | Set to YES to cause failing records during a bulk load operation to be logged to a file.                                    |
| REPLICATOR_LOGDIR                   | The location where the log file should be created. A full or relative path, or an environment variable followed by a colon. |
| REPLICATOR_EMAIL_SENDER             | The email address that replicator messages should be sent FROM.                                                             |
| REPLICATOR_SMTP_SERVER              | The DNS name or IP address of the SMTP mail server that will be used to send messages.                                      |
| REPLICATOR_MAX_COLS                 | The maximum number of columns in a database table. Default is 254. |
| REPLICATOR_MAX_CURSORS              | The maximum number of database cursors. Allow 4 per table. Default is 128. |
| REPLICATOR_ERROR_STOP               | Set to YES to cause the replicator to stop if an error is encountered.                                                      |
| REPLICATOR_SYSTEM_LOG               | Set to YES to log to the system log in addition to the log file. |
| REPLICATOR_FULL_LOG                 | Set to YES to cause more verbose logging to be used.                                                                        |

***

## Running the Demo on Windows

In order to see the replication happenning use SQL Server Management Studio to
connect to the SqlReplicationIoHooks database and display the list of tables
in the database - there aren't any at the moment. Run the Synergy client
application by ensuring that application.vpj is the current project, and then
selecting "Build > Execute" from the Workbench menu.

Start the replicator process by selecting select Replicator -> Start Replicator
from the application menu. You should see some messages, including:

    SQL Replicator Log
    Replicator startup
    Processing interval is 5 seconds
    Connecting to database...
    Connected
    Maximum cursors: 128
    Maximum columns: 254
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

***

## Building and Running Replicator on Linux

Refer to the various shell script files in the LINUX directory.

***

## Building and Running Replicator on OpenVMS

Refer to the various shell script files in the VMS directory.

Basic steps to build on VMS:

1.  Log into a privileged account (privs needed to start a detached process as SYSTEM)
2.  Create an empty directory to deploy the code to.
3.  Deploy the DAT, RPS, SRC and VMS folders into the new directory.
4.  Move to the VMS folder
5.  Execute the BUILD.COM command procedure.
6.  Edit REPLICATOR_SETUP.COM and check settings. In particular you will need to
    configure REPLICATOR_DATABASE based on the SQL Server database you intend to use.
7.  Start replicator as a detached process by executing REPLICATOR_DETACH.COM
8.  Or start the replicator as an interactive process by executing REPLICATOR_RUN.COM_
8.  Check the log file in the [.LOG] folder and ensure that replicator was able to 
    connect to the database.
9.  Run EXE:REPLICATORMENU and test using the EMPLOYEE file.
10. Use the S command in REPLICATORMENU or run EXE:REPLICATORSSTOP.EXE to stop the
    replicator process.