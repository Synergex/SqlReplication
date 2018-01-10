@echo off
setlocal
pushd "%DAT%"

echo Deleting existing files...
if exist %DAT%\REPLICATION.ISM del /q %DAT%\REPLICATION.ISM
if exist %DAT%\REPLICATION.IS1 del /q %DAT%\REPLICATION.IS1
if exist %DAT%\DEPARTMENT.ISM  del /q %DAT%\DEPARTMENT.ISM
if exist %DAT%\DEPARTMENT.IS1  del /q %DAT%\DEPARTMENT.IS1
if exist %DAT%\EMPLOYEE.ISM    del /q %DAT%\EMPLOYEE.ISM
if exist %DAT%\EMPLOYEE.IS1    del /q %DAT%\EMPLOYEE.IS1

echo Loading new files...
fconvert -it DAT:DEPARTMENT.SEQ -oi DAT:DEPARTMENT.ISM -d XDL:DEPARTMENT.XDL
fconvert -it DAT:EMPLOYEE.SEQ   -oi DAT:EMPLOYEE.ISM   -d XDL:EMPLOYEE.XDL

echo Creating new replication log...
dbs DBLDIR:bldism -k XDL:REPLICATION.XDL

popd
endlocal
