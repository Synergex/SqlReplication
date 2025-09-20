@echo off
call "%SYNERGYDE64%dbl\dblvars64.bat"
pushd %~dp0
echo Extracting EMPLOYEE.ISM
"C:\Program Files\7-zip\7z.exe" e -y EMPLOYEE_100K.7z
echo OPTIMIZING REPLICATION_DEFAULT.ISM
isutl -ro REPLICATION_DEFAULT.ISM
pause
popd