; Script generated by the Inno Setup Script Wizard.
; SEE THE DOCUMENTATION FOR DETAILS ON CREATING INNO SETUP SCRIPT FILES!

#define MyAppName "Cultibox"
#define MyAppVersion "1.0"
#define MyAppPublisher "Green Box SAS"
#define MyAppURL "http://localhost:6891/cultibox/"

[Setup]
; NOTE: The value of AppId uniquely identifies this application.
; Do not use the same AppId value in installers for other applications.
; (To generate a new GUID, click Tools | Generate GUID inside the IDE.)
AppId={{E8DC2CCC-6FD8-4FA2-B11A-4CF206BA4C60}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
;AppVerName={#MyAppName} {#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
DefaultDirName={pf}\{#MyAppName}
DefaultGroupName={#MyAppName}
AllowNoIcons=yes
OutputBaseFilename=setup
Compression=lzma
SolidCompression=yes

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"
Name: "french"; MessagesFile: "compiler:Languages\French.isl"

[Files]
Source: "F:\Cultibox_web\01_software\01_install\02_src\01_xampp\*"; DestDir: "{app}\xampp"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "F:\Cultibox_web\01_software\01_install\02_src\02_joomla\*"; DestDir: "{app}\xampp\htdocs\cultibox"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "F:\Cultibox_web\01_software\01_install\02_src\03_sql\*"; DestDir: "{app}\xampp\sql_install"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "F:\Cultibox_web\01_software\01_install\02_src\04_doc\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs
; NOTE: Don't use "Flags: ignoreversion" on any shared system files

[Icons]
Name: "{group}\{cm:ProgramOnTheWeb,{#MyAppName}}"; Filename: "{#MyAppURL}"; Comment: "Run cultibox"
Name: "{group}\{cm:UninstallProgram,{#MyAppName}}"; Filename: {uninstallexe}; Comment: "Uninstall cultibox"

[Run]
Filename: "{app}\xampp\setup_xampp.bat";Description: "Change path"
Filename: "{app}\xampp\xampp_start.exe";Description: "Run Xampp"; Flags: nowait
Filename: "{app}\xampp\sql_install\install_sql.bat";  WorkingDir: "{app}" ;Description: "Change root password"
