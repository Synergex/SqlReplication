@echo off
setlocal

rem Configure the CodeGen environment

set ROOT=%~dp0
set CODEGEN_TPLDIR=%ROOT%\SRC\TEMPLATES
set CODEGEN_OUTDIR=%ROOT%\SRC\LIBRARY
set SYNDEFNS=ReplicationLibrary

set STRUCTURES=EMPLOYEE

rem Templates that contain code that will usually be edited. Remove the -r option to prevent overwrite?
codegen -e -r -lf -t ConfigureReplication PopulateReplicationKey

rem OK to regenerate, not structure specific
codegen -e -r -lf -t LastRecordCache replicate -define ATTACH_IO_HOOKS CLEAN_DATA

rem OK to regenerate, structure specific
codegen -e -r -lf -s %STRUCTURES% -t SqlIO SynIO -define ATTACH_IO_HOOKS CLEAN_DATA

rem Just for the demo environment
codegen -e -r -lf -s DEPARTMENT -t SynIO

rem Templates requiring all structures at once
codegen -e -r -lf -s %STRUCTURES% -ms -t GetReplicatedTables

endlocal
