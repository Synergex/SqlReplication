@echo off
setlocal

rem Configure the CodeGen environment

set ROOT=%~dp0
set CODEGEN_TPLDIR=%ROOT%\SRC\TEMPLATES
set CODEGEN_AUTHOR=Steve Ives
set OPTS=-e -r -lf -n SynPSG.ReplicationDemo -o "%ROOT%\SRC\LIBRARY"

codegen %OPTS% -s EMPLOYEE   -t ReplicationIoHooks -define ATTACH_IO_HOOKS CLEAN_DATA

codegen %OPTS% -s DEPARTMENT -t SynIO

rem Generate file data report programs

codegen -e -r -lf -s EMPLOYEE   -t FileDataReport -o "%ROOT%\SRC\REPLICATOR"

endlocal
