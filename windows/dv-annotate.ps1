$Version = "1.2.0"
# Windows PowerShell GUI script for annotating log messages for the game
# Delta V: Rings of Saturn and archiving up the logs, annotations,
# save games, and screemshots to send off to Kodera for debugging.
#
# See here for instructions: https://delta-v.kodera.pl/index.php/DV_Annotate
#
# This only needs Windows PowerShell 5.1 which comes with Windows 10.
#Requires -Version 5.1

###########################################################################
# Preferences are stored in %APPDATA%\dV-annotate\prefs.json
# This file will be created if it doesn't exist, and it can be text
# edited if desired. If deleted then it gets reset to the default.
###########################################################################
$dataDir = (Join-Path $env:APPDATA 'dV-annotate')
$prefsFile = (Join-Path $dataDir 'prefs.json')

# Editing these won't do anything if the prefs file already exists.
$defaultPrefs = @{
    # This is the game save directory for dV.
    dVGameDir           = (Join-Path $env:APPDATA 'dV')
    # This is the ilename for annotations log.
    dVReadme            = '_README.txt'
    # This is where to look for recent screenshots to include
    # in the zip archive. It gets guessed at dynamically later.
    dVScreenshotsDir    = ''
    includeScreenshots  = $true
    # This is the output directory for the created zip archive.
    outputDir           = (Join-Path $env:USERPROFILE 'Downloads')
    ResetReadme         = $true
    # These only matter for autodiscovering the steam overlay
    # screenshots folder and don't matter otherwise.
    steamUserDir        = (${env:ProgramFiles(x86)}, 'Steam', 'userdata') -join '\'
    steamUserID         = ''
    # Version to help detect upgrades
    Version             = $Version
}
$prefs = [PSCustomObject]@{}
$defaultScreenshotsDir = ($env:USERPROFILE, 'Pictures', 'dV-annotate') -join '\'

###### Static values and things that may not matter.
# The static steam app ID for dV. Only matters for finding the steam
# screenshots dir.
$steamAppID = '846030'
# Terminal output preferences. These don't matter if not using the terminal.
$DebugPreference = 'SilentlyContinue'
$VerbosePreference = 'SilentlyContinue'

# (get-item 'hklm:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Steam App 846030').GetValue('InstallLocation')

function LoadOrCreatePrefsFile {
    # create prefs directory if it doesn't exist
    if ( -not (Test-Path -Type Container $dataDir) ) {
        try {
            New-Item -Type Directory -Force -Path $dataDir
        }
        catch {
            ErrorBox "Default datra directory '$dataDir' can't be created. $_" "Fatal Error"
            Write-Error $_
            exit 1
        }
    }
    # create prefs.json if it doesn't exist
    if ( -not (Test-Path -PathType Leaf -LiteralPath $prefsFile) ) {
        try {
            $defaultPrefs | ConvertTo-Json > $prefsFile
        }
        catch {
            ErrorBox "Default prefs file $prefsFile can't be created. $_" "Fatal Error"
            Write-Error $_
            exit 1
        }
    }
    try {
        # load prefs file
        $script:prefs = (Get-Content -Raw $prefsFile | ConvertFrom-Json)
        if ( $null -eq $script:prefs.includeScreenshots ) {
            Add-Member -InputObject $script:prefs -MemberType NoteProperty -Name 'includeScreenshots' -Value $true
        }
        if ( $null -eq $script:prefs.resetReadme ) {
            Add-Member -InputObject $script:prefs -MemberType NoteProperty -Name 'resetReadme' -Value $true
        }
    }
    catch {
        ErrorBox "$prefsFile exists but can't be parsed. Please correct the JSON or delete the file and relaunch to recreate it." "Fatal Error"
        Write-Error $_
        exit 1
    }

    # Use $prefs.dvScreenshotsDir if set, otherwise: try to figure it out, set to default if that fails
    try {
        if (-not $prefs.dVScreenshotsDir) {
            # Attempt to automatically find the Steam screenshots directory for this game
            $prefs.dVScreenshotsDir = & {
                if ( ( $null -eq $prefs.steamUserID ) -or ( '' -eq $prefs.steamUserID ) ) {
                    $fobj = Get-ChildItem $prefs.steamUserDir | Sort-Object -Property LastWriteTime | Select-Object -Last 1
                    if ( $null -eq $fobj ) {
                        Write-Verbose "Couldn't find Steam screenshots in '$($prefs.steamUserData)'"
                        return $defaultScreenshotsDir
                    }
                    else {
                        $prefs.steamUserID = [System.String]$fobj.Name
                        Write-Verbose "SteamID = $($prefs.steamUserID)"
                    }
                }
                $path = ($prefs.steamUserDir, $prefs.steamUserID, '760\remote', $steamAppID, 'screenshots') -join '\'
                if ( -not (Test-Path -PathType Container -LiteralPath $path) ) {
                    Write-Verbose "Found Steam user directory but couldn't find Steam Delta V screenshots path $path"
                    return $defaultScreenshotsDir
                }
                Write-Verbose "Found Steam screenshots path: '$path'"
                $path
            }
            SavePrefsFile
        }
    }
    catch {
        Write-Verbose "Couldn't find screenshots directory automatically: $_"
        $prefs.dVScreenshotsDir = $defaultScreenshotsDir
        SavePrefsFile
        Write-Verbose "Directory set to default: '$($prefs.dVScreenshotsDir)'"
    }
    Write-Debug "Prefs loaded: $prefs"
}

function SavePrefsFile {
    try {
        $prefs | ConvertTo-Json > $prefsFile
    }
    catch {
        ErrorBox "Error trying to save prefs in '$prefsFile': $_" "Error Saving Preferences"
    }
    Write-Debug "Prefs saved: $prefs"
}

# Load the cmdlet to create windows explorer shortcuts.
. (Join-Path $PSScriptRoot 'New-Shortcut.ps1')

function LightweightInstall {
    $installedScriptName = 'dv-annotate.ps1'
    $installedScriptPath = (Join-Path $dataDir $installedScriptName)
    $shortcutName = 'dV Annotate'

    # "Flavor text" installation confirmation.
    [Console]::Title = "dv-Annotate Lightweight Install (Version $Version)"
    [Console]::BackgroundColor = 'Black'
    [Console]::ForegroundColor = 'Green'
    [Console]::BufferHeight = 120
    [Console]::BufferWidth = 80
    [Console]::WindowHeight = 24
    [Console]::WindowWidth = 80
    [Console]::Clear()
    for ($i = 0; $i -lt (5..10 | Get-Random) ; $i++) {
        Write-Output ('.' * (1..60 | Get-Random))
    }
    Write-Output @"
`n
This is autonomous Edge Runner Trusty Attitude. You have been seleceted to
assist ATLAS in discovering possibly dangerous software anomalies in this area.
If you would like to accept, please open a port and authorize my access to
install specialized reporting software in:

$installedScriptPath
(Install/Upgrade to Version ${Version})

To make this suitable for crew use, I will then create an access icon named
'${shortcutName}' in your on board interface in the following location:

$PSScriptRoot

You can then move the icon to any human interface location that you find
optimal.

Would you like to accept? (y/n)
"@
    if ( [Console]::ReadKey($true).KeyChar -ine 'y' ) {
        exit 0
    }

    Write-Output "`n"
    try {
        # This can also be used to upgrade.
        if ( -not (Test-Path -PathType Container $dataDir) ) {
            New-Item -Type Directory -Force -Path $dataDir -ErrorAction Stop *>&1 | Out-Null
            Write-Output '[Data directory created.]'
        }
        if ( (Test-Path $installedScriptPath) ) {
            Write-Output '[Replacing existing version.]'
        }
        Remove-Item -Force $installedScriptPath -ErrorAction SilentlyContinue *>&1 | Out-Null
        Move-Item -Force $PSCommandPath $installedScriptPath -ErrorAction Stop *>&1 | Out-Null
        Write-Output '[Script moved to data directory.]'

        $ShortcutParams = @{
            # This is the same directory the script was executed from.
            Path         = (Join-Path $PSScriptRoot "${shortcutName}.lnk")
            # Standard Windows Powershell 5.1 location
            TargetPath   = "$env:SystemRoot\System32\windowspowershell\v1.0\powershell.exe"
            WindowStyle  = 'Minimized'
            Arguments    = "-NoProfile -WindowStyle Hidden -ExecutionPolicy RemoteSigned -Command ${installedScriptPath}"
            # This is a standard explorer icon that looks like a page with a pencil.
            IconLocation = '%SystemRoot%\System32\SHELL32.dll,269'
        }
        $shortcut = New-Shortcut @ShortcutParams
        if ( $shortcut ) {
            Write-Output '[Shortcut created in the same folder you ran the script from.]'
        }

        Write-Output @'

Reporting systems upgraded. Thank you for your cooperation.

[After closing this terminal window, double-click the new shortcut icon to
run the script. It will work even if you move it elsewhere.]
'@
    }
    catch {
        Write-Error "Installation failed with the error: $_"
        Write-Error "Please report this to the author."
    }

    Write-Output "`nPress any key to exit."
    [Console]::ReadKey($true) | Out-Null
    exit 0
}

# Load the cmdlet to create windows explorer shortcuts.
. (Join-Path $PSScriptRoot 'New-Shortcut.ps1')

# Run the Lightweight Install if not running from the data directory.
if ( $PSScriptRoot -ine $dataDir ) { LightweightInstall }

<##
### Informational and confirmational UI functions.
##>

function UpdateStatusMessage ([Parameter(Mandatory)][System.String]$Message) {
    $ToolStripStatusLabel1.Text = $Message
    Write-Verbose "Status: $Message"
}

function ConfirmBox ( [Parameter(Mandatory)][System.String]$Message,
    [System.String]$Caption = 'Confirm' ) {
    $dr = [System.Windows.Forms.MessageBox]::Show($Message, $Caption,
        [System.Windows.Forms.MessageBoxButtons]::OKCancel,
        [System.Windows.Forms.MessageBoxIcon]::Exclamation)
    $dr -eq [System.Windows.Forms.DialogResult]::OK
}

function InfoBox ( [Parameter(Mandatory)][System.String]$Message,
    [System.String]$Caption = 'Info' ) {
    [System.Windows.Forms.MessageBox]::Show($Message, $Caption,
        [System.Windows.Forms.MessageBoxButtons]::OK,
        [System.Windows.Forms.MessageBoxIcon]::Information)
}

function ErrorBox ( [Parameter(Mandatory)][System.String]$Message,
    [System.String]$Caption = 'Error' ) {
    [System.Windows.Forms.MessageBox]::Show($Message, $Caption,
        [System.Windows.Forms.MessageBoxButtons]::OK,
        [System.Windows.Forms.MessageBoxIcon]::Exclamation)
}

<##
### Timestamp formatting functions
##>

function GetFormattedTimestamp ( $timeStamp = $null ) {
    $dtFormat = "yyyy'/'MM'/'dd' 'HH':'mm':'ss"
    if ($null -eq $timeStamp) {
        [System.String](Get-Date -Format $dtFormat)
    }
    else {
        [System.String](Get-Date -Date $timeStamp -Format $dtFormat)
    }
}

function GetFilenameFormattedTimestamp ( $timeStamp = $null ) {
    $dtFormat = "yyyy''MM''dd'_T'HH'_'mm'_'sszz"
    if ($null -eq $timeStamp) {
        [System.String](Get-Date -Format $dtFormat)
    }
    else {
        [System.String](Get-Date -Date $timeStamp -Format $dtFormat)
    }
}

<##
### Annotation log functions.
##>

function GetScreenshots {
    $dVReadme = (Join-Path $prefs.dVGameDir $prefs.dVReadme)
    $readmeCreationTime = (Get-Item $dVReadme).CreationTime

    Get-ChildItem -LiteralPath $prefs.dVScreenshotsDir |
        Where-Object { ($_.Name -match '(\.jpg|\.png)$') -and ($_.LastWriteTime -gt $readmeCreationTime) }
}

function WriteReadme ( [Parameter(Mandatory)][string]$LogMessage, $timeStamp = $null ) {
    $dVReadme = (Join-Path $prefs.dVGameDir $prefs.dVReadme)
    $tstr = (GetFormattedTimestamp $timeStamp)
    $lastScreenshot = (GetScreenshots | Sort-Object -Property LastWriteTime | Select-Object -Last 1)
    $ssInfo = ''
    if ($lastScreenshot) {
        $ssInfo = " [${lastScreenshot}]"
    }
    Add-Content -LiteralPath $dVReadme -Value "[${tstr}] -- ${LogMessage}${ssInfo}"
}

function ResetReadme {
    $dVReadme = (Join-Path $prefs.dVGameDir $prefs.dVReadme)
    Remove-Item -LiteralPath $dVReadme -Force -ErrorAction SilentlyContinue
    New-Item -Type File -Path $dVReadme
    WriteReadme 'Annotation log reset. See _screenshots folder for any mentioend screenshots.'
}

function CreateReadmeIfNeeded {
    $dVReadme = (Join-Path $prefs.dVGameDir $prefs.dVReadme)
    if ( -not (Test-Path -LiteralPath $dVReadme) ) {
        ResetReadme
        UpdateStatusMessage 'New annotation log file created.'
    }
}

function LoadReadmeString {
    $dVReadme = (Join-Path $prefs.dVGameDir $prefs.dVReadme)
    $logText = $null
    $logText = (Get-Content -LiteralPath $dVReadme -Raw -ErrorAction SilentlyContinue)
    if ( $null -eq $logText ) {
        $logText = "[Unable to retrieve annotations. '$dVReadme' doesn't exist?]"
        UpdateStatusMessage "Can't display annotation log in Review tab."
    }
    else {
        UpdateStatusMessage 'Loaded annotations log file into viewer.'
    }
    $logText
}

function GetZipFilename {
    [System.String]('dV-Log-' + (GetFilenameFormattedTimestamp) + '.zip')
}

function CreateZipArchive ( [bool]$includeScreenshots = $true, [bool]$resetReadme = $true ) {
     try {
        $guid = (New-Guid)
        $tmpDirName = (Join-Path $env:TEMP "${guid}.tmp")
        $tmpDir = $null

        try {
            $tmpDir = (New-Item -Type Directory -Path $tmpDirName -Verbose -ErrorAction Stop)
            $tmpDv = (Join-Path $tmpDir 'dV')
        } catch {
            Write-Verbose $_.InvocationInfo.PositionMessage
            $errMessage = ('Failed to create temporary directory: ' + [System.String]$_.Exception.GetType())
            UpdateStatusMessage $errMessage
            ErrorBox $errMessage -Caption 'Archive Operation Failed'
            return
        }

        try {
            Copy-Item -Recurse -LiteralPath $prefs.dVGameDir -Destination $tmpDir -ErrorAction Stop
        }
        catch {
            Write-Verbose $_.InvocationInfo.PositionMessage
            $errMessage = ('Copying game directory failed with exception: ' + [System.String]$_.Exception.GetType())
            UpdateStatusMessage $errMessage
            ErrorBox $errMessage -Caption 'Archive Operation Failed'
            return
        }

        try {
            if ( $includeScreenshots -and (Test-Path -Path $prefs.dVScreenshotsDir -PathType Container) ) {
                $tmpScreenshots = (Join-Path $tmpDv '_screenshots')
                New-Item -ItemType Directory -Path $tmpScreenshots -ErrorAction Stop
                $screenshots = (GetScreenshots)
                if ( $screenshots ) {
                    foreach ($file in $screenshots ) {
                        $filePath = $file.FullName
                        (Copy-Item $filePath -Destination $tmpScreenshots -PassThru -ErrorAction Stop)
                        UpdateStatusMessage "Copied '${filePath}'..."
                    }
                    UpdateStatusMessage ("Found and copied " + $screenshots.Count + " recent screenshots.")
                } else {
                    UpdateStatusMessage "No screenshots newer than the annotation log were found."
                }
            }
        }
        catch {
            Write-Verbose $_.InvocationInfo.PositionMessage
            $errMessage = ('Copying screenshots failed with exception: ' + [System.String]$_.Exception.GetType())
            UpdateStatusMessage $errMessage
            ErrorBox $errMessage -Caption 'Screenshots Copy Failed'
        }

        try {
            $zipFileName = (GetZipFilename)
            (Compress-Archive -DestinationPath (Join-Path $prefs.outputDir $zipFileName) -LiteralPath $tmpDv -CompressionLevel Optimal -ErrorAction Stop)
        }
        catch {
            Write-Verbose $_.InvocationInfo.PositionMessage
            $errMessage = ('Archiving failed with exception: ' + [System.String]$_.Exception.GetType())
            UpdateStatusMessage $errMessage
            ErrorBox $errMessage -Caption 'Archive Operation Failed'
            return
        }

        UpdateStatusMessage "Success. '${zipFileName}' created in '$($prefs.outputDir)'"

        if ( $resetReadme ) {
            ResetReadme
        }
    }
    catch {
        Write-Verbose $_.InvocationInfo.PositionMessage
        $errMessage = ('Unexpected archive operation failure: ' + [System.String]$_.Exception.GetType())
        UpdateStatusMessage $errMessage
        ErrorBox $errMessage -Caption 'Archive Operation Failed'
        return
    }
    finally {
        Remove-Item -Force -Recurse -LiteralPath $tmpDir
    }
}

# Load the GUI code
. (Join-Path $PSScriptRoot 'dv-annotate-form.ps1')