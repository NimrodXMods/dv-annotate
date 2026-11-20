; Inno Setup 6 script for dV Annotate. Compile via Build-Installer.ps1,
; which passes /DAppVersion=x.y.z and builds the bundle first.
#ifndef AppVersion
  #error AppVersion is not defined. Compile with: ISCC.exe /DAppVersion=1.2.3 dv-annotate.iss
#endif

[Setup]
; AppId identifies the app for upgrades/uninstall. Never change it.
AppId={{7A94237D-AE01-4947-A0A8-E266DD2C872B}
AppName=dV Annotate
AppVersion={#AppVersion}
AppPublisher=dV Annotate
; Must match $dataDir in windows/dv-annotate.ps1 (%APPDATA%\dV-annotate).
DefaultDirName={userappdata}\dV-annotate
DisableDirPage=yes
DisableProgramGroupPage=yes
PrivilegesRequired=lowest
OutputDir=Output
OutputBaseFilename=dv-annotate-setup-{#AppVersion}
UninstallDisplayIcon={sys}\shell32.dll,269
Compression=lzma2
SolidCompression=yes
WizardStyle=modern

[Tasks]
Name: "desktopicon"; Description: "Create a &desktop shortcut"; GroupDescription: "Additional shortcuts:"; Flags: unchecked

[Files]
; prefs.json is deliberately not listed, so uninstall leaves it in place.
Source: "..\build\dv-annotate.ps1"; DestDir: "{app}"; Flags: ignoreversion

[Icons]
Name: "{userprograms}\dV Annotate"; Filename: "{sys}\WindowsPowerShell\v1.0\powershell.exe"; Parameters: "-NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File ""{app}\dv-annotate.ps1"""; WorkingDir: "{app}"; IconFilename: "{sys}\shell32.dll"; IconIndex: 269
Name: "{userdesktop}\dV Annotate"; Filename: "{sys}\WindowsPowerShell\v1.0\powershell.exe"; Parameters: "-NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File ""{app}\dv-annotate.ps1"""; WorkingDir: "{app}"; IconFilename: "{sys}\shell32.dll"; IconIndex: 269; Tasks: desktopicon

[Run]
Filename: "{sys}\WindowsPowerShell\v1.0\powershell.exe"; Parameters: "-NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File ""{app}\dv-annotate.ps1"""; WorkingDir: "{app}"; Description: "Launch dV Annotate"; Flags: postinstall nowait skipifsilent
