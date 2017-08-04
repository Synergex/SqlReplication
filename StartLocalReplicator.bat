@echo off
dbr EXE:replicator -interval 2 -verbose -keyvalues -loaderrors -erroremail steve.ives@synergex.com -mailserver exch2016.synergex.loc -mailfrom replicator@synergex.com -maildomain synergex.com -stoponerror -database VTX12_SQLNATIVE://SqlReplicationIoHooks/.///Trusted_connection=yes

rem This should work, but currently doesn't. Roger is working on it with Trifox
rem dbr -d EXE:replicator -interval 2 -verbose -keyvalues -loaderrors -erroremail steve.ives@synergex.com -mailserver exch2016.synergex.loc -mailfrom replicator@synergex.com -maildomain synergex.com -stoponerror -database net://SqlReplicationIoHooks/.///Trusted_connection=yes@1958:LOCALHOST!VTX12_SQLNATIVE