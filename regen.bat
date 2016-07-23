@echo off
setlocal

rem Configure the CodeGen environment

set ROOT_FOLDER=%~dp0
set CODEGEN_TPLDIR=%ROOT_FOLDER%\SRC\TEMPLATES
set CODEGEN_AUTHOR="Steve Ives"
set CODEGEN_COMPANY="Synergex Professional Services Group"
set OPTS=-e -r -lf -n SynPSG.ReplicationDemo

codegen %OPTS% -s EMPLOYEE   -t SynIO SqlIO ReplicationIoHooks IsNumeric -o "%ROOT_FOLDER%\SRC\LIBRARY" -define ATTACH_IO_HOOKS

codegen %OPTS% -s DEPARTMENT -t SynIO                                    -o "%ROOT_FOLDER%\SRC\LIBRARY"


endlocal
