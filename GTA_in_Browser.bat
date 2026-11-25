@echo off
setlocal EnableExtensions EnableDelayedExpansion
chcp 65001 >nul
title GTA Launcher
mode con: cols=55 lines=22

:menu
cls

powershell -NoProfile -Command ^
"$options = @('Offline spielen','Server beitreten','Server mit Freunden','Plugins','Beenden'); $selected = 0; while ($true) { Clear-Host; Write-Host '========== HAUPTMENUE =========='; Write-Host ''; for ($i=0; $i -lt $options.Count; $i++) { if ($i -eq $selected) { Write-Host ('  ^> ' + $options[$i]) -ForegroundColor Green } else { Write-Host ('    ' + $options[$i]) } }; $key = [Console]::ReadKey($true); if ($key.Key -eq 'UpArrow') { $selected = ($selected - 1 + $options.Count) %% $options.Count } elseif ($key.Key -eq 'DownArrow') { $selected = ($selected + 1) %% $options.Count } elseif ($key.Key -eq 'Enter') { exit ($selected + 1) } }"

if errorlevel 5 exit
if errorlevel 4 goto plugins
if errorlevel 3 goto server
if errorlevel 2 goto ip
if errorlevel 1 goto bayday


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

if not exist "%~dp0gespeicherte_server.txt" (
    type nul > "%~dp0gespeicherte_server.txt"
)

>>"%~dp0gespeicherte_server.txt" echo %serverName%^|%friendsServer%^|%friendsURL%

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

if not exist "%~dp0gespeicherte_server.txt" (
    echo Keine Server gespeichert!
    pause
    goto server
)

set count=0

for /f "usebackq tokens=1 delims=|" %%A in ("%~dp0gespeicherte_server.txt") do (
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

for /f "usebackq tokens=1-3 delims=|" %%A in ("%~dp0gespeicherte_server.txt") do (
    set /a count+=1
    if "!count!"=="!serverSelect!" set "selectedURL=%%C"
)

if not defined selectedURL (
    echo.
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

if not exist "%~dp0gespeicherte_server.txt" (
    echo Keine Server gespeichert!
    pause
    goto server
)

set count=0

for /f "usebackq tokens=1 delims=|" %%A in ("%~dp0gespeicherte_server.txt") do (
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

for /f "usebackq tokens=1-3 delims=|" %%A in ("%~dp0gespeicherte_server.txt") do (
    set /a count+=1
    if "!count!"=="!serverSelect!" set "selectedURL=%%C"
)

if not defined selectedURL (
    echo.
    echo Ungueltige Auswahl!
    pause
    goto server
)

echo(!selectedURL!| clip

echo.
echo HTTPS-Link erfolgreich kopiert!
echo.
pause
goto server


:deleteServer
cls
echo ================================
echo         SERVER LOESCHEN
echo ================================
echo.

if not exist "%~dp0gespeicherte_server.txt" (
    echo Keine Server gespeichert!
    pause
    goto server
)

set count=0

for /f "usebackq tokens=1 delims=|" %%A in ("%~dp0gespeicherte_server.txt") do (
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

powershell -NoProfile -Command ^
"$p=Join-Path '%~dp0' 'gespeicherte_server.txt'; $l=[System.Collections.Generic.List[string]]::new(); $l.AddRange([string[]](Get-Content -LiteralPath $p)); $n=0; if([int]::TryParse('%deleteSelect%',[ref]$n) -and $n -ge 1 -and $n -le $l.Count) { $l.RemoveAt($n-1); Set-Content -LiteralPath $p -Value $l -Encoding UTF8; Write-Host 'Server geloescht!' } else { Write-Host 'Ungueltige Auswahl!' }"

echo.
pause
goto server

:plugins
cls
echo ================================
echo          PLUGIN-MENUE
echo ================================
echo.
echo [1] Verfuegbare Plugins anzeigen
echo [2] Installierte Plugins
echo [3] Zurueck
echo.

set /p "pluginChoice=Auswahl: "

if "%pluginChoice%"=="1" goto availablePlugins
if "%pluginChoice%"=="2" goto installedPlugins
if "%pluginChoice%"=="3" goto menu

goto plugins


:availablePlugins
cls
echo ================================
echo       VERFUEGBARE PLUGINS
echo ================================
echo.

powershell -NoProfile -ExecutionPolicy Bypass -Command ^
"$url='https://raw.githubusercontent.com/mt-bavaria/Browser-GTA-Launcher/main/Plugin-System/plugins.json'; try { $data=Invoke-RestMethod -Uri $url -ErrorAction Stop; foreach($plugin in $data.plugins) { Write-Host ('Name: ' + $plugin.name) -ForegroundColor Green; Write-Host ('Beschreibung: ' + $plugin.description); Write-Host ('Version: ' + $plugin.version); Write-Host '' } } catch { Write-Host 'Plugin-Verzeichnis konnte nicht geladen werden!' -ForegroundColor Red; Write-Host $_.Exception.Message }"

echo.
pause
goto plugins


:installedPlugins
cls
echo ================================
echo       INSTALLIERTE PLUGINS
echo ================================
echo.

if not exist "%~dp0Plugins" (
    echo Noch keine Plugins installiert.
) else (
    dir "%~dp0Plugins" /b /ad
)

echo.
pause
goto plugins
