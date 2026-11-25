@echo off
cls
echo ================================
echo        SERVER-FAVORITEN
echo ================================
echo.

if not exist "%~dp0..\..\gespeicherte_server.txt" (
    echo Keine gespeicherten Server gefunden!
    pause
    goto :eof
)

for /f "usebackq tokens=1,2,3 delims=|" %%A in ("%~dp0..\..\gespeicherte_server.txt") do (
    echo Server: %%A
    echo Code: %%B
    echo Link: %%C
    echo.
)

pause
goto :eof
