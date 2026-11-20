# Inno Setup Installer + CI Release Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Ship dv-annotate as a per-user `setup.exe` built by GitHub Actions and attached to a GitHub Release with a build-provenance attestation, so users no longer hit PowerShell execution-policy problems.

**Architecture:** `windows/Build-Bundle.ps1` produces the single-file script as today. A new Inno Setup script packages that bundle into `dv-annotate-setup-<version>.exe`, installing to `%APPDATA%\dV-annotate` (the directory the script already treats as "installed", so its self-installer never triggers). One workflow builds and checks on every push/PR; on a `v*` tag it also attests the artifacts and publishes the release.

**Tech Stack:** Windows PowerShell 5.1, Inno Setup 6 (`ISCC.exe`), PSScriptAnalyzer, GitHub Actions (`windows-latest`), `actions/attest-build-provenance`, `gh` CLI.

**Spec:** No separate spec. Requirements come from the 2026-11-20 Claude Code session and are captured in Global Constraints below.

## Global Constraints

- Target runtime stays Windows PowerShell 5.1; no pwsh-only syntax in shipped code.
- Install must not require admin: `PrivilegesRequired=lowest`.
- Install directory must be exactly `{userappdata}\dV-annotate`, matching `$dataDir` in `windows/dv-annotate.ps1`. Otherwise the script runs `LightweightInstall` on first launch.
- Shortcut target: `%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe`. Arguments: `-NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File "{app}\dv-annotate.ps1"`. Icon: `%SystemRoot%\System32\SHELL32.dll,269`. Name: `dV Annotate`.
- Uninstall removes the installed script and shortcuts but leaves `prefs.json` (user data).
- Version has one source of truth, `$Version` in `windows/dv-annotate.ps1`. A release tag `vX.Y.Z` must equal it, or the release job fails.
- Release assets: `dv-annotate-setup-X.Y.Z.exe` and the raw bundle `dv-annotate.ps1` (the raw bundle stays for users who prefer the old route).
- Pin every third-party action to a full commit SHA, with the version in a trailing comment. Look up current versions when implementing; don't copy versions from memory.
- Workflow permissions: default `contents: read`; the release job adds `contents: write`, `id-token: write`, `attestations: write`.

## Attestation: what's available

- **Artifact attestations work for any file, including release assets.** `actions/attest-build-provenance` signs SLSA provenance (via Sigstore) binding the file's SHA-256 digest to the workflow run, commit, and repo. They're free for public repos. Users verify with `gh attestation verify dv-annotate-setup-X.Y.Z.exe -R NimrodXMods/dv-annotate`.
- **Immutable releases (repo setting) are complementary.** When enabled, GitHub locks the release's assets and tag after publishing and creates a release attestation, verifiable with `gh release verify-asset vX.Y.Z <file>`. This proves the asset is the one published in that release. Build provenance proves which workflow run built it. Enable both. Immutability means the workflow must upload all assets *before* publishing, so it creates the release as a draft, uploads, then publishes.
- Neither one is code signing. SmartScreen will still warn on the unsigned exe. Signing (e.g. Azure Artifact Signing) is out of scope for this plan.

## Review Focus

- A user who still downloads the raw `.ps1` (old instructions, old links) hits the RemoteSigned block on the installed copy. Task 1 fixes `LightweightInstall` so that path keeps working.
- Upgrading over an existing install (installer over installer, or installer over a LightweightInstall copy) must overwrite `dv-annotate.ps1` and keep `prefs.json`. Task 3's smoke test installs twice.
- Uninstall must not delete `prefs.json` or anything the user created in `%APPDATA%\dV-annotate`. Task 3's smoke test asserts this.
- The tag and `$Version` disagree, or someone forgot to rebuild the bundle: CI must fail loudly, not ship a stale bundle. Tasks 3 and 4 add the checks.
- `ISCC.exe` isn't preinstalled on the runner image, or sits at a different path. Task 3 locates it and installs it via Chocolatey if missing.

---

### Task 1: Make the existing install path policy-proof

**Files:**
- Modify: `windows/dv-annotate.ps1` (`LightweightInstall`, `LaunchDVGame`)
- Modify: `windows/build/dv-annotate.ps1` (rebuilt)
- Modify: `CLAUDE.md` (remove the TODO entry)

- [ ] **Step 1:** In `LightweightInstall`, after `Move-Item`, call `Unblock-File -LiteralPath $installedScriptPath`. Change the shortcut `Arguments` from `-ExecutionPolicy RemoteSigned -Command ${installedScriptPath}` to `-ExecutionPolicy Bypass -File "${installedScriptPath}"`. With `-File` and quoting, paths containing spaces work.
- [ ] **Step 2:** Fix the `CLAUDE.md` TODO: in `LaunchDVGame`, change `ErrorBox("…", "Launch Error")` to `ErrorBox "Exception trying to launch dV: $_" "Launch Error"`. Remove the TODO section.
- [ ] **Step 3:** Bump `$Version` to `1.3.0`, then run `windows/Build-Bundle.ps1`.
- [ ] **Step 4: Verify.** Run `Invoke-ScriptAnalyzer windows -Settings windows/PSScriptAnalyzerSettings.psd1 -Severity Error`. Expected: no output. Then, by hand on Windows: download the bundle from a branch raw URL, run it with "Run with PowerShell", answer `y`, and double-click the shortcut. Expected: the GUI opens, and `Get-Item -Stream Zone.Identifier "$env:APPDATA\dV-annotate\dv-annotate.ps1"` errors (the stream is gone).
- [ ] **Step 5: Commit** with the message "Unblock installed script and launch with -ExecutionPolicy Bypass".

### Task 2: Inno Setup script

**Files:**
- Create: `windows/installer/dv-annotate.iss`
- Create: `windows/installer/Build-Installer.ps1`
- Modify: `.gitignore` (add `windows/installer/Output/`)

**Interfaces:**
- Produces: `Build-Installer.ps1 [-IsccPath <string>]` reads `$Version` from `windows/dv-annotate.ps1` with the regex `^﻿?\$Version = "(\d+\.\d+\.\d+)"`. It runs `windows/Build-Bundle.ps1`, then `ISCC.exe /DAppVersion=<ver> windows/installer/dv-annotate.iss`. It writes `windows/installer/Output/dv-annotate-setup-<ver>.exe` and outputs that path. `IsccPath` defaults to `ISCC.exe` on `PATH`, else `${env:ProgramFiles(x86)}\Inno Setup 6\ISCC.exe`.

- [ ] **Step 1:** Write `dv-annotate.iss` using the Global Constraints values.
  - `[Setup]` uses: a fixed `AppId` (generate one GUID now and never change it), `AppName=dV Annotate`, `AppVersion={#AppVersion}`, `DefaultDirName={userappdata}\dV-annotate`, `DisableDirPage=yes`, `PrivilegesRequired=lowest`, `OutputBaseFilename=dv-annotate-setup-{#AppVersion}`, `UninstallDisplayIcon={sys}\shell32.dll,269`.
  - `[Files]` installs `..\build\dv-annotate.ps1` into `{app}` with `Flags: ignoreversion`.
  - `[Icons]` creates a Start Menu shortcut `{userprograms}\dV Annotate` and an optional desktop shortcut gated by a `[Tasks]` entry (unchecked by default).
  - `[Run]` offers to launch it after install (`postinstall nowait skipifsilent`).
  - Don't list `prefs.json` anywhere, so uninstall leaves it.
- [ ] **Step 2:** Write `Build-Installer.ps1` to the interface above. It must fail with a non-zero exit if the version regex doesn't match or ISCC exits non-zero.
- [ ] **Step 3: Verify locally.** Install Inno Setup 6, then run `windows/installer/Build-Installer.ps1`. Expected: it prints the `.exe` path. Run the exe. Expected: no UAC prompt, a Start Menu entry appears, and launching it opens the GUI without the "Lightweight Install" console. Uninstall from Settings. Expected: `prefs.json` remains.
- [ ] **Step 4: Commit** with the message "Add Inno Setup installer".

### Task 3: CI build workflow

**Files:**
- Create: `.github/workflows/build.yml`
- Create: `windows/installer/Test-Installer.ps1`

**Interfaces:**
- Consumes: `Build-Installer.ps1` from Task 2.
- Produces: an uploaded workflow artifact `dv-annotate-dist` containing the setup exe and `windows/build/dv-annotate.ps1`. Task 4 reuses this job via `workflow_call`.

- [ ] **Step 1:** Write `Test-Installer.ps1 -Setup <path>`. It runs `& $Setup /VERYSILENT /SUPPRESSMSGBOXES /CURRENTUSER /NORESTART` and waits for the process to exit.
  - After the first install, it asserts `"$env:APPDATA\dV-annotate\dv-annotate.ps1"` exists and the Start Menu `dV Annotate.lnk` exists, and that the shortcut's `Arguments` contain `-ExecutionPolicy Bypass` (read via `WScript.Shell`).
  - It writes a dummy `prefs.json`, installs a second time (upgrade), and asserts the dummy is unchanged.
  - It runs the uninstaller (`unins000.exe /VERYSILENT`) and asserts the script is gone and `prefs.json` remains.
  - It throws on the first failed assertion.
- [ ] **Step 2:** Write `build.yml`.
  - Triggers: `push` to `main`, `pull_request`, and `workflow_call`. One job, `build`, on `windows-latest`, with `defaults.run.shell: powershell` so it runs on 5.1.
  - Steps:
    1. Checkout.
    2. Rebuild the bundle with `windows/Build-Bundle.ps1`, then `git diff --exit-code windows/build/dv-annotate.ps1`. This fails if someone forgot to rebuild.
    3. `Invoke-ScriptAnalyzer windows -Recurse -Settings windows/PSScriptAnalyzerSettings.psd1 -Severity Error -EnableExit`.
    4. Install a pinned Inno Setup: `choco install innosetup --version <pinned 6.x> -y --no-progress --allow-downgrade`. Pin it, because whether the runner image preinstalls Inno Setup, and which version, has changed over time, and an unpinned install has conflicted with the preinstalled version. Don't use a third-party Inno Setup action; `Build-Installer.ps1` already does what it would, and works the same locally.
    5. `Build-Installer.ps1`.
    6. `Test-Installer.ps1`.
    7. Upload artifact `dv-annotate-dist`.
- [ ] **Step 3: Verify.** Push a branch and open a PR. Expected: the `build` job is green and the artifact is downloadable. Then commit a source change without rebuilding. Expected: step 2 fails with a diff. Revert that change.
- [ ] **Step 4: Commit** with the message "Add CI build and installer smoke test".

### Task 4: Tag-triggered release with attestation

**Files:**
- Create: `.github/workflows/release.yml`

**Interfaces:**
- Consumes: `build.yml` (`uses: ./.github/workflows/build.yml`) and the artifact `dv-annotate-dist`.

- [ ] **Step 1:** Write `release.yml`.
  - Trigger: `push` tags `v*`.
  - Job `build`: uses the reusable workflow from Task 3.
  - Job `release`: `needs: build`, runs on `ubuntu-latest`, with permissions `contents: write`, `id-token: write`, `attestations: write`. Steps:
    1. Checkout and download the artifact.
    2. Check that the tag minus its `v` equals the version parsed from `windows/dv-annotate.ps1`; exit 1 with both values if not.
    3. Run `actions/attest-build-provenance` with `subject-path` covering both files.
    4. `gh release create "$TAG" --draft --generate-notes` plus both files.
    5. `gh release edit "$TAG" --draft=false`. Publishing last keeps this compatible with immutable releases.
- [ ] **Step 2:** In the repo settings, enable **Immutable releases** (Settings → General → Releases). This is a manual, owner-only step; record it in the PR description.
- [ ] **Step 3: Verify.** Push tag `v1.3.0-rc1` against a matching `$Version` on a test branch, or use a scratch fork. Expected: a release appears with both assets. Download the exe, then run `gh attestation verify dv-annotate-setup-*.exe -R NimrodXMods/dv-annotate` (expected: `Verification succeeded`, naming `release.yml` and the tag's commit) and `gh release verify-asset <tag> <exe>` (expected: success). Delete the test release and tag. Then push a tag that doesn't match `$Version`. Expected: the version check fails and no release is created.
- [ ] **Step 4: Commit** with the message "Add attested release workflow".

### Task 5: Docs

**Files:**
- Modify: `windows/build/README.md`, `README.md`, `CLAUDE.md`

- [ ] **Step 1:** Rewrite the install instructions in `windows/build/README.md`.
  - Primary path: download `dv-annotate-setup-X.Y.Z.exe` from the latest release; expect the SmartScreen "More info → Run anyway" prompt (explain why, briefly); uninstall via Windows Settings.
  - Keep the raw-`.ps1` route as an alternative.
  - Add a "Verifying the download" section with the two `gh` commands from Task 4.
- [ ] **Step 2:** Update the "Windows" paragraph in `README.md` to point at Releases.
- [ ] **Step 3:** Update `CLAUDE.md`: add the installer build (`windows/installer/Build-Installer.ps1`), the release process (bump `$Version`, rebuild, commit, tag `vX.Y.Z`, push the tag), and the fact that CI rejects a stale bundle or a mismatched tag.
- [ ] **Step 4: Commit** with the message "Document installer, releases, and verification".
