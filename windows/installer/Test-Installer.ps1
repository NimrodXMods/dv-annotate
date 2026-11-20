<#
.SYNOPSIS
    Smoke-test the dV Annotate installer: install, upgrade, uninstall.
.DESCRIPTION
    Runs the setup exe silently, checks the installed script and Start Menu
    shortcut, checks an upgrade install preserves prefs.json, then runs the
    uninstaller and checks the script is removed while prefs.json remains.
    Throws on the first failed assertion.
.PARAMETER Setup
    Path to dv-annotate-setup-<ver>.exe.
#>
param(
    [Parameter(Mandatory = $true)]
    [string]$Setup
)

$ErrorActionPreference = 'Stop'

# This installs and uninstalls into the real %APPDATA%\dV-annotate (and the real
# Start Menu), deleting the app there, so only run it on a throwaway CI runner.
if ($env:GITHUB_ACTIONS -ne 'true') {
    Write-Error 'Test-Installer.ps1 installs and uninstalls into the real %APPDATA%\dV-annotate. Refusing to run outside GitHub Actions.'
    exit 1
}

$installDir = Join-Path $env:APPDATA 'dV-annotate'
$scriptPath = Join-Path $installDir 'dv-annotate.ps1'
$prefsPath = Join-Path $installDir 'prefs.json'
$uninstaller = Join-Path $installDir 'unins000.exe'
$shortcutPath = Join-Path $env:APPDATA 'Microsoft\Windows\Start Menu\Programs\dV Annotate.lnk'

function Assert-That {
    param([bool]$Condition, [string]$Message)
    if (-not $Condition) { throw "ASSERTION FAILED: $Message" }
    Write-Output "ok: $Message"
}

function Invoke-Setup {
    $p = Start-Process -FilePath $Setup -ArgumentList '/VERYSILENT', '/SUPPRESSMSGBOXES', '/CURRENTUSER', '/NORESTART' -Wait -PassThru
    Assert-That ($p.ExitCode -eq 0) "setup exited with code 0 (was $($p.ExitCode))"
}

$Setup = (Resolve-Path -LiteralPath $Setup).Path

# First install
Invoke-Setup
Assert-That (Test-Path -LiteralPath $scriptPath) 'dv-annotate.ps1 installed'
Assert-That (Test-Path -LiteralPath $shortcutPath) 'Start Menu shortcut exists'
$shell = New-Object -ComObject WScript.Shell
$lnk = $shell.CreateShortcut($shortcutPath)
Assert-That ($lnk.Arguments -like '*-ExecutionPolicy Bypass*') "shortcut arguments contain -ExecutionPolicy Bypass ($($lnk.Arguments))"

# Upgrade install must not touch prefs.json
$dummy = '{"dummy":"keep-me"}'
[System.IO.File]::WriteAllText($prefsPath, $dummy)
Invoke-Setup
Assert-That (Test-Path -LiteralPath $prefsPath) 'prefs.json present after upgrade'
Assert-That ([System.IO.File]::ReadAllText($prefsPath) -ceq $dummy) 'prefs.json unchanged after upgrade'

# Uninstall. The Inno uninstaller re-launches itself and returns early, so poll.
Assert-That (Test-Path -LiteralPath $uninstaller) 'uninstaller present'
Start-Process -FilePath $uninstaller -ArgumentList '/VERYSILENT' -Wait | Out-Null
$deadline = (Get-Date).AddSeconds(60)
while ((Test-Path -LiteralPath $scriptPath) -and ((Get-Date) -lt $deadline)) {
    Start-Sleep -Seconds 1
}
Assert-That (-not (Test-Path -LiteralPath $scriptPath)) 'dv-annotate.ps1 removed by uninstall'
Assert-That (Test-Path -LiteralPath $prefsPath) 'prefs.json remains after uninstall'

Write-Output 'Installer smoke test passed.'
