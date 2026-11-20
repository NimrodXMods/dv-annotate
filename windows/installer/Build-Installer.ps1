<#
.SYNOPSIS
    Build the dV Annotate installer (windows/installer/Output/dv-annotate-setup-<ver>.exe).
.DESCRIPTION
    Reads $Version from windows/dv-annotate.ps1, rebuilds the single-file bundle with
    Build-Bundle.ps1, then compiles dv-annotate.iss with Inno Setup 6 (ISCC.exe).
    Outputs the path of the installer on success; exits non-zero on failure.
.PARAMETER IsccPath
    Path to ISCC.exe. Defaults to ISCC.exe on PATH, else the Inno Setup 6 install
    under Program Files (x86), else a per-user install under %LOCALAPPDATA%\Programs.
#>
param(
    [string]$IsccPath
)

$ErrorActionPreference = 'Stop'

function Stop-Build ([string]$Message) {
    [Console]::Error.WriteLine("Build-Installer: $Message")
    exit 1
}

$windowsDir = Split-Path -Parent $PSScriptRoot
$sourceScript = Join-Path $windowsDir 'dv-annotate.ps1'
$issFile = Join-Path $PSScriptRoot 'dv-annotate.iss'

# Version
$match = Select-String -LiteralPath $sourceScript -Pattern '^\uFEFF?\$Version = "(\d+\.\d+\.\d+)"' | Select-Object -First 1
if (-not $match) { Stop-Build "Could not find a `$Version = `"x.y.z`" line in $sourceScript" }
$version = $match.Matches[0].Groups[1].Value

# Locate ISCC
if (-not $IsccPath) {
    $cmd = Get-Command 'ISCC.exe' -ErrorAction SilentlyContinue
    if ($cmd) {
        $IsccPath = $cmd.Source
    } else {
        $candidates = @()
        if (${env:ProgramFiles(x86)}) { $candidates += (Join-Path ${env:ProgramFiles(x86)} 'Inno Setup 6\ISCC.exe') }
        if ($env:LOCALAPPDATA) { $candidates += (Join-Path $env:LOCALAPPDATA 'Programs\Inno Setup 6\ISCC.exe') }
        foreach ($c in $candidates) {
            if (Test-Path -LiteralPath $c -PathType Leaf) { $IsccPath = $c; break }
        }
    }
}
if (-not $IsccPath -or -not (Test-Path -LiteralPath $IsccPath -PathType Leaf)) {
    Stop-Build "ISCC.exe (Inno Setup 6) not found. Install Inno Setup 6 or pass -IsccPath."
}

# Bundle
$global:LASTEXITCODE = 0
$null = & (Join-Path $windowsDir 'Build-Bundle.ps1')
if (-not $? -or $LASTEXITCODE -ne 0) { Stop-Build 'Build-Bundle.ps1 failed.' }

# Compile
& $IsccPath "/DAppVersion=$version" $issFile
if ($LASTEXITCODE -ne 0) { Stop-Build "ISCC.exe failed with exit code $LASTEXITCODE." }

$output = Join-Path $PSScriptRoot "Output\dv-annotate-setup-$version.exe"
if (-not (Test-Path -LiteralPath $output -PathType Leaf)) { Stop-Build "Expected installer not found: $output" }
Write-Output $output
