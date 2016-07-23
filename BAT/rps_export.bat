@echo off
if not exist %ROOT%RPS\rps.sch goto no_delete
echo Deleting existing repository schema...
del /q %ROOT%RPS\rps.sch
:no_delete
echo Exporting new repository schema...
dbs RPS:rpsutl -e %ROOT%RPS\rps.sch
if "%ERRORLEVEL%"=="1" goto export_fail
goto done
:export_fail
echo *ERROR* Schema export failed
goto done
:done