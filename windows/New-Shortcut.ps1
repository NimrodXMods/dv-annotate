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