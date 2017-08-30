@echo off
dbr EXE:replicator -interval 2 -verbose -keyvalues -loaderrors -stoponerror -database VTX12_SQLNATIVE://SqlReplicationIoHooks/.///Trusted_connection=yes
