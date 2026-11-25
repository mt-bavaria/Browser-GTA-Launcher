@echo off
cls
echo ================================
echo          SERVER-SUCHE
echo ================================
echo.

if not exist "%~dp0..\..\gespeicherte_server.txt" (
    echo Keine gespeicherten Server gefunden!
    pause
    goto :eof
)

set /p "searchName=Nach welchem Server suchen: "

echo.
echo Suchergebnisse:
echo.

findstr /i /c:"%searchName%" "%~dp0..\..\gespeicherte_server.txt"

if errorlevel 1 (
    echo Keine passenden Server gefunden.
)

echo.
pause
goto :eof
