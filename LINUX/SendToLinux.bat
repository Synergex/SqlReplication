@echo off

rem Edit the username and password in the FTP script below, point it at a Linux
rem account with an empty default directory and the script will create the necessary
rem directory structure and then upload all required files.
rem 
rem After the script completes:
rem 
rem 1. Log in to the Linux account
rem 2. Go to the LINUX directory
rem 3. Execute the build script (. ./build)
rem 
rem This script procedure should build the entire environment.
rem 

setlocal
pushd %~dp0

call "%SYNERGYDE32%dbl\dblvars32.bat"

rem Export a repository schema
echo Exporting repository schema...
dbs RPS:rpsutl -e replication.sch

rem Create an FTP command script to transfer the files
echo Creating FTP script...
echo open 192.168.93.11 21> ftp.tmp
echo replication>> ftp.tmp
echo replication>> ftp.tmp
echo ascii>> ftp.tmp
echo prompt>> ftp.tmp
echo mkdir data>> ftp.tmp
echo mkdir exe>> ftp.tmp
echo mkdir xdl>> ftp.tmp
echo mkdir obj>> ftp.tmp
echo mkdir proto>> ftp.tmp
echo mkdir logs>> ftp.tmp
echo mkdir repository>> ftp.tmp
echo mkdir src>> ftp.tmp
echo mkdir src/library>> ftp.tmp
echo mkdir src/replicator>> ftp.tmp
echo mkdir linux>> ftp.tmp
echo cd data>> ftp.tmp
echo mput ..\DAT\*.SEQ>> ftp.tmp
echo cd ../xdl>> ftp.tmp
echo mput ..\XDL\*.XDL>> ftp.tmp
echo cd ../repository>> ftp.tmp
echo put replication.sch>> ftp.tmp
echo cd ../src/library>> ftp.tmp
echo mput ..\SRC\LIBRARY\*.dbl>> ftp.tmp
echo mput ..\SRC\LIBRARY\*.def>> ftp.tmp
echo cd ../replicator>> ftp.tmp
echo mput ..\SRC\REPLICATOR\*.dbl>> ftp.tmp
echo cd ../../linux>> ftp.tmp
echo put build>> ftp.tmp
echo put replicator_count>> ftp.tmp
echo put replicator_detach>> ftp.tmp
echo put replicator_instructions>> ftp.tmp
echo put replicator_menu>> ftp.tmp
echo put replicator_run>> ftp.tmp
echo put replicator_setup>> ftp.tmp
echo put replicator_status>> ftp.tmp
echo put replicator_stop>> ftp.tmp
echo put setup>> ftp.tmp
echo bye>> ftp.tmp

rem Transfer the files
echo Transferring files...
ftp -s:ftp.tmp 1>nul

rem Delete the command script
echo Cleaning up...
del /q ftp.tmp
del /q replication.sch

echo Done!
popd
endlocal