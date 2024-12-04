# Installing

## Download

1. Download `dv-annotate.ps1` to any directory you normally download files to, such as your Windows user Downloads directory. This can be done by clicking the file `dv-annotate.ps1` above and selecting the download icon in the upper right of the frame where it says "Raw".

1. Open a file explorer window and browse to the directory you downloaded the file to.

1. (Optional) You might want to open the `.ps1` file in a text editor to inspect it for anything suspicious. The whole script is human-readable and nothing is obfuscated.

## Install

1. In the Windows explorer, right-click on the downloaded file `dv-annotate.ps1` and select "Run with PowerShell".

1. A console window will appear which will ask you to confirm the installation and will tell you what it copied where. This is a "Lightweight Install" process that just copies the file to `%APPDATA%\dV-annotate` and creates a shortcut for you to run it. On Windows 10 or later, this should work without installing any additional software.

1. Once this is done the `dv-annotate.ps1` script will disappear from the download directory (it got moved to `%APPDATA%\dV-annotate`) and a shortcut will appear in the download directory.

1. Double-click the shortcut to run the utility. The GUI window will appear.

1. The shortcut can be moved to any location you want and will still work, so this is a good time to move the shortcut to the desktop or wherever you want to put it.

## Uninstall

Just delete the `%APPDATA%\dV-annotate` folder and the shortcut.