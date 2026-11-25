@echo off
setlocal EnableExtensions EnableDelayedExpansion
chcp 65001 >nul

for %%I in ("%~dp0..\..") do set "ROOT=%%~fI"

set "SERVERS=%ROOT%\gespeicherte_server.txt"
set "FAVORITES=%ROOT%\favoriten.txt"

if not exist "%FAVORITES%" type nul > "%FAVORITES%"


:menu
cls
echo =================================
echo          SERVER-FAVORITEN
echo =================================
echo.
echo [1] Favoriten anzeigen
echo [2] Server hinzufuegen
echo [3] Favoriten entfernen
echo [4] Favorit betreten
echo [0] Zurueck
echo.

set /p "choice=Auswahl: "

if "%choice%"=="0" exit /b
if "%choice%"=="1" goto show
if "%choice%"=="2" goto add
if "%choice%"=="3" goto remove
if "%choice%"=="4" goto join

goto menu


:show
cls
echo =================================
echo          MEINE FAVORITEN
echo =================================
echo.

set count=0

for /f "usebackq tokens=1 delims=|" %%A in ("%FAVORITES%") do (
    set /a count+=1
    echo [!count!] %%A
)

if !count! EQU 0 echo Noch keine Favoriten vorhanden.

echo.
pause
goto menu


:add
cls
echo =================================
echo       FAVORIT HINZUFUEGEN
echo =================================
echo.

if not exist "%SERVERS%" (
    echo Du hast noch keine Server gespeichert!
    pause
    goto menu
)

set count=0

for /f "usebackq tokens=1 delims=|" %%A in ("%SERVERS%") do (
    set /a count+=1
    echo [!count!] %%A
)

if !count! EQU 0 (
    echo Keine Server vorhanden!
    pause
    goto menu
)

echo.
set /p "selection=Servernummer: "

set count=0
set "selectedName="
set "selectedCode="
set "selectedURL="

for /f "usebackq tokens=1-3 delims=|" %%A in ("%SERVERS%") do (
    set /a count+=1
    if "!count!"=="!selection!" (
        set "selectedName=%%A"
        set "selectedCode=%%B"
        set "selectedURL=%%C"
    )
)

if not defined selectedCode (
    echo.
    echo Ungueltige Auswahl!
    pause
    goto menu
)

findstr /l /c:"|!selectedCode!|" "%FAVORITES%" >nul

if not errorlevel 1 (
    echo.
    echo Dieser Server ist bereits ein Favorit!
    pause
    goto menu
)

>>"%FAVORITES%" echo !selectedName!^|!selectedCode!^|!selectedURL!

echo.
echo Server wurde zu deinen Favoriten hinzugefuegt!
pause
goto menu


:remove
cls
echo =================================
echo        FAVORIT ENTFERNEN
echo =================================
echo.

set count=0

for /f "usebackq tokens=1 delims=|" %%A in ("%FAVORITES%") do (
    set /a count+=1
    echo [!count!] %%A
)

if !count! EQU 0 (
    echo Keine Favoriten vorhanden!
    pause
    goto menu
)

echo.
set /p "selection=Nummer entfernen: "

set count=0
set "found="

if exist "%FAVORITES%.tmp" del "%FAVORITES%.tmp"

for /f "usebackq tokens=1-3 delims=|" %%A in ("%FAVORITES%") do (
    set /a count+=1
    if not "!count!"=="!selection!" (
        >>"%FAVORITES%.tmp" echo %%A^|%%B^|%%C
    ) else (
        set "found=1"
    )
)

if defined found (
    move /y "%FAVORITES%.tmp" "%FAVORITES%" >nul
    echo.
    echo Favorit entfernt!
) else (
    if exist "%FAVORITES%.tmp" del "%FAVORITES%.tmp"
    echo.
    echo Ungueltige Auswahl!
)

pause
goto menu


:join
cls
echo =================================
echo          FAVORIT BETRETEN
echo =================================
echo.

set count=0

for /f "usebackq tokens=1 delims=|" %%A in ("%FAVORITES%") do (
    set /a count+=1
    echo [!count!] %%A
)

if !count! EQU 0 (
    echo Keine Favoriten vorhanden!
    pause
    goto menu
)

echo.
set /p "selection=Favorit auswaehlen: "

set count=0
set "selectedURL="

for /f "usebackq tokens=1-3 delims=|" %%A in ("%FAVORITES%") do (
    set /a count+=1
    if "!count!"=="!selection!" set "selectedURL=%%C"
)

if not defined selectedURL (
    echo.
    echo Ungueltige Auswahl!
    pause
    goto menu
)

start "" "!selectedURL!"
goto menu
