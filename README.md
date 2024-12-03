# dv-annotate

Annotate save games and logs for the game Delta V: Rings of Saturn.

See [the wiki article here](https://delta-v.kodera.pl/index.php/DV_Annotate) for more info.

This repo contains two different "dv-annotate" tools: one GUI-based utility for Windows, and one package of simple bash scripts for Linux/SteamOS/OSX. These are for keeping notes on when problems happen (annotations) and creating a zip or tgz archive of the game data directory to aid in debugging.

## Windows

In `windows\build\dv-annotate.ps1` is a human-readable script for Windows Powershell 5.1 (the powershell.exe that ships with Windows 10). This can be installed by right-clicking on the file after downloading and selecting "Run with PowerShell". You will be asked to confirm before the script is copied.

## SteamOS, Linux, OSX

In the `bash-steamos-linux-osx` directory are some very simple and crude bash scripts that do the same as the above, but with no GUI or anything fancy.

## More Info

See [the wiki](https://delta-v.kodera.pl/index.php/DV_Annotate) and the [dV discord](https://discord.gg/dv) for more info or to ask questions or report problems.