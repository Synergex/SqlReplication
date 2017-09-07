@echo off
setlocal

rem -----------------------------------------------------------------------------------------------------
rem Local databasae connections 

rem SQL Server authentication and a DSN
rem set DBCONNECT=VTX12_SQLNATIVE:SqlReplicationUser/SqlReplicationPassword/SqlReplicationDSN

rem SQL Server authentication and a database name (no DSN)
rem set DBCONNECT=VTX12_SQLNATIVE:SqlReplicationUser/SqlReplicationPassword/SqlReplicationIoHooks/.///

rem Windows authentication and a database name (no DSN)
set DBCONNECT=VTX12_SQLNATIVE://SqlReplicationIoHooks/.///Trusted_connection=yes

rem -----------------------------------------------------------------------------------------------------
rem Remote databasae connections (via OpenNET Server)

rem SQL Server authentication and a server-side DSN
rem set DBCONNECT=net:SqlReplicationUser/SqlReplicationPassword/SqlReplicationDSN@1958:localhost!VTX12_SQLNATIVE

rem SQL Server authentication and a database name (no DSN)
rem set DBCONNECT=net:SqlReplicationUser/SqlReplicationPassword/SqlReplicationIoHooks/localhost///@1958:localhost!VTX12_SQLNATIVE

rem Windows authentication and a database name (no DSN)
rem set DBCONNECT=net://SqlReplicationIoHooks/.///Trusted_connection=yes@1958:localhost!VTX12_SQLNATIVE
rem

dbr EXE:replicator -interval 2 -verbose -keyvalues -loaderrors -stoponerror -database %DBCONNECT%

endlocal