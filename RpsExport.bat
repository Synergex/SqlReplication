@echo off
if not exist %ROOT%RPS\REPLICATION.SCH goto no_delete
echo Deleting existing repository schema...
del /q %ROOT%RPS\REPLICATION.SCH
:no_delete
echo Exporting new repository schema...
dbs RPS:rpsutl -e %ROOT%RPS\REPLICATION.SCH
if "%ERRORLEVEL%"=="1" goto export_fail
goto done
:export_fail
echo *ERROR* Schema export failed
goto done
:done