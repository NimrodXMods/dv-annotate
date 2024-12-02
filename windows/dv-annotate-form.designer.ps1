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
$resources = . (Join-Path $PSScriptRoot 'dv-annotate-form.resources.ps1')
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
