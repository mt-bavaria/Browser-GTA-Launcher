@echo off
setlocal EnableExtensions EnableDelayedExpansion
chcp 65001 >nul
title GTA Launcher
mode con: cols=55 lines=25

set "LAUNCHER_DIR=%~dp0"
set "PLUGIN_FOLDER=%LOCALAPPDATA%\GTA-Launcher"
set "PLUGIN_STATE=%PLUGIN_FOLDER%\active_plugins.txt"
set "FAVORITES=%~dp0favoriten.txt"
set "SERVERS=%~dp0gespeicherte_server.txt"

:: Dateien automatisch erstellen
if not exist "%PLUGIN_FOLDER%" mkdir "%PLUGIN_FOLDER%"
if not exist "%PLUGIN_STATE%" type nul > "%PLUGIN_STATE%"
if not exist "%FAVORITES%" type nul > "%FAVORITES%"


:menu
cls
set "MENU_ACTIONS=offline|join|server"
set /a MENU_COUNT=0

echo =========================================
echo              GTA LAUNCHER
echo =========================================
echo.

set /a MENU_COUNT+=1
echo [!MENU_COUNT!] Offline spielen

set /a MENU_COUNT+=1
echo [!MENU_COUNT!] Server beitreten

set /a MENU_COUNT+=1
echo [!MENU_COUNT!] Server mit Freunden

:: Server-Favoriten
findstr /x /i "server-favoriten" "%PLUGIN_STATE%" >nul
if not errorlevel 1 (
    if exist "%~dp0Plugins\Server-Favoriten\plugin.bat" (
        set /a MENU_COUNT+=1
        echo [!MENU_COUNT!] Server-Favoriten
        set "MENU_ACTIONS=!MENU_ACTIONS!|favorites"
    )
)

:: Server-Suche
findstr /x /i "server-suche" "%PLUGIN_STATE%" >nul
if not errorlevel 1 (
    if exist "%~dp0Plugins\Server-Suche\plugin.bat" (
        set /a MENU_COUNT+=1
        echo [!MENU_COUNT!] Server-Suche
        set "MENU_ACTIONS=!MENU_ACTIONS!|search"
    )
)

set /a MENU_COUNT+=1
echo [!MENU_COUNT!] Plugins
set "MENU_ACTIONS=!MENU_ACTIONS!|plugins"

set /a MENU_COUNT+=1
echo [!MENU_COUNT!] Beenden
set "MENU_ACTIONS=!MENU_ACTIONS!|exit"

echo.
set /p "menuChoice=Auswahl: "

set "MENU_ACTION="

for /f "tokens=%menuChoice% delims=|" %%A in ("!MENU_ACTIONS!") do (
    set "MENU_ACTION=%%A"
)

if "!MENU_ACTION!"=="offline" goto bayday
if "!MENU_ACTION!"=="join" goto ip
if "!MENU_ACTION!"=="server" goto server
if "!MENU_ACTION!"=="favorites" goto runFavorites
if "!MENU_ACTION!"=="search" goto runSearch
if "!MENU_ACTION!"=="plugins" goto plugins
if "!MENU_ACTION!"=="exit" exit

goto menu


:bayday
cls
start "" https://bayday.io
goto menu


:ip
cls
echo ================================
echo         SERVER BEITRETEN
echo ================================
echo.
set /p "serverIP=Servercode: "
start "" "https://bayday.io/online#%serverIP%"
goto menu


:server
cls
echo ================================
echo        SERVERVERWALTUNG
echo ================================
echo.
echo [1] Server speichern
echo [2] Server beitreten
echo [3] Server loeschen
echo [4] HTTPS-Link kopieren
echo [5] Zurueck
echo.
set /p "serverChoice=Auswahl: "

if "%serverChoice%"=="1" goto createServer
if "%serverChoice%"=="2" goto joinServer
if "%serverChoice%"=="3" goto deleteServer
if "%serverChoice%"=="4" goto copyServer
if "%serverChoice%"=="5" goto menu

goto server


:createServer
cls
echo ================================
echo         SERVER SPEICHERN
echo ================================
echo.

set /p "FSURL=Bayday-URL eingeben: "

set "friendsServer=%FSURL:*#=%"

if "%friendsServer%"=="%FSURL%" (
    echo.
    echo FEHLER: Kein Servercode gefunden!
    pause
    goto server
)

set "friendsURL=https://bayday.io/online#%friendsServer%"

echo.
echo Servercode: %friendsServer%
echo.

set /p "serverName=Servernamen eingeben: "

if not exist "%SERVERS%" type nul > "%SERVERS%"

>>"%SERVERS%" echo %serverName%^|%friendsServer%^|%friendsURL%

echo.
echo Server erfolgreich gespeichert!
echo.

choice /C JC /M "Jetzt beitreten (J) oder zurueck (C)?"

if errorlevel 2 goto server
if errorlevel 1 start "" "%friendsURL%"

goto server


:joinServer
cls
echo ================================
echo         SERVER BEITRETEN
echo ================================
echo.

if not exist "%SERVERS%" (
    echo Keine Server gespeichert!
    pause
    goto server
)

set count=0

for /f "usebackq tokens=1 delims=|" %%A in ("%SERVERS%") do (
    set /a count+=1
    echo [!count!] %%A
)

if !count! EQU 0 (
    echo Keine Server gespeichert!
    pause
    goto server
)

echo.
set /p "serverSelect=Servernummer: "

set count=0
set "selectedURL="

for /f "usebackq tokens=1-3 delims=|" %%A in ("%SERVERS%") do (
    set /a count+=1
    if "!count!"=="!serverSelect!" set "selectedURL=%%C"
)

if not defined selectedURL (
    echo Ungueltige Auswahl!
    pause
    goto server
)

start "" "!selectedURL!"
goto server


:copyServer
cls
echo ================================
echo         LINK KOPIEREN
echo ================================
echo.

if not exist "%SERVERS%" (
    echo Keine Server gespeichert!
    pause
    goto server
)

set count=0

for /f "usebackq tokens=1 delims=|" %%A in ("%SERVERS%") do (
    set /a count+=1
    echo [!count!] %%A
)

if !count! EQU 0 (
    echo Keine Server gespeichert!
    pause
    goto server
)

echo.
set /p "serverSelect=Servernummer: "

set count=0
set "selectedURL="

for /f "usebackq tokens=1-3 delims=|" %%A in ("%SERVERS%") do (
    set /a count+=1
    if "!count!"=="!serverSelect!" set "selectedURL=%%C"
)

if not defined selectedURL (
    echo Ungueltige Auswahl!
    pause
    goto server
)

echo(!selectedURL!| clip

echo.
echo HTTPS-Link erfolgreich kopiert!
pause
goto server


:deleteServer
cls
echo ================================
echo         SERVER LOESCHEN
echo ================================
echo.

if not exist "%SERVERS%" (
    echo Keine Server gespeichert!
    pause
    goto server
)

set count=0

for /f "usebackq tokens=1 delims=|" %%A in ("%SERVERS%") do (
    set /a count+=1
    echo [!count!] %%A
)

if !count! EQU 0 (
    echo Keine Server gespeichert!
    pause
    goto server
)

echo.
set /p "deleteSelect=Welche Nummer loeschen: "

set count=0
set "found="

if exist "%SERVERS%.tmp" del "%SERVERS%.tmp"

for /f "usebackq tokens=1-3 delims=|" %%A in ("%SERVERS%") do (
    set /a count+=1
    if not "!count!"=="!deleteSelect!" (
        >>"%SERVERS%.tmp" echo %%A^|%%B^|%%C
    ) else (
        set "found=1"
    )
)

if defined found (
    move /y "%SERVERS%.tmp" "%SERVERS%" >nul
    echo.
    echo Server geloescht!
) else (
    if exist "%SERVERS%.tmp" del "%SERVERS%.tmp"
    echo.
    echo Ungueltige Auswahl!
)

pause
goto server


:: =================================
:: PLUGIN-MENUE
:: =================================

:plugins
cls
echo ================================
echo          PLUGIN-MENUE
echo ================================
echo.
echo [1] Server-Favoriten aktivieren/deaktivieren
echo [2] Server-Suche aktivieren/deaktivieren
echo [0] Zurueck
echo.

set /p "pluginChoice=Auswahl: "

if "%pluginChoice%"=="0" goto menu
if "%pluginChoice%"=="1" set "PLUGIN_ID=server-favoriten"
if "%pluginChoice%"=="2" set "PLUGIN_ID=server-suche"

if not defined PLUGIN_ID goto plugins

if "%PLUGIN_ID%"=="server-favoriten" (
    set "PLUGIN_FILE=%~dp0Plugins\Server-Favoriten\plugin.bat"
) else (
    set "PLUGIN_FILE=%~dp0Plugins\Server-Suche\plugin.bat"
)

if not exist "!PLUGIN_FILE!" (
    echo.
    echo Plugin-Datei nicht gefunden!
    pause
    set "PLUGIN_ID="
    goto plugins
)

findstr /x /i "!PLUGIN_ID!" "%PLUGIN_STATE%" >nul

if errorlevel 1 (
    >>"%PLUGIN_STATE%" echo !PLUGIN_ID!
    echo.
    echo Plugin aktiviert!
) else (
    findstr /v /i /x "!PLUGIN_ID!" "%PLUGIN_STATE%" > "%PLUGIN_STATE%.tmp"
    move /y "%PLUGIN_STATE%.tmp" "%PLUGIN_STATE%" >nul
    echo.
    echo Plugin deaktiviert!
)

set "PLUGIN_ID="
set "PLUGIN_FILE="

pause
goto plugins


:: =================================
:: SERVER-FAVORITEN STARTEN
:: =================================

:runFavorites
call "%~dp0Plugins\Server-Favoriten\plugin.bat"
goto menu


:: =================================
:: SERVER-SUCHE STARTEN
:: =================================

:runSearch
call "%~dp0Plugins\Server-Suche\plugin.bat"
goto menu
