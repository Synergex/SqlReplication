@echo off
setlocal
rem
rem You must configure settings for replicator system wide, or in your synergy.ini file, like this:
rem
rem [replicator_pk]
rem EXE=C:\DEV\PUBLIC\SqlReplicationIoHooksPrimaryKey\EXE
rem DAT=C:\DEV\PUBLIC\SqlReplicationIoHooksPrimaryKey\DAT
rem REPLICATOR_INTERVAL=5
rem REPLICATOR_FULL_LOG=YES
rem REPLICATOR_LOG_KEYS=YES
rem REPLICATOR_LOG_BULK_LOAD_EXCEPTIONS=YES
rem REPLICATOR_DATABASE=VTX12_SQLNATIVE://SqlReplication/.///Trusted_connection=yes
rem REPLICATOR_LOGDIR=C:\DEV\PUBLIC\SqlReplicationIoHooksPrimaryKey
rem
rem By default the service that is created will be run under the NT AUTHORITY\SYSTEM account, so
rem you must also ensure that this account has full access to the database being used:
rem
rem - In SQL Server Management Studio, go to Security > Logins > NT AUTHORITY\SYSTEM
rem - Right-click and select Properties
rem - Go to the User Mapping page
rem - In the "Users mapped to this login" list, check the checkbox next to the database being used
rem - In the "Database role membership for" list, check the checkbox next to db_owner
rem - Click OK to save the information
rem
dbssvc -r -c SynergyReplicator -d "Synergy/DE SQL Replication Service" "%~dp0..\EXE\replicator_pk.dbr"
sc config SynergyReplicator depend= lanmanworkstation/Eventlog/SynLM/MSSQLSERVER
net start SynergyReplicator
endlocal
