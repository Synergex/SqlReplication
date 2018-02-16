@echo off
pushd %~dp0
setlocal

set PATH=%PATH%;C:\Windows\Microsoft.NET\Framework\v4.0.30319

rem netsh http add urlacl url=http://+:8080/ user="Local Service"
rem if ERRORLEVEL 1 goto error_url_res

installutil FileService\bin\Release\FileService.exe
if ERRORLEVEL 1 goto error_install

net start FileService
if ERRORLEVEL 1 goto error_install

goto done

:error_exe
echo ERROR: FileService.exe not found!
goto done

rem :error_url_res
rem echo ERROR: Failed to reserve HTTP URL for non-administrator use!
rem goto done

:error_install
echo ERROR: Service was not installed!
goto done

:error_start
echo ERROR: Service was not started!
goto done

:done
endlocal
popd
pause