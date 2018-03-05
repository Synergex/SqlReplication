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
rem This command procedure should build the entire environment.
rem 

setlocal
pushd %~dp0

call "%SYNERGYDE32%dbl\dblvars32.bat"

rem Create an FTP command script to transfer the files
echo Creating FTP script...
echo open 192.168.93.10 21 > ftp.tmp
echo replication >> ftp.tmp
echo replication >> ftp.tmp
echo ascii >> ftp.tmp
echo prompt >> ftp.tmp
echo mkdir [.DATA] >> ftp.tmp
echo mkdir [.EXE] >> ftp.tmp
echo mkdir [.FDL] >> ftp.tmp
echo mkdir [.OBJ] >> ftp.tmp
echo mkdir [.PROTO] >> ftp.tmp
echo mkdir [.LOGS] >> ftp.tmp
echo mkdir [.REPOSITORY] >> ftp.tmp
echo mkdir [.SRC.LIBRARY] >> ftp.tmp
echo mkdir [.SRC.REPLICATOR] >> ftp.tmp
echo mkdir [.VMS] >> ftp.tmp
echo cd [.DATA] >> ftp.tmp
echo mput DAT\*.SEQ >> ftp.tmp
echo cd [-.FDL] >> ftp.tmp
echo mput VMS\*.FDL >> ftp.tmp
echo cd [-.REPOSITORY] >> ftp.tmp
echo put RPS\REPLICATION.SCH >> ftp.tmp
echo cd [-.SRC.LIBRARY] >> ftp.tmp
echo mput SRC\LIBRARY\*.dbl >> ftp.tmp
echo mput SRC\LIBRARY\*.def >> ftp.tmp
echo cd [-.REPLICATOR] >> ftp.tmp
echo mput SRC\REPLICATOR\*.dbl >> ftp.tmp
echo cd [-.-.VMS] >> ftp.tmp
echo mput VMS\*.COM >> ftp.tmp
echo put VMS\MAKESHARE.DBL >> ftp.tmp
echo put VMS\REPLICATOR.OPT >> ftp.tmp
echo bye >> ftp.tmp

rem Transfer the files
echo Transferring files...
ftp -s:ftp.tmp 1>nul

rem Delete the command script
echo Cleaning up...
del /q ftp.tmp

echo Done!
popd
endlocal