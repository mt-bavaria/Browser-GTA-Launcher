$ErrorActionPreference = "Stop"

# Einstellungen
$InstallPath = "$env:LOCALAPPDATA\GTA-Launcher"

$GitHubUser = "mt-bavaria"
$Repository = "Browser-GTA-Launcher"
$Branch = "main"

$BaseURL = "https://raw.githubusercontent.com/$GitHubUser/$Repository/$Branch"

$DownloadURL = "$BaseURL/GTA_in_Browser.bat"
$IconURL = "$BaseURL/GTA-Launcher.ico"

Write-Host ""
Write-Host "==================================" -ForegroundColor Cyan
Write-Host "       GTA LAUNCHER INSTALLER"
Write-Host "==================================" -ForegroundColor Cyan
Write-Host ""

try {

    # Installationsordner erstellen
    Write-Host "[1/5] Installationsordner erstellen..."

    New-Item -ItemType Directory -Force -Path $InstallPath | Out-Null

    # Launcher herunterladen
    Write-Host "[2/5] Launcher herunterladen..."

    $LauncherPath = Join-Path $InstallPath "GTA-Launcher.bat"

    $Response = Invoke-WebRequest -Uri $DownloadURL

    if ($Response.StatusCode -ne 200) {
        throw "Launcher-Download fehlgeschlagen."
    }

    if ($Response.Content -notmatch "@echo off") {
        throw "Keine gueltige Batchdatei gefunden."
    }

    [System.IO.File]::WriteAllText(
        $LauncherPath,
        $Response.Content,
        [System.Text.Encoding]::UTF8
    )

    # Logo herunterladen
    Write-Host "[3/5] Launcher-Logo herunterladen..."

    $IconPath = Join-Path $InstallPath "GTA-Launcher.ico"

    Invoke-WebRequest -Uri $IconURL -OutFile $IconPath

    if (!(Test-Path $IconPath) -or (Get-Item $IconPath).Length -eq 0) {
        throw "Logo-Download fehlgeschlagen."
    }

    # Desktop-Verknüpfung erstellen
    Write-Host "[4/5] Desktop-Verknuepfung erstellen..."

    $Desktop = [Environment]::GetFolderPath("Desktop")
    $ShortcutPath = Join-Path $Desktop "GTA Launcher.lnk"

    $WScriptShell = New-Object -ComObject WScript.Shell
    $Shortcut = $WScriptShell.CreateShortcut($ShortcutPath)

    $Shortcut.TargetPath = $LauncherPath
    $Shortcut.WorkingDirectory = $InstallPath
    $Shortcut.IconLocation = $IconPath

    $Shortcut.Save()

    # Fertig
    Write-Host ""
    Write-Host "[5/5] Installation abgeschlossen!" -ForegroundColor Green

    Write-Host ""
    Write-Host "GTA Launcher wurde erfolgreich installiert!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Installationsort: $InstallPath"
    Write-Host "Desktop-Verknuepfung erstellt."
    Write-Host "Eigenes Launcher-Logo eingerichtet."

}
catch {
    Write-Host ""
    Write-Host "FEHLER: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Read-Host "Enter zum Beenden"
