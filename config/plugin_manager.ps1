param(
    [string]$Mode = "available"
)

$base = Split-Path -Parent $PSScriptRoot
$json = Join-Path $PSScriptRoot "plugins.json"
$stateFolder = Join-Path $env:LOCALAPPDATA "GTA-Launcher"
$state = Join-Path $stateFolder "active_plugins.txt"

if (!(Test-Path $stateFolder)) {
    New-Item -ItemType Directory -Path $stateFolder -Force | Out-Null
}

if (!(Test-Path $state)) {
    New-Item -ItemType File -Path $state -Force | Out-Null
}

try {
    $data = Get-Content -LiteralPath $json -Raw | ConvertFrom-Json
    $active = @(Get-Content -LiteralPath $state -ErrorAction SilentlyContinue)

    $plugins = @()

    foreach ($plugin in $data.plugins) {
        $folder = Get-ChildItem (Join-Path $base "Plugins") -Directory |
            Where-Object { $_.Name -ieq $plugin.id -or $_.Name -ieq $plugin.name } |
            Select-Object -First 1

        $file = if ($folder) {
            Join-Path $folder.FullName "plugin.bat"
        } else {
            ""
        }

        $plugins += [PSCustomObject]@{
            Id = $plugin.id
            Name = $plugin.name
            Description = $plugin.description
            Version = $plugin.version
            File = $file
            Installed = ($file -ne "" -and (Test-Path $file))
        }
    }

    switch ($Mode) {

        "available" {
            Write-Host "VERFUEGBARE PLUGINS" -ForegroundColor Cyan
            Write-Host ""

            foreach ($plugin in $plugins) {
                $status = if ($plugin.Installed) { "VORHANDEN" } else { "FEHLT" }

                Write-Host "[$status] $($plugin.Name)"
                Write-Host $plugin.Description
                Write-Host "Version: $($plugin.Version)"
                Write-Host ""
            }
        }

        "installed" {
            Write-Host "INSTALLIERTE PLUGINS" -ForegroundColor Cyan
            Write-Host ""

            foreach ($plugin in $plugins | Where-Object { $_.Installed }) {
                $status = if ($active -contains $plugin.Id) { "AKTIV" } else { "INAKTIV" }
                Write-Host "[$status] $($plugin.Name)"
            }
        }

        "manage" {
            $available = @($plugins | Where-Object { $_.Installed })

            if ($available.Count -eq 0) {
                Write-Host "Keine Plugins gefunden."
                break
            }

            Write-Host "PLUGINS VERWALTEN" -ForegroundColor Cyan
            Write-Host ""

            for ($i = 0; $i -lt $available.Count; $i++) {
                $status = if ($active -contains $available[$i].Id) { "AKTIV" } else { "INAKTIV" }
                Write-Host "[$($i + 1)] $($available[$i].Name) - $status"
            }

            Write-Host ""
            $choice = Read-Host "Nummer eingeben (0 = Zurueck)"

            if ($choice -eq "0") {
                break
            }

            $number = 0

            if ([int]::TryParse($choice, [ref]$number) -and $number -ge 1 -and $number -le $available.Count) {
                $id = $available[$number - 1].Id

                if ($active -contains $id) {
                    $active = @($active | Where-Object { $_ -ne $id })
                    Write-Host "Plugin deaktiviert."
                }
                else {
                    $active += $id
                    Write-Host "Plugin aktiviert."
                }

                Set-Content -LiteralPath $state -Value $active -Encoding UTF8
            }
            else {
                Write-Host "Ungueltige Auswahl."
            }
        }
    }
}
catch {
    Write-Host "FEHLER:" -ForegroundColor Red
    Write-Host $_.Exception.Message
}
