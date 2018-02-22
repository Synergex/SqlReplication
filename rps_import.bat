@echo off
rem Make sure we have a schema
echo Locating schema file...
if not exist %ROOT%RPS\rps.sch goto no_schema
rem Test to see if the schema will load
echo Testing schema load...
dbs RPS:rpsutl -i %ROOT%RPS\rps.sch -ia -ir -s -n %ROOT%RPS\rpsmain.new %ROOT%RPS\rpstext.new
if "%ERRORLEVEL%"=="1" goto parse_fail
if exist %ROOT%RPS\rpsmain.new del /q %ROOT%RPS\rpsmain.new
if exist %ROOT%RPS\rpsmain.ne1 del /q %ROOT%RPS\rpsmain.ne1
if exist %ROOT%RPS\rpstext.new del /q %ROOT%RPS\rpstext.new
if exist %ROOT%RPS\rpstext.ne1 del /q %ROOT%RPS\rpstext.ne1
echo Test OK
rem Load the schema
echo Performing schema load...
dbs RPS:rpsutl -i %ROOT%RPS\rps.sch -ia -ir
if "%ERRORLEVEL%"=="1" goto load_fail
echo Schema loaded OK
goto done
:no_schema
echo *ERROR* Schema file not found!
goto done
:parse_fail
echo *ERROR* Schema parse failed - repository not changed
goto done
:load_fail
echo *ERROR* Schema load failed - repository not changed
:done
