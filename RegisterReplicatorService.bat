@echo off

rem An example of registering the replicator as a Windows service.
rem Refer to README.md for additional information.

dbssvc -rs -c SynergyReplicator -d "Synergy SQL Replicator Service" REPLICATOR_EXE:replicator -interval 2 -verbose -keyvalues -loaderrors -stoponerror -database VTX12_SQLNATIVE://SqlReplication/.///Trusted_connection=yes
