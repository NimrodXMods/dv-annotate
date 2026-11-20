<#
.SYNOPSIS
    Build windows/build/dv-annotate.ps1, the single-file distributable.
.DESCRIPTION
    Starts from dv-annotate.ps1 and recursively inlines every line of the form
    ". (Join-Path $PSScriptRoot 'file.ps1')" (including "$x = . (Join-Path ...)"),
    the same way PowerShell Pro Tools' Merge-Script produced earlier bundles.
    Output is written as UTF-8 with BOM so Windows PowerShell 5.1 reads it correctly.
#>
param(
    [string]$Root = $PSScriptRoot,
    [string]$Out = (Join-Path $PSScriptRoot 'build\dv-annotate.ps1')
)

$pattern = '^(?<pre>.*?)\.\s*\(Join-Path \$PSScriptRoot ''(?<f>[^'']+)''\)\s*$'

function Expand-DotSource ([string]$path) {
    foreach ($line in (Get-Content -LiteralPath $path -Encoding UTF8)) {
        $m = [regex]::Match($line, $pattern)
        if (-not $m.Success) { $line; continue }
        $inner = (Expand-DotSource (Join-Path $Root $m.Groups['f'].Value)) -join "`r`n"
        "$($m.Groups['pre'].Value)$inner"
    }
}

$text = ((Expand-DotSource (Join-Path $Root 'dv-annotate.ps1')) -join "`r`n").TrimStart([char]0xFEFF)
[IO.File]::WriteAllText($Out, $text, (New-Object System.Text.UTF8Encoding $true))
Write-Output "Wrote $Out"
