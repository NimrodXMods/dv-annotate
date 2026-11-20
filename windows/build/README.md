# Installing

## Option 1: Installer (recommended)

1. Go to the [latest release](https://github.com/NimrodXMods/dv-annotate/releases/latest) and download the file named `dv-annotate-setup-X.Y.Z.exe` (the numbers change with each version). It is listed under "Assets".

1. Double-click the downloaded file to run it. It installs just for your Windows user account, so you do not need to be an administrator.

1. Windows may show a blue box that says "Windows protected your PC". This happens because the installer is not digitally signed yet, not because anything is wrong with it. Only continue if you downloaded the file from the release page above. Click "More info", then click "Run anyway".

1. Follow the steps. You can choose whether to also add a desktop shortcut. The program is installed to `%APPDATA%\dV-annotate` and a "dV Annotate" entry is added to the Start Menu.

1. Open "dV Annotate" from the Start Menu (or from the desktop shortcut, if you chose one).

### Uninstall

Open Windows Settings, go to Apps > Installed apps (on Windows 10: Apps & features), find "dV Annotate", and choose Uninstall. Your saved settings file (`prefs.json`) is kept.

### Verifying the download (optional)

If you want to confirm the installer really came from this project, you can check it with the [GitHub CLI](https://cli.github.com/) (`gh`). The `gh` checks need the GitHub CLI installed and a one-time `gh auth login` (sign in to GitHub). Open PowerShell in the folder you downloaded the file to and run these two commands, replacing `X.Y.Z` with the version number in the file name (and `vX.Y.Z` with the same version, with a `v` in front):

```
gh attestation verify dv-annotate-setup-X.Y.Z.exe -R NimrodXMods/dv-annotate
gh release verify-asset vX.Y.Z dv-annotate-setup-X.Y.Z.exe -R NimrodXMods/dv-annotate
```

Both should report that the file is verified. If either one fails, do not run the installer. Ask on the [dV discord](https://discord.gg/dv) `#workshop` channel instead.

## Option 2: The script only (alternative)

This route skips the installer. It is a single script file that moves itself into place the first time you run it.

1. Download `dv-annotate.ps1` to any directory you normally download files to, such as your Windows user Downloads directory. This can be done by clicking the file `dv-annotate.ps1` above and selecting the download icon in the upper right of the frame where it says "Raw". You can also download it from the same [latest release](https://github.com/NimrodXMods/dv-annotate/releases/latest).

1. Open a file explorer window and browse to the directory you downloaded the file to.

1. (Optional) You might want to open the `.ps1` file in a text editor to inspect it for anything suspicious. The whole script is human-readable and nothing is obfuscated.

1. In the Windows explorer, right-click on the downloaded file `dv-annotate.ps1` and select "Run with PowerShell".

1. A console window will appear which will ask you to confirm the installation and will tell you what it copied where. This is a "Lightweight Install" process that just moves the file to `%APPDATA%\dV-annotate` and creates a shortcut for you to run it. On Windows 10 or later, this should work without installing any additional software.

1. Once this is done the `dv-annotate.ps1` script will disappear from the download directory (it got moved to `%APPDATA%\dV-annotate`) and a shortcut will appear in the download directory.

1. Double-click the shortcut to run the utility. The GUI window will appear.

1. The shortcut can be moved to any location you want and will still work, so this is a good time to move the shortcut to the desktop or wherever you want to put it.

### Uninstall (script only)

Just delete the `%APPDATA%\dV-annotate` folder and the shortcut.
