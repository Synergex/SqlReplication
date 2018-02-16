@echo off
pushd %~dp0
setlocal

set PATH=%PATH%;C:\Windows\Microsoft.NET\Framework\v4.0.30319

net stop FileService
if ERRORLEVEL 1 goto error_stop

installutil /u FileService\bin\Release\FileService.exe
if ERRORLEVEL 1 goto error_uninstall

rem netsh http delete urlacl url=http://+:8080/
rem if ERRORLEVEL 1 goto error_url_res

goto done

:error_exe
echo ERROR: FileService.exe not found!
goto done

:error_stop
echo ERROR: Service was not stopped!
goto done

:error_uninstall
echo ERROR: Service was not uninstalled!
goto done

rem :error_url_res
rem echo ERROR: Failed to remove HTTP URL reservation!
rem goto done

:done
endlocal
popd
pause