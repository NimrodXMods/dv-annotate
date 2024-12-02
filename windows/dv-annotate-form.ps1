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
. (Join-Path $PSScriptRoot 'dv-annotate-form.designer.ps1')

# Override form designer.
$FormTop.Text = "dV-annotate: Delta V Log Utility (${Version})"

# Load the preferences file here.
LoadOrCreatePrefsFile

<##
### Finally, display the main window.
##>
$FormTop.ShowDialog()
Write-Debug 'Main window closed. Exiting.'