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

rem Generate file data report programs
codegen -e -r -lf -s EMPLOYEE -t FileDataReport        -o "%ROOT%\SRC\REPLICATOR"

rem Generate maintenance program components
codegen -e -r -lf -s EMPLOYEE    -t tk_maint_tab       -o "%ROOT%\SRC\APPLICATION" -n SynPSG.ReplicationDemo
codegen -e -r -lf -s DEPARTMENT  -t tk_change tk_drill -o "%ROOT%\SRC\APPLICATION" -n SynPSG.ReplicationDemo


endlocal
