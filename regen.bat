@echo off
setlocal

rem Configure the CodeGen environment

set ROOT=%~dp0
set CODEGEN_TPLDIR=%ROOT%\SRC\TEMPLATES
set CODEGEN_AUTHOR=Steve Ives
set OPTS=-e -r -lf -n SynPSG.ReplicationDemo -o "%ROOT%\SRC\LIBRARY"

codegen %OPTS% -s EMPLOYEE   -t ReplicationIoHooks -define ATTACH_IO_HOOKS

codegen %OPTS% -s DEPARTMENT -t SynIO


endlocal
