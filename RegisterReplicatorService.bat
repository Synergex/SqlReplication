@echo off

rem An example of registering the replicator as a Windows service.
rem Refer to README.md for additional information.

dbssvc -rs -c SynergyReplicator -d "Synergy SQL Replicator Service" EXE:replicator -interval 2 -verbose -keyvalues -loaderrors -erroremail steve.ives@synergex.com -mailserver exch2016.synergex.loc -mailfrom replicator@synergex.com -maildomain synergex.com -stoponerror -database VTX12_SQLNATIVE://SqlReplicationIoHooks/.///Trusted_connection=yes