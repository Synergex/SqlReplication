@echo off
setlocal

rem Configure the CodeGen environment

set ROOT=%~dp0
set CODEGEN_TPLDIR=%ROOT%\SRC\TEMPLATES
set CODEGEN_AUTHOR=Steve Ives

codegen -e -r -lf -s EMPLOYEE   -t ReplicationIoHooks  -o "%ROOT%\SRC\LIBRARY" -n SynPSG.ReplicationDemo -define ATTACH_IO_HOOKS CLEAN_DATA

codegen -e -r -lf -s DEPARTMENT -t SynIO               -o "%ROOT%\SRC\LIBRARY" -n SynPSG.ReplicationDemo

rem ONE TIME ONLY - Generate manually maintained routines
rem codegen -e -r -lf  -t ConfigureReplication    -o "%ROOT%\SRC\LIBRARY" -n SynPSG.ReplicationDemo
rem codegen -e -r -lf  -t PopulateReplicationKey  -o "%ROOT%\SRC\LIBRARY" -n SynPSG.ReplicationDemo

endlocal
