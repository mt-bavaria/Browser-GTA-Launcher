$ErrorActionPreference = "Stop"

# Einstellungen
$InstallPath = "$env:LOCALAPPDATA\GTA-Launcher"

$GitHubUser = "mt-bavaria"
$Repository = "Browser-GTA-Launcher"
$Branch = "main"

$DownloadURL = "https://raw.githubusercontent.com/$GitHubUser/$Repository/$Branch/GTA_in_Browser.bat"

Write-Host ""
Write-Host "==================================" -ForegroundColor Cyan
Write-Host "       GTA LAUNCHER INSTALLER"
Write-Host "==================================" -ForegroundColor Cyan
Write-Host ""

try {

    # Installationsordner erstellen
    Write-Host "[1/4] Installationsordner erstellen..."

    New-Item -ItemType Directory -Force -Path $InstallPath | Out-Null

    # Launcher herunterladen
    Write-Host "[2/4] Launcher herunterladen..."

    $LauncherPath = Join-Path $InstallPath "GTA-Launcher.bat"

	$response = Invoke-WebRequest -Uri $DownloadURL

	if ($response.StatusCode -ne 200) {
		throw "Download fehlgeschlagen."
	}

	if ($response.Content -notmatch "@echo off") {
		throw "Die heruntergeladene Datei ist keine gueltige Batchdatei."
	}

	[System.IO.File]::WriteAllText(
		$LauncherPath,
		$response.Content,
		[System.Text.Encoding]::UTF8
	)

    # Desktop-Verknüpfung erstellen
    Write-Host "[3/4] Desktop-Verknüpfung erstellen..."

    $Desktop = [Environment]::GetFolderPath("Desktop")
    $ShortcutPath = Join-Path $Desktop "GTA Launcher.lnk"

    $WScriptShell = New-Object -ComObject WScript.Shell
    $Shortcut = $WScriptShell.CreateShortcut($ShortcutPath)

    $Shortcut.TargetPath = $LauncherPath
    $Shortcut.WorkingDirectory = $InstallPath
    $Shortcut.Save()

    # Fertig
    Write-Host ""
    Write-Host "[4/4] Installation abgeschlossen!" -ForegroundColor Green

    Write-Host ""
    Write-Host "GTA Launcher wurde installiert!"
    Write-Host "Installationsort: $InstallPath"

}
catch {
    Write-Host ""
    Write-Host "FEHLER: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Read-Host "Enter zum Beenden"