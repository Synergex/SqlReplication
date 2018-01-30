@echo off
setlocal

set DBCONNECT=VTX12_SQLNATIVE://SqlReplicationIoHooks/.///Trusted_connection=yes

dbr REPLICATOR_EXE:replicator -interval 2 -verbose -keyvalues -loaderrors -stoponerror -database %DBCONNECT%

endlocal