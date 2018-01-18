@echo off

rem Edit the username and password in the FTP script below, point it at a VMS
rem account with an empty default directory and the script will create the necessary
rem directory structure and then upload all required files.
rem 
rem After the script completes:
rem 
rem 1. Log in to the VMS account
rem 2. Go to the [.VMS] directory
rem 3. Execute BUILD.COM
rem 
rem This command procedure should build the entire encironment.
rem 

setlocal
pushd %~dp0

call "%SYNERGYDE32%dbl\dblvars32.bat"

rem Export a repository schema
echo Exporting repository schema...
dbs RPS:rpsutl -e REPLICATION.SCH

rem Create an FTP command script to transfer the files
echo Creating FTP script...
echo open 192.168.93.10 21 > ftp.tmp
echo replication >> ftp.tmp
echo replication >> ftp.tmp
echo ascii >> ftp.tmp
echo prompt >> ftp.tmp
echo mkdir [.EXE] >> ftp.tmp
echo mkdir [.FDL] >> ftp.tmp
echo mkdir [.OBJ] >> ftp.tmp
echo mkdir [.PROTO] >> ftp.tmp
echo mkdir [.REPLICATOR_DATA] >> ftp.tmp
echo mkdir [.REPLICATOR_LOG] >> ftp.tmp
echo mkdir [.RPS] >> ftp.tmp
echo mkdir [.SRC.LIBRARY] >> ftp.tmp
echo mkdir [.SRC.REPLICATOR] >> ftp.tmp
echo mkdir [.VMS] >> ftp.tmp
echo cd [.FDL] >> ftp.tmp
echo mput *.FDL >> ftp.tmp
echo cd [-.REPLICATOR_DATA] >> ftp.tmp
echo mput ..\DAT\*.SEQ >> ftp.tmp
echo cd [-.RPS] >> ftp.tmp
echo put REPLICATION.SCH >> ftp.tmp
echo cd [-.SRC.LIBRARY] >> ftp.tmp
echo mput ..\SRC\LIBRARY\*.dbl >> ftp.tmp
echo mput ..\SRC\LIBRARY\*.def >> ftp.tmp
echo cd [-.REPLICATOR] >> ftp.tmp
echo mput ..\SRC\REPLICATOR\*.dbl >> ftp.tmp
echo cd [-.-.VMS] >> ftp.tmp
echo mput *.COM >> ftp.tmp
echo put MAKESHARE.DBL >> ftp.tmp
echo put REPLICATOR.OPT >> ftp.tmp
echo bye >> ftp.tmp

rem Transfer the files
echo Transferring files...
ftp -s:ftp.tmp 1>nul

rem Delete the command script
echo Cleaning up...
del /q ftp.tmp
del /q REPLICATION.SCH

popd
endlocal