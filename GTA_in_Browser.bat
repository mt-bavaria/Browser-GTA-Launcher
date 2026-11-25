@echo off
setlocal EnableExtensions EnableDelayedExpansion
chcp 65001 >nul
title GTA Launcher
mode con: cols=55 lines=25

set "LAUNCHER_DIR=%~dp0"
set "PLUGIN_STATE=%~dp0active_plugins.txt"
set "FAVORITES=%~dp0favoriten.txt"
set "SERVERS=%~dp0gespeicherte_server.txt"

:: Dateien automatisch erstellen
if not exist "%PLUGIN_STATE%" type nul > "%PLUGIN_STATE%"
if not exist "%FAVORITES%" type nul > "%FAVORITES%"
if not exist "%SERVERS%" type nul > "%SERVERS%"


:: =================================
:: HAUPTMENUE
:: =================================

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
    set /a MENU_COUNT+=1
    echo [!MENU_COUNT!] Server-Favoriten
    set "MENU_ACTIONS=!MENU_ACTIONS!|favorites"
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
if "!MENU_ACTION!"=="favorites" goto favorites
if "!MENU_ACTION!"=="plugins" goto plugins
if "!MENU_ACTION!"=="exit" exit

goto menu


:: =================================
:: BAYDAY
:: =================================

:bayday
start "" https://bayday.io
goto menu


:: =================================
:: SERVER BEITRETEN
:: =================================

:ip
cls
echo ================================
echo         SERVER BEITRETEN
echo ================================
echo.
set /p "serverIP=Servercode: "
start "" "https://bayday.io/online#%serverIP%"
goto menu


:: =================================
:: SERVERVERWALTUNG
:: =================================

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

findstr /x /i "server-favoriten" "%PLUGIN_STATE%" >nul

if errorlevel 1 (
    echo [1] Server-Favoriten aktivieren
) else (
    echo [1] Server-Favoriten deaktivieren
)

echo [0] Zurueck
echo.

set /p "pluginChoice=Auswahl: "

if "%pluginChoice%"=="0" goto menu
if not "%pluginChoice%"=="1" goto plugins

findstr /x /i "server-favoriten" "%PLUGIN_STATE%" >nul

if errorlevel 1 (
    >>"%PLUGIN_STATE%" echo server-favoriten
    echo.
    echo Server-Favoriten aktiviert!
) else (
    findstr /v /i /x "server-favoriten" "%PLUGIN_STATE%" > "%PLUGIN_STATE%.tmp"
    move /y "%PLUGIN_STATE%.tmp" "%PLUGIN_STATE%" >nul
    echo.
    echo Server-Favoriten deaktiviert!
)

pause
goto plugins


:: =================================
:: SERVER-FAVORITEN
:: =================================

:favorites
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

if "%choice%"=="0" goto menu
if "%choice%"=="1" goto showFavorites
if "%choice%"=="2" goto addFavorite
if "%choice%"=="3" goto removeFavorite
if "%choice%"=="4" goto joinFavorite

goto favorites


:: =================================
:: FAVORITEN ANZEIGEN
:: =================================

:showFavorites
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
goto favorites


:: =================================
:: FAVORIT HINZUFUEGEN
:: =================================

:addFavorite
cls
echo =================================
echo       FAVORIT HINZUFUEGEN
echo =================================
echo.

set count=0

for /f "usebackq tokens=1 delims=|" %%A in ("%SERVERS%") do (
    set /a count+=1
    echo [!count!] %%A
)

if !count! EQU 0 (
    echo Du hast noch keine Server gespeichert!
    pause
    goto favorites
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
    echo Ungueltige Auswahl!
    pause
    goto favorites
)

findstr /l /c:"|!selectedCode!|" "%FAVORITES%" >nul

if not errorlevel 1 (
    echo.
    echo Dieser Server ist bereits ein Favorit!
    pause
    goto favorites
)

>>"%FAVORITES%" echo !selectedName!^|!selectedCode!^|!selectedURL!

echo.
echo Server wurde zu deinen Favoriten hinzugefuegt!
pause
goto favorites


:: =================================
:: FAVORIT ENTFERNEN
:: =================================

:removeFavorite
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
    goto favorites
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
goto favorites


:: =================================
:: FAVORIT BETRETEN
:: =================================

:joinFavorite
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
    goto favorites
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
    echo Ungueltige Auswahl!
    pause
    goto favorites
)

start "" "!selectedURL!"
goto favorites
