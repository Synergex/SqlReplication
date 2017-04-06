@echo off

rem This batch file can be used to configure the environment after an initial
rem download of the environment. It will load the repository from the schema
rem file, and load the ISAM files ready for use.

if exist "%SYNERGYDE64%dbl\dblvars64.bat" (
  call "%SYNERGYDE64%dbl\dblvars64.bat"
  echo Using 64-bit Synergy
) else (
  if exist "%SYNERGYDE32%dbl\dblvars32.bat" (
    call "%SYNERGYDE32%dbl\dblvars32.bat"
    echo Using 32-bit Synergy
  ) else (
    echo "Synergy/DE not found!"
    exit /b
  )
)

set ROOT=%~dp0
set INC=%ROOT%SRC\LIBRARY
set OBJ=%ROOT%OBJ
set EXE=%ROOT%EXE
set DAT=%ROOT%DAT
set BAT=%ROOT%BAT
set XDL=%ROOT%XDL
set RPSMFIL=%ROOT%RPS\rpsmain.ism
set RPSTFIL=%ROOT%RPS\rpstext.ism
set SYNEXPDIR=%ROOT%PROTO
set SYNIMPDIR=%ROOT%PROTO
set REPLICATOR_DATABASE=VTX12_SQLNATIVE://SqlReplicationUniqueKey/.///Trusted_connection=yes
set REPLICATOR_LOGDIR=%ROOT%
set REPLICATOR_INTERVAL=2
set REPLICATOR_FULL_LOG=YES
set REPLICATOR_LOG_KEYS=YES
set REPLICATOR_LOG_BULK_LOAD_EXCEPTIONS=YES
set REPLICATOR_EXPORT=%ROOT%
set REPLICATOR_EMAIL_SENDER=replicator@synergex.com
set REPLICATOR_EMAIL_DOMAIN=synergex.com
set REPLICATOR_ERROR_EMAIL=steve.ives@synergex.com
set REPLICATOR_ERROR_STOP=YES
set REPLICATOR_SMTP_SERVER=

rem If no repository load it from the schema
if not exist "%RPSMFIL%" (
  call "%BAT%\rps_import.bat"
)

rem if no data files, create and load them
if not exist "%DAT%\employee.ism" (
  call "%BAT%\load_data.bat"
)
