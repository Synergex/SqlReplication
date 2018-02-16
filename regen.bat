@echo off
setlocal

rem Configure the CodeGen environment
set ROOT=%~dp0
set CODEGEN_TPLDIR=%ROOT%\SRC\TEMPLATES
set CODEGEN_OUTDIR=%ROOT%\SRC\LIBRARY

set STRUCTURES=EMPLOYEE

rem Generate Synergy and SQL I/O routines for the structures being replicated
codegen -e -r -lf -s %STRUCTURES% -t SqlIO SynIO -define ATTACH_IO_HOOKS CLEAN_DATA

rem Templates requiring all structures to be processed at once
codegen -e -r -lf -s %STRUCTURES% -ms -t GetReplicatedTables

endlocal
