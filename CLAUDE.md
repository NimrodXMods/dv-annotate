# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

Tools for players of the game *Delta V: Rings of Saturn* (Steam app ID `846030`) to write timestamped annotations while playing, then archive the game data directory (saves, debug logs, the annotations file, and recent screenshots) into a zip/tgz to send to the developer for bug reports. User docs live on the wiki: https://delta-v.kodera.pl/index.php/DV_Annotate

There are two independent implementations that share no code:

- `windows/` — the main product: a Windows Forms GUI written in PowerShell.
- `bash-steamos-linux-osx/` — minimal CLI shell scripts (no GUI, no installer), mostly for the author's own Steam Deck use.

## Windows (PowerShell GUI)

**Target runtime is Windows PowerShell 5.1** (`powershell.exe`, `#Requires -Version 5.1`), not PowerShell 7. Don't use pwsh-only syntax (`??`, `?.`, ternary, `&&`/`||`, `-Parallel`, etc.). Source files carry a UTF-8 BOM. Keep it that way so 5.1 reads non-ASCII correctly.

### Source layout and load order

The app is assembled by dot-sourcing at runtime, relative to `$PSScriptRoot`:

1. `dv-annotate.ps1` is the entry point and holds `$Version`. It defines prefs handling, the installer, readme/annotation-log functions, zip archiving, and game launch. It dot-sources `New-Shortcut.ps1` (twice, currently) and finally `dv-annotate-form.ps1`.
2. `dv-annotate-form.ps1` defines the event-handler scriptblocks (`$ButtonSave_Click`, `$TabReview_Enter`, …), loads WinForms assemblies, dot-sources the designer file, calls `LoadOrCreatePrefsFile`, then `$FormTop.ShowDialog()`.
3. `dv-annotate-form.designer.ps1` and `dv-annotate-form.resources.ps1` are **tool-generated** by a PowerShell WinForms designer (PowerShell Pro Tools style). The designer wires controls to handlers by variable name (`$ButtonSave.add_Click($ButtonSave_Click)`), so a handler must exist as a variable with exactly that `$<ControlName>_<Event>` name *before* the designer file is dot-sourced. Avoid hand-editing the designer/resources files beyond small tweaks. Prefer overriding properties after the designer runs (as is done for `$FormTop.Text`).

All functions and handlers share script scope. Handlers reach `$prefs` and the form controls as script-level variables.

### Build (single-file bundle)

`windows/build/dv-annotate.ps1` is the distributable: every dot-sourced file inlined into one script, which users download directly from GitHub. Rebuild it with:

```powershell
windows/Build-Bundle.ps1
```

It recursively inlines each `. (Join-Path $PSScriptRoot '…')` line and writes UTF-8 with BOM. It replaces PowerShell Pro Tools' `Merge-Script`, which produced earlier bundles from `windows/package.psd1` and is not installed here. The bundle is committed to git. After changing source files, bump `$Version` in `dv-annotate.ps1`, rebuild, and commit the bundle with the source change.

### Installer (Inno Setup)

```powershell
windows/installer/Build-Installer.ps1
```

This reads `$Version` from `windows/dv-annotate.ps1`, rebuilds the bundle with `Build-Bundle.ps1`, then compiles `windows/installer/dv-annotate.iss` with Inno Setup 6 (`ISCC.exe`) into `windows/installer/Output/dv-annotate-setup-<ver>.exe`. It finds `ISCC.exe` on PATH or in the default Inno Setup locations, or you can pass `-IsccPath`. The installer is per-user (no admin): it installs to `%APPDATA%\dV-annotate`, adds a "dV Annotate" Start Menu shortcut and an optional desktop shortcut, and is uninstalled from Windows Settings > Apps. Uninstall keeps `prefs.json`. The exe is unsigned, so SmartScreen shows "Windows protected your PC" on first run; users click "More info" then "Run anyway".

### Release

1. Bump `$Version` in `windows/dv-annotate.ps1`.
2. Run `windows/Build-Bundle.ps1` so `windows/build/dv-annotate.ps1` matches the source.
3. Commit the source change together with the rebuilt bundle.
4. Tag the commit `vX.Y.Z` (matching `$Version`) and run `git push origin vX.Y.Z`.

Pushing the tag runs `.github/workflows/release.yml`, which builds the installer, attests build provenance, and publishes a GitHub Release with `dv-annotate-setup-X.Y.Z.exe` and `dv-annotate.ps1`. CI fails on a stale bundle: `build.yml` rebuilds the bundle and fails if it differs from the committed `windows/build/dv-annotate.ps1`. `release.yml` fails if the tag does not equal `$Version`.

Verification commands for users are in `windows/build/README.md`.

### Lint

```powershell
Invoke-ScriptAnalyzer -Path windows -Settings windows/PSScriptAnalyzerSettings.psd1
```

The settings enable all rules except `PSUseDeclaredVarsMoreThanAssignments` and `PSAvoidGlobalVars`. Those two are excluded because handlers and controls are cross-file script-scope variables.

There are no automated tests.

### Running / the self-install gotcha

At startup the script checks `if ($PSScriptRoot -ine $dataDir) { LightweightInstall }`, where `$dataDir` is `%APPDATA%\dV-annotate`. Running from anywhere else triggers the "Lightweight Install". It prompts y/n, then **moves** (`Move-Item`) the running script into `%APPDATA%\dV-annotate\` and creates a `dV Annotate.lnk` shortcut next to where it was run. Consequences:

- Running `windows/dv-annotate.ps1` from the repo and answering `y` moves the source file out of the repo. Answer `n` (exits), or test the built bundle from a scratch copy.
- The installer only moves the single script file, so only the merged bundle works as an installed app. The multi-file source tree does not. (This is the script's own self-install. It is separate from the Inno Setup installer described above.)
- Never run `windows/installer/Test-Installer.ps1` locally. It refuses to run outside GitHub Actions because it installs and uninstalls into the real `%APPDATA%\dV-annotate`.

The GUI needs an interactive desktop session, so it can't be meaningfully exercised headlessly.

### Runtime data and behavior worth knowing

- Prefs: `%APPDATA%\dV-annotate\prefs.json`, created from `$defaultPrefs` on first run. Missing keys added in later versions are patched in by `LoadOrCreatePrefsFile`. Follow that pattern when adding a new pref so old prefs files keep working.
- Game data dir defaults to `%APPDATA%\dV`. Annotations go to `_README.txt` there, one line per entry: `[yyyy/MM/dd HH:mm:ss] -- comment [latest-screenshot]`.
- The screenshots dir is auto-discovered as `<Steam>\userdata\<most-recent-user>\760\remote\846030\screenshots`, falling back to `%USERPROFILE%\Pictures\dV-annotate`.
- "Recent" screenshots means screenshots newer than the annotation file's **creation time**. `ResetReadme` deletes and recreates the file, which resets that window.
- Archiving copies the game dir to `%TEMP%\<guid>.tmp`, adds `_screenshots/`, and zips to `outputDir` (default Downloads) as `dV-Log-<timestamp>.zip`. It then optionally resets the annotation log.
- Game launch finds the install path via the `HKLM\...\Uninstall` registry entry whose DisplayName matches `?V: Rings of Saturn`, then runs `Delta-V.exe`.

## Bash scripts (SteamOS/Linux/macOS)

Each script sources its config from **`~/dv-archive.include.sh`** (the home directory, not the script directory). That file holds a hardcoded `steamid`, `archivetag`, and paths that default to SteamOS locations (`~/.local/share/dV`). `dv-archive.sh` writes a `.tgz` of `~/.local/share/dV` and then clears the `_README` annotations file. The scripts use GNU `find -printf`/`-newermt`, so they need adjustment for macOS.
