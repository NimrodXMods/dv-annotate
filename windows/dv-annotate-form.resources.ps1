& { $BinaryFormatter = New-Object -TypeName System.Runtime.Serialization.Formatters.Binary.BinaryFormatter
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