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

rem Create an FTP command script to transfer the files
echo Creating FTP script...
echo open 192.168.93.11 21> ftp.tmp
echo replication>> ftp.tmp
echo replication>> ftp.tmp
echo ascii>> ftp.tmp
echo prompt>> ftp.tmp
echo mkdir DAT>> ftp.tmp
echo mkdir EXE>> ftp.tmp
echo mkdir XDL>> ftp.tmp
echo mkdir OBJ>> ftp.tmp
echo mkdir PROTO>> ftp.tmp
echo mkdir LOGS>> ftp.tmp
echo mkdir RPS>> ftp.tmp
echo mkdir SRC>> ftp.tmp
echo mkdir SRC/LIBRARY>> ftp.tmp
echo mkdir SRC/REPLICATOR>> ftp.tmp
echo mkdir SRC/TOOLS>> ftp.tmp
echo mkdir LINUX>> ftp.tmp
echo cd DAT>> ftp.tmp
echo mput DAT\*.SEQ>> ftp.tmp
echo cd ../XDL>> ftp.tmp
echo mput XDL\*.XDL>> ftp.tmp
echo cd ../RPS>> ftp.tmp
echo put RPS\REPLICATION.SCH>> ftp.tmp
echo cd ../SRC/LIBRARY>> ftp.tmp
echo mput SRC\LIBRARY\*.dbl>> ftp.tmp
echo mput SRC\LIBRARY\*.def>> ftp.tmp
echo cd ../REPLICATOR>> ftp.tmp
echo mput SRC\REPLICATOR\*.dbl>> ftp.tmp
echo cd ../TOOLS>> ftp.tmp
echo mput SRC\TOOLS\*.dbl>> ftp.tmp
echo cd ../../LINUX>> ftp.tmp
echo put LINUX\build>> ftp.tmp
echo put LINUX\replicator_count>> ftp.tmp
echo put LINUX\replicator_detach>> ftp.tmp
echo put LINUX\replicator_instructions>> ftp.tmp
echo put LINUX\replicator_menu>> ftp.tmp
echo put LINUX\replicator_run>> ftp.tmp
echo put LINUX\replicator_setup>> ftp.tmp
echo put LINUX\replicator_status>> ftp.tmp
echo put LINUX\replicator_stop>> ftp.tmp
echo put LINUX\setup>> ftp.tmp
echo bye>> ftp.tmp

rem Transfer the files
echo Transferring files...
ftp -s:ftp.tmp 1>nul

rem Delete the command script
echo Cleaning up...
del /q ftp.tmp

echo Done!
popd
endlocal