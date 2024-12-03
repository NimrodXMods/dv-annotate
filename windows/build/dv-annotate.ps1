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
<#
.SYNOPSIS
    Create a shortcut in Windows Explorer.
.DESCRIPTION
    This will use WSH COM to tell Windows Explorer to create a shortcut.
.NOTES
    There isn't much error checking, but an exception will prevent the shortcut
    from being saved.

    On success, a System.IO.FileInfo object for the shortcut will be output.
.EXAMPLE
    New-Shortcut -Path c:\foobar.lnk -TargetPath 'c:\program files\TheCoolAppFolder'
#>

function New-Shortcut {
    [CmdletBinding(
        ConfirmImpact='Medium',
        PositionalBinding=$false,
        SupportsShouldProcess)]
    [OutputType([System.IO.Fileinfo])]

    param (
        [Parameter(Mandatory, Position=0,
            HelpMessage='The path of the .lnk or .htm shortcut file to create, including extension.')]
        [ValidateNotNullOrEmpty()]
        [System.String] $Path,
        [Parameter(Mandatory, Position=1,
            HelpMessage='The target pathname that the shortcut will link to.')]
        [ValidateNotNullOrEmpty()]
        [System.String]$TargetPath,
        [Parameter(
            HelpMessage='The comment field that shows up in the windows explorer field.'
        )]
        [ValidateNotNull()]
        [System.String]$Description,
        [Parameter(
            HelpMessage='The arguments string for the target when it is an executable that accepts arguments.'
        )]
        [ValidateNotNull()]
        [System.String]$Arguments = '',
        [Parameter(
            HelpMessage='The default wowrking directory that the command is run in.'
        )]
        [ValidateNotNull()]
        [System.String]$WorkingDirectory = '',
        [Parameter(
            HelpMessage='The initial state of the main window, either Normal, Minimized, or Maximized.'
        )]
        [ValidateSet('Normal', 'Maximized', 'Minimized')]
        [System.String]$WindowStyle = 'Normal',
        [Parameter(
            HelpMessage='The hotkey field.'
        )]
        [ValidateNotNull()]
        [System.String]$Hotkey ='',
        [Parameter(
            HelpMessage=('A string containing "Pathname,ID" (ex. "C:\Foo\Bar.dll,42" )' +
                         ' specifying the icon by file and resource ID.'))]
        [ValidateNotNull()]
        [System.String]$IconLocation = ''
    )

    Begin {
        $Shell = New-Object -ComObject ('WScript.Shell')
        [int]$intWindowStyle = switch ( $WindowStyle ) {
            'Normal'    { 1 }
            'Maximized' { 3 }
            'Minimized' { 7 }
            Default     { 1 }
        }
    }

    Process {
        if ( $PSCmdlet.ShouldProcess('Creating a Windows Explorer shortcut',
                "Should the shortcut '${Path}' with TargetPath '${TargetPath}' be created?") ) {
            try {
                $ShortCut = $Shell.CreateShortcut($Path)
                $ShortCut.TargetPath = $TargetPath
                $ShortCut.Arguments = $Arguments
                $ShortCut.WorkingDirectory = $WorkingDirectory
                $ShortCut.WindowStyle = $intWindowStyle
                $ShortCut.Hotkey = $Hotkey
                # IconLocation format = 'C:\Windows\System32\windowspowershell\v1.0\powershell.exe,0'
                if ( $IconLocation ) { $ShortCut.IconLocation = $IconLocation }
                else { $ShortCut.IconLocation = '%SystemRoot%\System32\SHELL32.dll,1' }
                $ShortCut.Description = $Description
                $ShortCut.Save()
            }
            catch {
                throw
            }
        }
    }

    End {
        [System.IO.FileInfo](Get-ChildItem $Path)
    }
}

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
<#
.SYNOPSIS
    Create a shortcut in Windows Explorer.
.DESCRIPTION
    This will use WSH COM to tell Windows Explorer to create a shortcut.
.NOTES
    There isn't much error checking, but an exception will prevent the shortcut
    from being saved.

    On success, a System.IO.FileInfo object for the shortcut will be output.
.EXAMPLE
    New-Shortcut -Path c:\foobar.lnk -TargetPath 'c:\program files\TheCoolAppFolder'
#>

function New-Shortcut {
    [CmdletBinding(
        ConfirmImpact='Medium',
        PositionalBinding=$false,
        SupportsShouldProcess)]
    [OutputType([System.IO.Fileinfo])]

    param (
        [Parameter(Mandatory, Position=0,
            HelpMessage='The path of the .lnk or .htm shortcut file to create, including extension.')]
        [ValidateNotNullOrEmpty()]
        [System.String] $Path,
        [Parameter(Mandatory, Position=1,
            HelpMessage='The target pathname that the shortcut will link to.')]
        [ValidateNotNullOrEmpty()]
        [System.String]$TargetPath,
        [Parameter(
            HelpMessage='The comment field that shows up in the windows explorer field.'
        )]
        [ValidateNotNull()]
        [System.String]$Description,
        [Parameter(
            HelpMessage='The arguments string for the target when it is an executable that accepts arguments.'
        )]
        [ValidateNotNull()]
        [System.String]$Arguments = '',
        [Parameter(
            HelpMessage='The default wowrking directory that the command is run in.'
        )]
        [ValidateNotNull()]
        [System.String]$WorkingDirectory = '',
        [Parameter(
            HelpMessage='The initial state of the main window, either Normal, Minimized, or Maximized.'
        )]
        [ValidateSet('Normal', 'Maximized', 'Minimized')]
        [System.String]$WindowStyle = 'Normal',
        [Parameter(
            HelpMessage='The hotkey field.'
        )]
        [ValidateNotNull()]
        [System.String]$Hotkey ='',
        [Parameter(
            HelpMessage=('A string containing "Pathname,ID" (ex. "C:\Foo\Bar.dll,42" )' +
                         ' specifying the icon by file and resource ID.'))]
        [ValidateNotNull()]
        [System.String]$IconLocation = ''
    )

    Begin {
        $Shell = New-Object -ComObject ('WScript.Shell')
        [int]$intWindowStyle = switch ( $WindowStyle ) {
            'Normal'    { 1 }
            'Maximized' { 3 }
            'Minimized' { 7 }
            Default     { 1 }
        }
    }

    Process {
        if ( $PSCmdlet.ShouldProcess('Creating a Windows Explorer shortcut',
                "Should the shortcut '${Path}' with TargetPath '${TargetPath}' be created?") ) {
            try {
                $ShortCut = $Shell.CreateShortcut($Path)
                $ShortCut.TargetPath = $TargetPath
                $ShortCut.Arguments = $Arguments
                $ShortCut.WorkingDirectory = $WorkingDirectory
                $ShortCut.WindowStyle = $intWindowStyle
                $ShortCut.Hotkey = $Hotkey
                # IconLocation format = 'C:\Windows\System32\windowspowershell\v1.0\powershell.exe,0'
                if ( $IconLocation ) { $ShortCut.IconLocation = $IconLocation }
                else { $ShortCut.IconLocation = '%SystemRoot%\System32\SHELL32.dll,1' }
                $ShortCut.Description = $Description
                $ShortCut.Save()
            }
            catch {
                throw
            }
        }
    }

    End {
        [System.IO.FileInfo](Get-ChildItem $Path)
    }
}

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
<##
########## Windows Forms UI Control Event Handlers
### (This is where we start seeing the limits of PowerShell capability
### as some of the cracks start to show in the lack of OOP support.)
##>

## Top level window

$FormTop_Activated = {
    $TextBoxAnnotate.Focus()
    Write-Debug 'FormTop_Activated: focused textbox'
}

## Annotate Tab

# Utility functions for time/date pickers
function ResetTimePickerNow {
    $dt = Get-Date
    $DateTimePickerLogDate.Value = $dt
    $DateTimePickerLogTime.Value = $dt
}
function GetTimePickerDateTime {
    $dPicker = [System.DateTime]$DateTimePickerLogDate.Value
    $tPicker = [System.DateTime]$DateTimePickerLogTime.Value
    $dateArgs = @{
        Year   = $dPicker.Year
        Month  = $dPicker.Month
        Day    = $dPicker.Day
        Hour   = $tPicker.Hour
        Minute = $tPicker.Minute
        Second = $tPicker.Second
    }
    Get-Date @dateArgs
}

# Reset time on enter
$TabAnnotate_Enter = {
    ResetTimePickerNow
    UpdateStatusMessage 'Timestamp reset to now.'
}

# Just some whats up messages.
$DateTimePickerLogTime_ValueChanged = {
    UpdateStatusMessage 'Timestamp time changed.'
}
$DateTimePickerLogDate_ValueChanged = {
    UpdateStatusMessage 'Timestamp date changed.'
}

# Save button
$ButtonSave_Click = {
    CreateReadmeIfNeeded
    $comment = $TextBoxAnnotate.Text
    if ( -not $comment ) {
        $comment = 'TIMESTAMP ONLY'
    }
    $dt = (GetTimePickerDateTime)
    WriteReadme $comment $dt
    $TextBoxAnnotate.Clear()
    ResetTimePickerNow
    $TextBoxAnnotate.Focus()
    UpdateStatusMessage "Comment saved for ${dt}. ('$comment')"
}

# clear button
$ButtonClear_Click = {
    $TextBoxAnnotate.Clear()
    ResetTimePickerNow
    $TextBoxAnnotate.Focus()
    UpdateStatusMessage 'Annotation textbox cleared. Timestamp reset to now.'
}

## Review Tab

$TabReview_Enter = {
    $TextBoxLog.Text = (LoadReadmeString)
}

$ButtonOpenReadme_Click = {
    Invoke-Item (Join-Path $prefs.dVGameDir $prefs.dVReadme)
    UpdateStatusMessage 'Attempted to open annotation log in default text editor.'
}

# reset button
$ButtonResetLog_Click = {
    $confirmed = (ConfirmBox 'This will erase all of your annotations! Are you sure?' -Caption 'Confirm Annotation Log Reset')
    if (-not $confirmed) { return }
    ResetReadme
    $TextBoxLog.Text = (LoadReadmeString)
    UpdateStatusMessage 'Annotation log cleared.'
}

## Archive Tab

# Utility functions - yes this needs proper oop like observers
function SetDirectoryValidStatus ( [System.String]$path = '', [Windows.Forms.Control]$ctrl ) {
    if ( -not (Test-Path -PathType Container $path) ) {
        $ctrl.ForeColor = [System.Drawing.Color]::Red
    }
    else {
        $ctrl.ForeColor = [System.Drawing.SystemColors]::WindowText
    }
}
function ShowFolderBrowserDialog ( $description, $initialDir ) {
    $FolderBrowserDialog1.Description = $description
    $FolderBrowserDialog1.SelectedPath = $initialDir
    $FolderBrowserDialog1.ShowNewFolderButton = $true
    $result = $FolderBrowserDialog1.ShowDialog()
    $result
}

# game directory path controls
$LabelDvGameDirPath_VisibleChanged = {
    Write-Debug 'LabelDvGameDirPath_VisibleChanged'
    $LabelDvGameDirPath.Text = $prefs.dVGameDir
    SetDirectoryValidStatus $prefs.dVGameDir $LabelDvGameDirPath
}
$ButtonSetGameDir_Click = {
    $result = ShowFolderBrowserDialog 'Select the Delta V game save directory. NOTE: This seldom needs to be changed!' $prefs.dVGameDir
    if ( $result -eq [System.Windows.Forms.DialogResult]::OK) {
        $prefs.dVGameDir = $folderBrowserDialog1.SelectedPath
        SavePrefsFile
        $LabelDvGameDirPath.Text = $prefs.dVGameDir
        SetDirectoryValidStatus $prefs.dVGameDir $LabelDvGameDirPath
    }
}
$LabelDvGameDirPath_DoubleClick = {
    Invoke-Item $prefs.dVGameDir
    UpdateStatusMessage 'Opened dV game directory in Explorer.'
}

# Screenshots Directory controls
function ValidateScreenshotsDir ( [System.String]$path = '') {
    if ( -not (Test-Path -PathType Container $path) ) {
        $LabelScreenShotsDirPath.ForeColor = [System.Drawing.Color]::Red
        $CheckBoxIncludeSS.Enabled = $false
        $CheckBoxIncludeSS.Checked = $false
    }
    else {
        $LabelScreenShotsDirPath.ForeColor = [System.Drawing.SystemColors]::WindowText
        $CheckBoxIncludeSS.Enabled = $true
        $CheckBoxIncludeSS.Checked = $prefs.includeScreenshots
    }
}
$LabelScreenShotsDirPath_VisibleChanged = {
    Write-Debug 'LabelScreenShotsDirPath_VisibleChang'
    $LabelScreenShotsDirPath.Text = $prefs.dVScreenshotsDir
    ValidateScreenshotsDir $prefs.dVScreenshotsDir
}
$ButtonSetScreenshotsDir_Click = {
    $result = ShowFolderBrowserDialog 'Select a folder to include recent screenshots from.' $prefs.dVScreenshotsDir
    if ( $result -eq [System.Windows.Forms.DialogResult]::OK) {
        $prefs.dVScreenshotsDir = $folderBrowserDialog1.SelectedPath
        SavePrefsFile
        $LabelScreenShotsDirPath.Text = $prefs.dVScreenshotsDir
        ValidateScreenshotsDir $prefs.dVScreenshotsDir
    }
}
$LabelScreenShotsDirPath_DoubleClick = {
    Invoke-Item $prefs.dVScreenshotsDir
    UpdateStatusMessage 'Opened screenshots directoy in Explorer.'
}
# update screenshots checkbox from prefs if the control is enabled
$CheckBoxIncludeSS_VisibleChanged = {
    if ( $CheckBoxIncludeSS.Enabled ) {
        $CheckBoxIncludeSS.Checked = $prefs.includeScreenshots
    }
}
# update prefs if box enabled and changed
$CheckBoxIncludeSS_CheckedChanged = {
    if ( $CheckBoxIncludeSS.Enabled ) {
        $prefs.includeScreenshots = $CheckBoxIncludeSS.Checked
        SavePrefsFile
    }
}

# output directory path controls
$LabelOutputDirPath_VisibleChanged = {
    $LabelOutputDirPath.Text = $prefs.outputDir
    SetDirectoryValidStatus $prefs.outputDir $LabelOutputDirPath
}
$ButtonSetOutputDir_Click = {
    $result = ShowFolderBrowserDialog 'Select a folder to output .zip archive files to.' $prefs.outputDir
    if ( $result -eq [System.Windows.Forms.DialogResult]::OK) {
        $prefs.outputDir = $folderBrowserDialog1.SelectedPath
        SavePrefsFile
        $LabelOutputDirPath.Text = $prefs.outputDir
        SetDirectoryValidStatus $prefs.outputDir $LabelOutputDirPath
    }
}
$LabelOutputDirPath_DoubleClick = {
    Invoke-Item $prefs.outputDir
    UpdateStatusMessage 'Opened output directory in Explorer.'
}

# "don't reset readme" checkbox
$CheckBoxNoResetReadme_CheckedChanged = {
    if ( $CheckBoxNoResetReadme.Enabled ) {
        $prefs.resetReadme = ( -not $CheckBoxNoResetReadme.Checked )
        SavePrefsFile
    }
}
$CheckBoxNoResetReadme_VisibleChanged = {
    if ( $CheckBoxIncludeSS.Enabled ) {
        $CheckBoxNoResetReadme.Checked = ( -not $prefs.resetReadme )
    }
}

# Launch Button
$ButtonLaunch_Click = {
    $dvRegInfo = (Get-childitem 'hklm:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall') |
        Where-Object { $_.GetValue('DisplayName') -like '?V: Rings of Saturn' }
    $dvInstallDir = $dvRegInfo.GetValue('InstallLocation')
    $dvExe = (Join-Path $dvInstallDir 'Delta-V.exe')
    $TabControlTop.SelectTab('TabAnnotate')
    UpdateStatusMessage "Launching Delta V from '$dvExe'"
    Invoke-Item $dvExe
}

# Archive Button
$ButtonArchive_Click = {
    if ( $prefs.resetReadme ) {
        UpdateStatusMessage 'Confirm archive operation...'
        $confirmed = (ConfirmBox 'This will create the archive and reset the current annotation log. Are you sure?' -Caption 'Confirm Operation')
    }
    else {
        $confirmed = $true
    }
    if ( $confirmed ) {
        CreateZipArchive $prefs.includeScreenshots $prefs.resetReadme
    }
    else {
        UpdateStatusMessage 'Archive operation cancelled.'
    }
}

# Include Windows Forms and run the UI tool-generated code.
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
[System.Windows.Forms.Application]::EnableVisualStyles()

<##
########### Tool-generated code below.
###>
$FormTop = New-Object -TypeName System.Windows.Forms.Form
[System.Windows.Forms.TabControl]$TabControlTop = $null
[System.Windows.Forms.TabPage]$TabAnnotate = $null
[System.Windows.Forms.Label]$LabelAnnotateInfo = $null
[System.Windows.Forms.Label]$LabelTimeStamp = $null
[System.Windows.Forms.ToolTip]$ToolTipDefault = $null
[System.ComponentModel.IContainer]$components = $null
[System.Windows.Forms.DateTimePicker]$DateTimePickerLogDate = $null
[System.Windows.Forms.DateTimePicker]$DateTimePickerLogTime = $null
[System.Windows.Forms.Button]$ButtonClear = $null
[System.Windows.Forms.Button]$ButtonSave = $null
[System.Windows.Forms.TextBox]$TextBoxAnnotate = $null
[System.Windows.Forms.TabPage]$TabReview = $null
[System.Windows.Forms.Button]$ButtonResetLog = $null
[System.Windows.Forms.Button]$ButtonOpenReadme = $null
[System.Windows.Forms.Label]$LabelReviewInfo = $null
[System.Windows.Forms.TextBox]$TextBoxLog = $null
[System.Windows.Forms.TabPage]$TabArchive = $null
[System.Windows.Forms.Button]$ButtonLaunch = $null
[System.Windows.Forms.Button]$ButtonSetOutputDir = $null
[System.Windows.Forms.Button]$ButtonSetScreenshotsDir = $null
[System.Windows.Forms.Button]$ButtonSetGameDir = $null
[System.Windows.Forms.CheckBox]$CheckBoxNoResetReadme = $null
[System.Windows.Forms.Label]$LabelOutputDirLabel = $null
[System.Windows.Forms.Label]$LabelGameDirLabel = $null
[System.Windows.Forms.Label]$LabelOutputDirPath = $null
[System.Windows.Forms.CheckBox]$CheckBoxIncludeSS = $null
[System.Windows.Forms.Label]$LabelDvGameDirPath = $null
[System.Windows.Forms.Label]$LabelScreenShotsDirPath = $null
[System.Windows.Forms.Label]$LabelArchiveInfoText = $null
[System.Windows.Forms.Button]$ButtonArchive = $null
[System.Windows.Forms.StatusStrip]$StatusStrip1 = $null
[System.Windows.Forms.ToolStripStatusLabel]$ToolStripStatusLabel1 = $null
[System.Windows.Forms.FolderBrowserDialog]$FolderBrowserDialog1 = $null
function InitializeComponent
{
$components = (New-Object -TypeName System.ComponentModel.Container)
$resources = & { $BinaryFormatter = New-Object -TypeName System.Runtime.Serialization.Formatters.Binary.BinaryFormatter
 @{ 
'ButtonSetScreenshotsDir.Name' = 'ButtonSetScreenshotsDir'
'LabelOutputDirLabel.Name' = 'LabelOutputDirLabel'
'ButtonSetOutputDir.Name' = 'ButtonSetOutputDir'
'FolderBrowserDialog1.TrayLocation' = New-Object -TypeName System.Drawing.Point -ArgumentList @(253, 17)
'ButtonArchive.ToolTip' = 'This will create a ZIP file of the game directory
which will include your annotation log,
save games, game debug logs, and optionally
screenshots.

The ZIP file will appear in the output directory
shown above, and you can open the directory
by double-clicking the pathname.'
'GroupBoxOutputDir.Name' = 'GroupBoxOutputDir'
'ToolTipDefault.Name' = 'ToolTipDefault'
'ButtonSave.Name' = 'ButtonSave'
'ButtonSaveAnnotation.Name' = 'ButtonSaveAnnotation'
'DateTimePicker1.Name' = 'DateTimePicker1'
'LabelScreenShotsDirPath.Name' = 'LabelScreenShotsDirPath'
'LabelDvGameDirPath.Name' = 'LabelDvGameDirPath'
'CheckBoxNoResetReadme.Name' = 'CheckBoxNoResetReadme'
'TabReview.Name' = 'TabReview'
'LabelTimeStamp.Name' = 'LabelTimeStamp'
'LabelSSFLabel.Name' = 'LabelSSFLabel'
'LabelReviewInfo.Name' = 'LabelReviewInfo'
'DateTimePickerLogDate.Name' = 'DateTimePickerLogDate'
'LabelAnnotateInfo.Name' = 'LabelAnnotateInfo'
'LabelGameDirLabel.Name' = 'LabelGameDirLabel'
'TabAnnotate.Name' = 'TabAnnotate'
'TabArchive.Name' = 'TabArchive'
'ButtonResetLog.Name' = 'ButtonResetLog'
'CheckBoxOpenContaining.Name' = 'CheckBoxOpenContaining'
'ButtonArchive.Name' = 'ButtonArchive'
'DateTimePickerLogTime.Name' = 'DateTimePickerLogTime'
'LabelScreenshotsStatus.Name' = 'LabelScreenshotsStatus'
'CheckBox1.Name' = 'CheckBox1'
'GroupBoxScreenshots.Name' = 'GroupBoxScreenshots'
'ButtonOpenReadme.Name' = 'ButtonOpenReadme'
'TextBoxLog.Name' = 'TextBoxLog'
'LabelScreenShotsDir.ToolTip' = 'This is the configured folder to search for screenshots of the game. Only screenshots since the annotations log was created will be copied into the archive. Double click this pathname to open the directory as a folder in a Windows Explorer window.'
'LabelStaticHelp.Name' = 'LabelStaticHelp'
'LabelTimeStamp.ToolTip' = 'This is the timestamp that will be logged in the archive along with your comment
It will be reset to the current time when you forground the window, switch tabs,
or clear the comment field. You can change it manually before saving if needed.'
'CheckBoxIncludeSS.Name' = 'CheckBoxIncludeSS'
'ButtonOpenOutput.Name' = 'ButtonOpenOutput'
'$this.Name' = 'FormTop'
'ToolTipDefault.TrayLocation' = New-Object -TypeName System.Drawing.Point -ArgumentList @(129, 17)
'StatusStrip1.Name' = 'StatusStrip1'
'LabelOutputDirPath.Name' = 'LabelOutputDirPath'
'ButtonSave.ToolTip' = 'This will save the text in the textbox above to the annotation log.
The timestamp on the left will be used for the log entry''s comment.
The text box will then be cleared and the timestamp reset to now.

If you don''t enter any text then a timestamp will be saved with a
comment indicating that only a timestamp was saved.'
'TextBoxAnnotate.Name' = 'TextBoxAnnotate'
'TabControlTop.Name' = 'TabControlTop'
'LabelStaticHelp.Text' = 'Clicking "Create Archive" will create a zip archive of the dV game data directory which includes all saved games and logs. This will include the annotation log and any screenshots since the log was last reset, then reset the annotation log.'
'StatusStrip1.TrayLocation' = New-Object -TypeName System.Drawing.Point -ArgumentList @(17, 17)
'ButtonSetGameDir.Name' = 'ButtonSetGameDir'
'LabelScreenShotsDir.Name' = 'LabelScreenShotsDir'
'LabelOutputDir.Name' = 'LabelOutputDir'
'ButtonOpenContaining.Name' = 'ButtonOpenContaining'
'LabelScreenShotsDirPath.ToolTip' = 'This is the configured or discorvered folder to search for
screenshots of the game. Only screenshots writtemn
since the annotations log was created will be copied into
the archive.

Double click this pathname to open the directory in a an
explorer window.'
'ToolStripStatusLabel1.Name' = 'ToolStripStatusLabel1'
'TopTabControl.Name' = 'TopTabControl'
'ButtonClear.Name' = 'ButtonClear'
'Button1.Name' = 'Button1'
'ButtonTest.Name' = 'ButtonTest'
'LabelArchiveInfoText.Name' = 'LabelArchiveInfoText'
'Label1.Text' = 'Clicking "Create Archive" will create a zip archive of the dV game data directory which includes all saved games and logs. This will include the annotation log and any screenshots since the log was last reset, then reset the annotation log.'
'LabelDvGDPLabel.Name' = 'LabelDvGDPLabel'
'Label1.Name' = 'Label1'
'FolderBrowserDialog1.Name' = 'FolderBrowserDialog1'
'GroupBoxGameDir.Name' = 'GroupBoxGameDir'
'ButtonLaunch.Name' = 'ButtonLaunch'
}
}
$TabControlTop = (New-Object -TypeName System.Windows.Forms.TabControl)
$TabAnnotate = (New-Object -TypeName System.Windows.Forms.TabPage)
$LabelAnnotateInfo = (New-Object -TypeName System.Windows.Forms.Label)
$LabelTimeStamp = (New-Object -TypeName System.Windows.Forms.Label)
$DateTimePickerLogDate = (New-Object -TypeName System.Windows.Forms.DateTimePicker)
$DateTimePickerLogTime = (New-Object -TypeName System.Windows.Forms.DateTimePicker)
$ButtonClear = (New-Object -TypeName System.Windows.Forms.Button)
$ButtonSave = (New-Object -TypeName System.Windows.Forms.Button)
$TextBoxAnnotate = (New-Object -TypeName System.Windows.Forms.TextBox)
$TabReview = (New-Object -TypeName System.Windows.Forms.TabPage)
$ButtonResetLog = (New-Object -TypeName System.Windows.Forms.Button)
$ButtonOpenReadme = (New-Object -TypeName System.Windows.Forms.Button)
$LabelReviewInfo = (New-Object -TypeName System.Windows.Forms.Label)
$TextBoxLog = (New-Object -TypeName System.Windows.Forms.TextBox)
$TabArchive = (New-Object -TypeName System.Windows.Forms.TabPage)
$ButtonSetOutputDir = (New-Object -TypeName System.Windows.Forms.Button)
$ButtonSetScreenshotsDir = (New-Object -TypeName System.Windows.Forms.Button)
$ButtonSetGameDir = (New-Object -TypeName System.Windows.Forms.Button)
$CheckBoxNoResetReadme = (New-Object -TypeName System.Windows.Forms.CheckBox)
$LabelOutputDirLabel = (New-Object -TypeName System.Windows.Forms.Label)
$LabelGameDirLabel = (New-Object -TypeName System.Windows.Forms.Label)
$LabelOutputDirPath = (New-Object -TypeName System.Windows.Forms.Label)
$CheckBoxIncludeSS = (New-Object -TypeName System.Windows.Forms.CheckBox)
$LabelDvGameDirPath = (New-Object -TypeName System.Windows.Forms.Label)
$LabelScreenShotsDirPath = (New-Object -TypeName System.Windows.Forms.Label)
$LabelArchiveInfoText = (New-Object -TypeName System.Windows.Forms.Label)
$ButtonArchive = (New-Object -TypeName System.Windows.Forms.Button)
$StatusStrip1 = (New-Object -TypeName System.Windows.Forms.StatusStrip)
$ToolStripStatusLabel1 = (New-Object -TypeName System.Windows.Forms.ToolStripStatusLabel)
$ToolTipDefault = (New-Object -TypeName System.Windows.Forms.ToolTip -ArgumentList @($components))
$FolderBrowserDialog1 = (New-Object -TypeName System.Windows.Forms.FolderBrowserDialog)
$ButtonLaunch = (New-Object -TypeName System.Windows.Forms.Button)
$TabControlTop.SuspendLayout()
$TabAnnotate.SuspendLayout()
$TabReview.SuspendLayout()
$TabArchive.SuspendLayout()
$StatusStrip1.SuspendLayout()
$FormTop.SuspendLayout()
#
#TabControlTop
#
$TabControlTop.Anchor = ([System.Windows.Forms.AnchorStyles][System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right)
$TabControlTop.Controls.Add($TabAnnotate)
$TabControlTop.Controls.Add($TabReview)
$TabControlTop.Controls.Add($TabArchive)
$TabControlTop.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]0,[System.Int32]0))
$TabControlTop.Name = [System.String]'TabControlTop'
$TabControlTop.SelectedIndex = [System.Int32]0
$TabControlTop.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]585,[System.Int32]296))
$TabControlTop.SizeMode = [System.Windows.Forms.TabSizeMode]::Fixed
$TabControlTop.TabIndex = [System.Int32]0
$TabControlTop.TabStop = $false
#
#TabAnnotate
#
$TabAnnotate.Controls.Add($LabelAnnotateInfo)
$TabAnnotate.Controls.Add($LabelTimeStamp)
$TabAnnotate.Controls.Add($DateTimePickerLogDate)
$TabAnnotate.Controls.Add($DateTimePickerLogTime)
$TabAnnotate.Controls.Add($ButtonClear)
$TabAnnotate.Controls.Add($ButtonSave)
$TabAnnotate.Controls.Add($TextBoxAnnotate)
$TabAnnotate.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]4,[System.Int32]25))
$TabAnnotate.Name = [System.String]'TabAnnotate'
$TabAnnotate.Padding = (New-Object -TypeName System.Windows.Forms.Padding -ArgumentList @([System.Int32]3))
$TabAnnotate.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]577,[System.Int32]267))
$TabAnnotate.TabIndex = [System.Int32]0
$TabAnnotate.Text = [System.String]'Annotate'
$ToolTipDefault.SetToolTip($TabAnnotate,[System.String]'Functions for logging comments about game behavior..')
$TabAnnotate.ToolTipText = [System.String]'Functions for logging comments about game behavior..'
$TabAnnotate.add_Enter($TabAnnotate_Enter)
#
#LabelAnnotateInfo
#
$LabelAnnotateInfo.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]6,[System.Int32]9))
$LabelAnnotateInfo.Margin = (New-Object -TypeName System.Windows.Forms.Padding -ArgumentList @([System.Int32]3,[System.Int32]6,[System.Int32]3,[System.Int32]0))
$LabelAnnotateInfo.Name = [System.String]'LabelAnnotateInfo'
$LabelAnnotateInfo.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]565,[System.Int32]54))
$LabelAnnotateInfo.TabIndex = [System.Int32]5
$LabelAnnotateInfo.Text = [System.String]'Enter a comment describing game behavior at current time.The timestamp will be reset to now when this window moves to the foreground or when cleared. See tooltips on controls for more information.'
#
#LabelTimeStamp
#
$LabelTimeStamp.Anchor = ([System.Windows.Forms.AnchorStyles][System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Left)
$LabelTimeStamp.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]9,[System.Int32]233))
$LabelTimeStamp.Margin = (New-Object -TypeName System.Windows.Forms.Padding -ArgumentList @([System.Int32]3,[System.Int32]0,[System.Int32]0,[System.Int32]0))
$LabelTimeStamp.Name = [System.String]'LabelTimeStamp'
$LabelTimeStamp.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]83,[System.Int32]23))
$LabelTimeStamp.TabIndex = [System.Int32]5
$LabelTimeStamp.Text = [System.String]'Timestamp:'
$LabelTimeStamp.TextAlign = [System.Drawing.ContentAlignment]::MiddleRight
$ToolTipDefault.SetToolTip($LabelTimeStamp,[System.String]$resources.'LabelTimeStamp.ToolTip')
#
#DateTimePickerLogDate
#
$DateTimePickerLogDate.Anchor = ([System.Windows.Forms.AnchorStyles][System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Left)
$DateTimePickerLogDate.Format = [System.Windows.Forms.DateTimePickerFormat]::Short
$DateTimePickerLogDate.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]95,[System.Int32]233))
$DateTimePickerLogDate.Name = [System.String]'DateTimePickerLogDate'
$DateTimePickerLogDate.ShowUpDown = $true
$DateTimePickerLogDate.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]121,[System.Int32]24))
$DateTimePickerLogDate.TabIndex = [System.Int32]1
$ToolTipDefault.SetToolTip($DateTimePickerLogDate,[System.String]'Date in YOUR LOCAL TIMEZONE.
Use the Clear button to reset the comment
field and the timestamp to now.')
$DateTimePickerLogDate.add_ValueChanged($DateTimePickerLogDate_ValueChanged)
#
#DateTimePickerLogTime
#
$DateTimePickerLogTime.Anchor = ([System.Windows.Forms.AnchorStyles][System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Left)
$DateTimePickerLogTime.CalendarFont = (New-Object -TypeName System.Drawing.Font -ArgumentList @([System.String]'Tahoma',[System.Single]10,[System.Drawing.FontStyle]::Regular,[System.Drawing.GraphicsUnit]::Point,([System.Byte][System.Byte]0)))
$DateTimePickerLogTime.DropDownAlign = [System.Windows.Forms.LeftRightAlignment]::Right
$DateTimePickerLogTime.Format = [System.Windows.Forms.DateTimePickerFormat]::Time
$DateTimePickerLogTime.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]222,[System.Int32]233))
$DateTimePickerLogTime.Name = [System.String]'DateTimePickerLogTime'
$DateTimePickerLogTime.ShowUpDown = $true
$DateTimePickerLogTime.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]113,[System.Int32]24))
$DateTimePickerLogTime.TabIndex = [System.Int32]2
$ToolTipDefault.SetToolTip($DateTimePickerLogTime,[System.String]'Time in YOUR LOCAL TIMEZONE.
Use the Clear button to reset the commen
 field and the timestamp to now.')
$DateTimePickerLogTime.add_ValueChanged($DateTimePickerLogTime_ValueChanged)
#
#ButtonClear
#
$ButtonClear.Anchor = ([System.Windows.Forms.AnchorStyles][System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right)
$ButtonClear.AutoSize = $true
$ButtonClear.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]341,[System.Int32]231))
$ButtonClear.Name = [System.String]'ButtonClear'
$ButtonClear.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]75,[System.Int32]27))
$ButtonClear.TabIndex = [System.Int32]3
$ButtonClear.Text = [System.String]'Clear'
$ToolTipDefault.SetToolTip($ButtonClear,[System.String]'This will clear the text box above
and also reset the timestamp to the current time.')
$ButtonClear.add_Click($ButtonClear_Click)
#
#ButtonSave
#
$ButtonSave.Anchor = ([System.Windows.Forms.AnchorStyles][System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right)
$ButtonSave.AutoSize = $true
$ButtonSave.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]422,[System.Int32]231))
$ButtonSave.Name = [System.String]'ButtonSave'
$ButtonSave.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]149,[System.Int32]27))
$ButtonSave.TabIndex = [System.Int32]4
$ButtonSave.Text = [System.String]'Save Comment'
$ToolTipDefault.SetToolTip($ButtonSave,[System.String]$resources.'ButtonSave.ToolTip')
$ButtonSave.add_Click($ButtonSave_Click)
#
#TextBoxAnnotate
#
$TextBoxAnnotate.Anchor = ([System.Windows.Forms.AnchorStyles][System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right)
$TextBoxAnnotate.Font = (New-Object -TypeName System.Drawing.Font -ArgumentList @([System.String]'Consolas',[System.Single]12,[System.Drawing.FontStyle]::Regular,[System.Drawing.GraphicsUnit]::Point,([System.Byte][System.Byte]0)))
$TextBoxAnnotate.HideSelection = $false
$TextBoxAnnotate.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]9,[System.Int32]69))
$TextBoxAnnotate.Margin = (New-Object -TypeName System.Windows.Forms.Padding -ArgumentList @([System.Int32]3,[System.Int32]6,[System.Int32]3,[System.Int32]3))
$TextBoxAnnotate.Multiline = $true
$TextBoxAnnotate.Name = [System.String]'TextBoxAnnotate'
$TextBoxAnnotate.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]559,[System.Int32]156))
$TextBoxAnnotate.TabIndex = [System.Int32]0
#
#TabReview
#
$TabReview.Controls.Add($ButtonResetLog)
$TabReview.Controls.Add($ButtonOpenReadme)
$TabReview.Controls.Add($LabelReviewInfo)
$TabReview.Controls.Add($TextBoxLog)
$TabReview.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]4,[System.Int32]22))
$TabReview.Name = [System.String]'TabReview'
$TabReview.Padding = (New-Object -TypeName System.Windows.Forms.Padding -ArgumentList @([System.Int32]3))
$TabReview.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]577,[System.Int32]270))
$TabReview.TabIndex = [System.Int32]1
$TabReview.Text = [System.String]'Review'
$TabReview.ToolTipText = [System.String]'Review the contents of the log file containing the comments added with the Annotate tab.'
$TabReview.add_Enter($TabReview_Enter)
#
#ButtonResetLog
#
$ButtonResetLog.Anchor = ([System.Windows.Forms.AnchorStyles][System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right)
$ButtonResetLog.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]294,[System.Int32]230))
$ButtonResetLog.Name = [System.String]'ButtonResetLog'
$ButtonResetLog.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]87,[System.Int32]27))
$ButtonResetLog.TabIndex = [System.Int32]1
$ButtonResetLog.Text = [System.String]'Reset Log'
$ToolTipDefault.SetToolTip($ButtonResetLog,[System.String]'Use this to erase the annotations log
and recreate it.')
$ButtonResetLog.UseVisualStyleBackColor = $true
$ButtonResetLog.add_Click($ButtonResetLog_Click)
#
#ButtonOpenReadme
#
$ButtonOpenReadme.Anchor = ([System.Windows.Forms.AnchorStyles][System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right)
$ButtonOpenReadme.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]387,[System.Int32]230))
$ButtonOpenReadme.Name = [System.String]'ButtonOpenReadme'
$ButtonOpenReadme.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]186,[System.Int32]27))
$ButtonOpenReadme.TabIndex = [System.Int32]2
$ButtonOpenReadme.Text = [System.String]'Open in Default Text Editor'
$ToolTipDefault.SetToolTip($ButtonOpenReadme,[System.String]'This will open the annotations .txt file
in the system default editor for .txt files.
On systems where the .txt editor was
never set, it will open the file in Notepad.')
$ButtonOpenReadme.UseVisualStyleBackColor = $true
$ButtonOpenReadme.add_Click($ButtonOpenReadme_Click)
#
#LabelReviewInfo
#
$LabelReviewInfo.Anchor = ([System.Windows.Forms.AnchorStyles][System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right)
$LabelReviewInfo.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]8,[System.Int32]232))
$LabelReviewInfo.Name = [System.String]'LabelReviewInfo'
$LabelReviewInfo.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]248,[System.Int32]23))
$LabelReviewInfo.TabIndex = [System.Int32]1
$LabelReviewInfo.Text = [System.String]'The above shows your comment log.'
$LabelReviewInfo.TextAlign = [System.Drawing.ContentAlignment]::MiddleLeft
#
#TextBoxLog
#
$TextBoxLog.Anchor = ([System.Windows.Forms.AnchorStyles][System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right)
$TextBoxLog.BackColor = [System.Drawing.Color]::FromArgb(([System.Int32]([System.Byte][System.Byte]40)),([System.Int32]([System.Byte][System.Byte]40)),([System.Int32]([System.Byte][System.Byte]40)))

$TextBoxLog.BorderStyle = [System.Windows.Forms.BorderStyle]::FixedSingle
$TextBoxLog.Font = (New-Object -TypeName System.Drawing.Font -ArgumentList @([System.String]'Consolas',[System.Single]12,[System.Drawing.FontStyle]::Regular,[System.Drawing.GraphicsUnit]::Point,([System.Byte][System.Byte]0)))
$TextBoxLog.ForeColor = [System.Drawing.Color]::LightGreen
$TextBoxLog.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]6,[System.Int32]6))
$TextBoxLog.MaxLength = [System.Int32]65535
$TextBoxLog.Multiline = $true
$TextBoxLog.Name = [System.String]'TextBoxLog'
$TextBoxLog.ReadOnly = $true
$TextBoxLog.ScrollBars = [System.Windows.Forms.ScrollBars]::Vertical
$TextBoxLog.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]565,[System.Int32]218))
$TextBoxLog.TabIndex = [System.Int32]0
$TextBoxLog.TabStop = $false
#
#TabArchive
#
$TabArchive.Controls.Add($ButtonLaunch)
$TabArchive.Controls.Add($ButtonSetOutputDir)
$TabArchive.Controls.Add($ButtonSetScreenshotsDir)
$TabArchive.Controls.Add($ButtonSetGameDir)
$TabArchive.Controls.Add($CheckBoxNoResetReadme)
$TabArchive.Controls.Add($LabelOutputDirLabel)
$TabArchive.Controls.Add($LabelGameDirLabel)
$TabArchive.Controls.Add($LabelOutputDirPath)
$TabArchive.Controls.Add($CheckBoxIncludeSS)
$TabArchive.Controls.Add($LabelDvGameDirPath)
$TabArchive.Controls.Add($LabelScreenShotsDirPath)
$TabArchive.Controls.Add($LabelArchiveInfoText)
$TabArchive.Controls.Add($ButtonArchive)
$TabArchive.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]4,[System.Int32]25))
$TabArchive.Name = [System.String]'TabArchive'
$TabArchive.Padding = (New-Object -TypeName System.Windows.Forms.Padding -ArgumentList @([System.Int32]8))
$TabArchive.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]577,[System.Int32]267))
$TabArchive.TabIndex = [System.Int32]2
$TabArchive.Text = [System.String]'Archive'
$TabArchive.ToolTipText = [System.String]'Functions for archiving the game data directory along with the log files, comments, save game data, and optionally screenshots.'
#
#ButtonSetOutputDir
#
$ButtonSetOutputDir.Font = (New-Object -TypeName System.Drawing.Font -ArgumentList @([System.String]'Tahoma',[System.Single]12,[System.Drawing.FontStyle]::Regular,[System.Drawing.GraphicsUnit]::Point,([System.Byte][System.Byte]0)))
$ButtonSetOutputDir.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]135,[System.Int32]134))
$ButtonSetOutputDir.Name = [System.String]'ButtonSetOutputDir'
$ButtonSetOutputDir.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]30,[System.Int32]30))
$ButtonSetOutputDir.TabIndex = [System.Int32]12
$ButtonSetOutputDir.Text = [System.String]'>'
$ButtonSetOutputDir.UseVisualStyleBackColor = $true
$ButtonSetOutputDir.add_Click($ButtonSetOutputDir_Click)
#
#ButtonSetScreenshotsDir
#
$ButtonSetScreenshotsDir.Font = (New-Object -TypeName System.Drawing.Font -ArgumentList @([System.String]'Tahoma',[System.Single]12,[System.Drawing.FontStyle]::Regular,[System.Drawing.GraphicsUnit]::Point,([System.Byte][System.Byte]0)))
$ButtonSetScreenshotsDir.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]36,[System.Int32]87))
$ButtonSetScreenshotsDir.Name = [System.String]'ButtonSetScreenshotsDir'
$ButtonSetScreenshotsDir.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]30,[System.Int32]30))
$ButtonSetScreenshotsDir.TabIndex = [System.Int32]11
$ButtonSetScreenshotsDir.Text = [System.String]'>'
$ButtonSetScreenshotsDir.UseVisualStyleBackColor = $true
$ButtonSetScreenshotsDir.add_Click($ButtonSetScreenshotsDir_Click)
#
#ButtonSetGameDir
#
$ButtonSetGameDir.Font = (New-Object -TypeName System.Drawing.Font -ArgumentList @([System.String]'Tahoma',[System.Single]12,[System.Drawing.FontStyle]::Regular,[System.Drawing.GraphicsUnit]::Point,([System.Byte][System.Byte]0)))
$ButtonSetGameDir.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]135,[System.Int32]23))
$ButtonSetGameDir.Name = [System.String]'ButtonSetGameDir'
$ButtonSetGameDir.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]30,[System.Int32]30))
$ButtonSetGameDir.TabIndex = [System.Int32]10
$ButtonSetGameDir.Text = [System.String]'>'
$ButtonSetGameDir.UseVisualStyleBackColor = $true
$ButtonSetGameDir.add_Click($ButtonSetGameDir_Click)
#
#CheckBoxNoResetReadme
#
$CheckBoxNoResetReadme.Font = (New-Object -TypeName System.Drawing.Font -ArgumentList @([System.String]'Tahoma',[System.Single]10,[System.Drawing.FontStyle]::Bold,[System.Drawing.GraphicsUnit]::Point,([System.Byte][System.Byte]0)))
$CheckBoxNoResetReadme.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]12,[System.Int32]170))
$CheckBoxNoResetReadme.Name = [System.String]'CheckBoxNoResetReadme'
$CheckBoxNoResetReadme.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]383,[System.Int32]24))
$CheckBoxNoResetReadme.TabIndex = [System.Int32]9
$CheckBoxNoResetReadme.Text = [System.String]'Don''t reset the annotations log after archiving'
$ToolTipDefault.SetToolTip($CheckBoxNoResetReadme,[System.String]'The annotations log in your game directory is normally
cleared and recreated after creating an archive. This
allows you to retain it if you want.')
$CheckBoxNoResetReadme.UseVisualStyleBackColor = $true
$CheckBoxNoResetReadme.add_CheckedChanged($CheckBoxNoResetReadme_CheckedChanged)
$CheckBoxNoResetReadme.add_VisibleChanged($CheckBoxNoResetReadme_VisibleChanged)
#
#LabelOutputDirLabel
#
$LabelOutputDirLabel.Font = (New-Object -TypeName System.Drawing.Font -ArgumentList @([System.String]'Tahoma',[System.Single]10,[System.Drawing.FontStyle]::Bold,[System.Drawing.GraphicsUnit]::Point,([System.Byte][System.Byte]0)))
$LabelOutputDirLabel.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]12,[System.Int32]127))
$LabelOutputDirLabel.Name = [System.String]'LabelOutputDirLabel'
$LabelOutputDirLabel.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]117,[System.Int32]42))
$LabelOutputDirLabel.TabIndex = [System.Int32]8
$LabelOutputDirLabel.Text = [System.String]'Zip File Output Directory:'
$LabelOutputDirLabel.TextAlign = [System.Drawing.ContentAlignment]::MiddleRight
#
#LabelGameDirLabel
#
$LabelGameDirLabel.Font = (New-Object -TypeName System.Drawing.Font -ArgumentList @([System.String]'Tahoma',[System.Single]10,[System.Drawing.FontStyle]::Bold,[System.Drawing.GraphicsUnit]::Point,([System.Byte][System.Byte]0)))
$LabelGameDirLabel.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]12,[System.Int32]19))
$LabelGameDirLabel.Name = [System.String]'LabelGameDirLabel'
$LabelGameDirLabel.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]117,[System.Int32]42))
$LabelGameDirLabel.TabIndex = [System.Int32]7
$LabelGameDirLabel.Text = [System.String]'Delta V Game Data Directory:'
$LabelGameDirLabel.TextAlign = [System.Drawing.ContentAlignment]::MiddleRight
#
#LabelOutputDirPath
#
$LabelOutputDirPath.Anchor = ([System.Windows.Forms.AnchorStyles][System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right)
$LabelOutputDirPath.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]171,[System.Int32]127))
$LabelOutputDirPath.Name = [System.String]'LabelOutputDirPath'
$LabelOutputDirPath.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]280,[System.Int32]42))
$LabelOutputDirPath.TabIndex = [System.Int32]0
$LabelOutputDirPath.Text = [System.String]'outputDir'
$LabelOutputDirPath.TextAlign = [System.Drawing.ContentAlignment]::MiddleLeft
$ToolTipDefault.SetToolTip($LabelOutputDirPath,[System.String]'Double-click this to open the directory containing the output ZIP file.')
$LabelOutputDirPath.add_VisibleChanged($LabelOutputDirPath_VisibleChanged)
$LabelOutputDirPath.add_DoubleClick($LabelOutputDirPath_DoubleClick)
#
#CheckBoxIncludeSS
#
$CheckBoxIncludeSS.Checked = $true
$CheckBoxIncludeSS.CheckState = [System.Windows.Forms.CheckState]::Checked
$CheckBoxIncludeSS.Font = (New-Object -TypeName System.Drawing.Font -ArgumentList @([System.String]'Tahoma',[System.Single]10,[System.Drawing.FontStyle]::Bold,[System.Drawing.GraphicsUnit]::Point,([System.Byte][System.Byte]0)))
$CheckBoxIncludeSS.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]12,[System.Int32]64))
$CheckBoxIncludeSS.Name = [System.String]'CheckBoxIncludeSS'
$CheckBoxIncludeSS.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]413,[System.Int32]24))
$CheckBoxIncludeSS.TabIndex = [System.Int32]3
$CheckBoxIncludeSS.Text = [System.String]'Include recent screenshots from the following folder:'
$ToolTipDefault.SetToolTip($CheckBoxIncludeSS,[System.String]'Screenshots are included by default if the directory can
be found, but this can be disabled if desired.')
$CheckBoxIncludeSS.UseVisualStyleBackColor = $true
$CheckBoxIncludeSS.add_CheckedChanged($CheckBoxIncludeSS_CheckedChanged)
$CheckBoxIncludeSS.add_VisibleChanged($CheckBoxIncludeSS_VisibleChanged)
#
#LabelDvGameDirPath
#
$LabelDvGameDirPath.Anchor = ([System.Windows.Forms.AnchorStyles][System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right)
$LabelDvGameDirPath.AutoEllipsis = $true
$LabelDvGameDirPath.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]171,[System.Int32]19))
$LabelDvGameDirPath.Name = [System.String]'LabelDvGameDirPath'
$LabelDvGameDirPath.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]396,[System.Int32]42))
$LabelDvGameDirPath.TabIndex = [System.Int32]1
$LabelDvGameDirPath.Text = [System.String]'dvGameDir'
$LabelDvGameDirPath.TextAlign = [System.Drawing.ContentAlignment]::MiddleLeft
$ToolTipDefault.SetToolTip($LabelDvGameDirPath,[System.String]'This is the data directory for the game.
Double click the pathname to open the
directory as a folder in a Windows
Explorer window.')
$LabelDvGameDirPath.add_VisibleChanged($LabelDvGameDirPath_VisibleChanged)
$LabelDvGameDirPath.add_DoubleClick($LabelDvGameDirPath_DoubleClick)
#
#LabelScreenShotsDirPath
#
$LabelScreenShotsDirPath.Anchor = ([System.Windows.Forms.AnchorStyles][System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right)
$LabelScreenShotsDirPath.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]72,[System.Int32]87))
$LabelScreenShotsDirPath.Name = [System.String]'LabelScreenShotsDirPath'
$LabelScreenShotsDirPath.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]494,[System.Int32]36))
$LabelScreenShotsDirPath.TabIndex = [System.Int32]4
$LabelScreenShotsDirPath.Text = [System.String]'dvScreenShotsDir'
$ToolTipDefault.SetToolTip($LabelScreenShotsDirPath,[System.String]$resources.'LabelScreenShotsDirPath.ToolTip')
$LabelScreenShotsDirPath.add_VisibleChanged($LabelScreenShotsDirPath_VisibleChanged)
$LabelScreenShotsDirPath.add_DoubleClick($LabelScreenShotsDirPath_DoubleClick)
#
#LabelArchiveInfoText
#
$LabelArchiveInfoText.Anchor = ([System.Windows.Forms.AnchorStyles][System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Left)
$LabelArchiveInfoText.BackColor = [System.Drawing.Color]::Transparent
$LabelArchiveInfoText.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]8,[System.Int32]197))
$LabelArchiveInfoText.Name = [System.String]'LabelArchiveInfoText'
$LabelArchiveInfoText.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]384,[System.Int32]59))
$LabelArchiveInfoText.TabIndex = [System.Int32]6
$LabelArchiveInfoText.Text = [System.String]'Double-click any pathname above to open the directory in an explorer window. The pathnames can be changed using the associated buttons.'
$LabelArchiveInfoText.TextAlign = [System.Drawing.ContentAlignment]::MiddleLeft
#
#ButtonArchive
#
$ButtonArchive.Anchor = ([System.Windows.Forms.AnchorStyles][System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right)
$ButtonArchive.AutoSize = $true
$ButtonArchive.BackColor = [System.Drawing.Color]::Black
$ButtonArchive.FlatAppearance.BorderColor = [System.Drawing.Color]::Green
$ButtonArchive.FlatAppearance.BorderSize = [System.Int32]3
$ButtonArchive.FlatAppearance.MouseDownBackColor = [System.Drawing.Color]::Yellow
$ButtonArchive.FlatAppearance.MouseOverBackColor = [System.Drawing.Color]::FromArgb(([System.Int32]([System.Byte][System.Byte]64)),([System.Int32]([System.Byte][System.Byte]64)),([System.Int32]([System.Byte][System.Byte]64)))

$ButtonArchive.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$ButtonArchive.Font = (New-Object -TypeName System.Drawing.Font -ArgumentList @([System.String]'Segoe UI',[System.Single]12,[System.Drawing.FontStyle]::Bold,[System.Drawing.GraphicsUnit]::Point,([System.Byte][System.Byte]0)))
$ButtonArchive.ForeColor = [System.Drawing.Color]::Lime
$ButtonArchive.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]415,[System.Int32]196))
$ButtonArchive.Name = [System.String]'ButtonArchive'
$ButtonArchive.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]151,[System.Int32]56))
$ButtonArchive.TabIndex = [System.Int32]20
$ButtonArchive.Text = [System.String]'Create Archive'
$ToolTipDefault.SetToolTip($ButtonArchive,[System.String]$resources.'ButtonArchive.ToolTip')
$ButtonArchive.UseMnemonic = $false
$ButtonArchive.UseVisualStyleBackColor = $false
$ButtonArchive.add_Click($ButtonArchive_Click)
#
#StatusStrip1
#
$StatusStrip1.GripStyle = [System.Windows.Forms.ToolStripGripStyle]::Visible
$StatusStrip1.Items.AddRange([System.Windows.Forms.ToolStripItem[]]@($ToolStripStatusLabel1))
$StatusStrip1.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]0,[System.Int32]299))
$StatusStrip1.Name = [System.String]'StatusStrip1'
$StatusStrip1.ShowItemToolTips = $true
$StatusStrip1.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]584,[System.Int32]22))
$StatusStrip1.TabIndex = [System.Int32]1
$StatusStrip1.Text = [System.String]'StatusStrip1'
#
#ToolStripStatusLabel1
#
$ToolStripStatusLabel1.AutoToolTip = $true
$ToolStripStatusLabel1.DisplayStyle = [System.Windows.Forms.ToolStripItemDisplayStyle]::Text
$ToolStripStatusLabel1.Name = [System.String]'ToolStripStatusLabel1'
$ToolStripStatusLabel1.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]569,[System.Int32]17))
$ToolStripStatusLabel1.Spring = $true
$ToolStripStatusLabel1.Text = [System.String]'Status messages should appear here.'
$ToolStripStatusLabel1.TextAlign = [System.Drawing.ContentAlignment]::MiddleLeft
#
#ButtonLaunch
#
$ButtonLaunch.Anchor = ([System.Windows.Forms.AnchorStyles][System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right)
$ButtonLaunch.BackColor = [System.Drawing.Color]::Black
$ButtonLaunch.FlatAppearance.BorderColor = [System.Drawing.Color]::Yellow
$ButtonLaunch.FlatAppearance.BorderSize = [System.Int32]2
$ButtonLaunch.FlatAppearance.MouseDownBackColor = [System.Drawing.Color]::Gray
$ButtonLaunch.FlatAppearance.MouseOverBackColor = [System.Drawing.Color]::FromArgb(([System.Int32]([System.Byte][System.Byte]64)),([System.Int32]([System.Byte][System.Byte]64)),([System.Int32]([System.Byte][System.Byte]64)))

$ButtonLaunch.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$ButtonLaunch.ForeColor = [System.Drawing.Color]::Yellow
$ButtonLaunch.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]457,[System.Int32]127))
$ButtonLaunch.Name = [System.String]'ButtonLaunch'
$ButtonLaunch.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]109,[System.Int32]56))
$ButtonLaunch.TabIndex = [System.Int32]21
$ButtonLaunch.Text = [System.String]'Launch ΔV'
$ToolTipDefault.SetToolTip($ButtonLaunch,[System.String]'As a convenience, this will launch the game for you,
but it isn''t necessary to use this.

After launching the game, just use Alt+Tab to switch to
the logging utility.')
$ButtonLaunch.UseMnemonic = $false
$ButtonLaunch.UseVisualStyleBackColor = $false
$ButtonLaunch.add_Click($ButtonLaunch_Click)
#
#FormTop
#
$FormTop.AcceptButton = $ButtonSave
$FormTop.ClientSize = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]584,[System.Int32]321))
$FormTop.Controls.Add($StatusStrip1)
$FormTop.Controls.Add($TabControlTop)
$FormTop.Font = (New-Object -TypeName System.Drawing.Font -ArgumentList @([System.String]'Tahoma',[System.Single]10,[System.Drawing.FontStyle]::Regular,[System.Drawing.GraphicsUnit]::Point,([System.Byte][System.Byte]0)))
$FormTop.ForeColor = [System.Drawing.SystemColors]::WindowText
$FormTop.MaximizeBox = $false
$FormTop.MaximumSize = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]1024,[System.Int32]768))
$FormTop.MinimumSize = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]600,[System.Int32]360))
$FormTop.SizeGripStyle = [System.Windows.Forms.SizeGripStyle]::Show
$FormTop.StartPosition = [System.Windows.Forms.FormStartPosition]::CenterScreen
$FormTop.Text = [System.String]'dv-annotate ($Version)'
$FormTop.add_Activated($FormTop_Activated)
$TabControlTop.ResumeLayout($false)
$TabAnnotate.ResumeLayout($false)
$TabAnnotate.PerformLayout()
$TabReview.ResumeLayout($false)
$TabReview.PerformLayout()
$TabArchive.ResumeLayout($false)
$TabArchive.PerformLayout()
$StatusStrip1.ResumeLayout($false)
$StatusStrip1.PerformLayout()
$FormTop.ResumeLayout($false)
$FormTop.PerformLayout()
Add-Member -InputObject $FormTop -Name TabControlTop -Value $TabControlTop -MemberType NoteProperty
Add-Member -InputObject $FormTop -Name TabAnnotate -Value $TabAnnotate -MemberType NoteProperty
Add-Member -InputObject $FormTop -Name LabelAnnotateInfo -Value $LabelAnnotateInfo -MemberType NoteProperty
Add-Member -InputObject $FormTop -Name LabelTimeStamp -Value $LabelTimeStamp -MemberType NoteProperty
Add-Member -InputObject $FormTop -Name ToolTipDefault -Value $ToolTipDefault -MemberType NoteProperty
Add-Member -InputObject $FormTop -Name components -Value $components -MemberType NoteProperty
Add-Member -InputObject $FormTop -Name DateTimePickerLogDate -Value $DateTimePickerLogDate -MemberType NoteProperty
Add-Member -InputObject $FormTop -Name DateTimePickerLogTime -Value $DateTimePickerLogTime -MemberType NoteProperty
Add-Member -InputObject $FormTop -Name ButtonClear -Value $ButtonClear -MemberType NoteProperty
Add-Member -InputObject $FormTop -Name ButtonSave -Value $ButtonSave -MemberType NoteProperty
Add-Member -InputObject $FormTop -Name TextBoxAnnotate -Value $TextBoxAnnotate -MemberType NoteProperty
Add-Member -InputObject $FormTop -Name TabReview -Value $TabReview -MemberType NoteProperty
Add-Member -InputObject $FormTop -Name ButtonResetLog -Value $ButtonResetLog -MemberType NoteProperty
Add-Member -InputObject $FormTop -Name ButtonOpenReadme -Value $ButtonOpenReadme -MemberType NoteProperty
Add-Member -InputObject $FormTop -Name LabelReviewInfo -Value $LabelReviewInfo -MemberType NoteProperty
Add-Member -InputObject $FormTop -Name TextBoxLog -Value $TextBoxLog -MemberType NoteProperty
Add-Member -InputObject $FormTop -Name TabArchive -Value $TabArchive -MemberType NoteProperty
Add-Member -InputObject $FormTop -Name ButtonLaunch -Value $ButtonLaunch -MemberType NoteProperty
Add-Member -InputObject $FormTop -Name ButtonSetOutputDir -Value $ButtonSetOutputDir -MemberType NoteProperty
Add-Member -InputObject $FormTop -Name ButtonSetScreenshotsDir -Value $ButtonSetScreenshotsDir -MemberType NoteProperty
Add-Member -InputObject $FormTop -Name ButtonSetGameDir -Value $ButtonSetGameDir -MemberType NoteProperty
Add-Member -InputObject $FormTop -Name CheckBoxNoResetReadme -Value $CheckBoxNoResetReadme -MemberType NoteProperty
Add-Member -InputObject $FormTop -Name LabelOutputDirLabel -Value $LabelOutputDirLabel -MemberType NoteProperty
Add-Member -InputObject $FormTop -Name LabelGameDirLabel -Value $LabelGameDirLabel -MemberType NoteProperty
Add-Member -InputObject $FormTop -Name LabelOutputDirPath -Value $LabelOutputDirPath -MemberType NoteProperty
Add-Member -InputObject $FormTop -Name CheckBoxIncludeSS -Value $CheckBoxIncludeSS -MemberType NoteProperty
Add-Member -InputObject $FormTop -Name LabelDvGameDirPath -Value $LabelDvGameDirPath -MemberType NoteProperty
Add-Member -InputObject $FormTop -Name LabelScreenShotsDirPath -Value $LabelScreenShotsDirPath -MemberType NoteProperty
Add-Member -InputObject $FormTop -Name LabelArchiveInfoText -Value $LabelArchiveInfoText -MemberType NoteProperty
Add-Member -InputObject $FormTop -Name ButtonArchive -Value $ButtonArchive -MemberType NoteProperty
Add-Member -InputObject $FormTop -Name StatusStrip1 -Value $StatusStrip1 -MemberType NoteProperty
Add-Member -InputObject $FormTop -Name ToolStripStatusLabel1 -Value $ToolStripStatusLabel1 -MemberType NoteProperty
Add-Member -InputObject $FormTop -Name FolderBrowserDialog1 -Value $FolderBrowserDialog1 -MemberType NoteProperty
}
. InitializeComponent


# Override form designer.
$FormTop.Text = "dV-annotate: Delta V Log Utility (${Version})"

# Load the preferences file here.
LoadOrCreatePrefsFile

<##
### Finally, display the main window.
##>
$FormTop.ShowDialog()
Write-Debug 'Main window closed. Exiting.'