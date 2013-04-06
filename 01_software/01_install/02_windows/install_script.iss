; Script generated by the Inno Setup Script Wizard.
; SEE THE DOCUMENTATION FOR DETAILS ON CREATING INNO SETUP SCRIPT FILES!


; #####################################################################################
;       Changer les chemins de la section [Files] pour rendre le script portable
; #####################################################################################


#define MyAppName "cultibox"
#define MyAppVersion "1.1.2"
#define MyAppPublisher "Green Box SAS"
#define MyAppURL "http://www.cultibox.fr/"

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
DefaultDirName={sd}\{#MyAppName}
DefaultGroupName={#MyAppName}
AllowNoIcons=yes
OutputBaseFilename=cultibox-windows7_{#MyAppVersion}
VersionInfoVersion={#MyAppVersion}
Compression=lzma
SolidCompression=yes
;Pas de warning si le dossier existe d�j�
DirExistsWarning=no
; Interdiction de changer le path
DisableDirPage=yes
;Minimal disk space requiered: 400Mo
ExtraDiskSpaceRequired=419430400
;Desactive le choix de creation dans le menu demarrer
DisableProgramGroupPage=yes
LicenseFile=conf-package\lgpl3.txt



[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"
Name: "french"; MessagesFile: "compiler:Languages\French.isl"


[CustomMessages]
french.ContinueInstall=Une version du logiciel Cultibox semble d�ja pr�sente, vous pouvez tenter d'installer cette nouvelle version par dessus l'ancienne mais vous risquez de perdre votre configuration. Votre configuration actuelle sera sauvegard� dans le r�pertoire backup pour vous permettre de la retrouver. Voulez vous continuer et installer cette version?
english.ContinueInstall=A current version of the Cultibox software seems to be already installed on your computer. You can install this new software version over the old one but you may loose your configuration in the process. Your current configuration will be saved into the backup directory. Do you want to continue the install process?

french.SaveDatas=Voulez-vous sauvegarder la configuration de votre ancienne version afin de pouvoir la restaurer ult�rieurement si n�c�ssaire?
english.SaveDatas=Do you want to save the configuration of your old Cultibox software to maybe ued it to restore your preferences later?

french.CleanCache=Vous venez d'installer une nouvelle version, n'oubliez pas de supprimer le cache de votre navigateur internet pour que celle-ci soit pleinement fonctionnelle
english.CleanCache=You just install a new version of the Cultibox software, don't forget to delete your internet browser's cache to have a full working version.

french.StartCultibox=Voulez-vous ex�cuter le logiciel Cultibox imm�diatement?
english.StartCultibox=Do you want to execute the Cultibox software immediatly?

[code]
var 
  ForceInstall: boolean;
function InitializeSetup():boolean;
var
  ResultCode: integer;

begin
  Result := True;  
  if FileExists(ExpandConstant('{sd}\{#MyAppName}\unins000.exe')) then
  begin
       // Ask the user a Yes/No question, defaulting to No
       if MsgBox(ExpandConstant('{cm:ContinueInstall}'), mbConfirmation, MB_YESNO or MB_DEFBUTTON2) = IDYES then                                                                                                                                 
       begin
           // user clicked Yes
           ForceInstall := True;
           Result := True;
       end else 
       begin
           ForceInstall := False;
           Result := False;
       end; 
  end else
  begin
    ForceInstall := False;
    Result := True;
  end;

  if(ForceInstall) then
  begin
       if MsgBox(ExpandConstant('{cm:SaveDatas}'), mbConfirmation, MB_YESNO or MB_DEFBUTTON2) = IDYES then                                                                                                                                 
       begin                                                      
        Exec (ExpandConstant ('{cmd}'), '/C net start cultibox_apache', '', SW_SHOW, ewWaitUntilTerminated, ResultCode);
        Exec (ExpandConstant ('{cmd}'), '/C net start cultibox_mysql', '', SW_SHOW, ewWaitUntilTerminated, ResultCode);

        ExtractTemporaryFile ('backup.bat');
        Exec (ExpandConstant ('{cmd}'), ExpandConstant ('/C copy backup.bat {sd}\{#MyAppName}\backup.bat'), ExpandConstant ('{tmp}'), SW_SHOW, ewWaitUntilTerminated, ResultCode);
        Exec (ExpandConstant ('{cmd}'), '/C backup.bat', ExpandConstant ('{sd}\{#MyAppName}'), SW_SHOW, ewWaitUntilTerminated, ResultCode);
       end;
       Exec (ExpandConstant ('{cmd}'), '/C net stop cultibox_apache', '', SW_SHOW, ewWaitUntilTerminated, ResultCode);
       Exec (ExpandConstant ('{cmd}'), '/C net stop cultibox_mysql', '', SW_SHOW, ewWaitUntilTerminated, ResultCode);
  end;  
end;

procedure CurStepChanged(CurStep: TSetupStep);
var
  ResultCode: integer;

 begin
  if(CurStep=ssPostInstall) then
  begin
    if not (ForceInstall) then
    begin    
        Exec (ExpandConstant ('{cmd}'), ExpandConstant('/C setup_xampp.bat'), ExpandConstant ('{sd}\{#MyAppName}\xampp'), SW_SHOW, ewWaitUntilTerminated, ResultCode);
        Exec (ExpandConstant ('{cmd}'), ExpandConstant('/C apache_uninstallservice.bat'), ExpandConstant ('{sd}\{#MyAppName}\xampp\apache'), SW_SHOW, ewWaitUntilTerminated, ResultCode);
        Exec (ExpandConstant ('{cmd}'), ExpandConstant('/C apache_installservice.bat'), ExpandConstant ('{sd}\{#MyAppName}\xampp\apache'), SW_SHOW, ewWaitUntilTerminated, ResultCode);
        Exec (ExpandConstant ('{cmd}'), ExpandConstant('/C mysql_uninstallservice.bat'), ExpandConstant ('{sd}\{#MyAppName}\xampp\mysql'), SW_SHOW, ewWaitUntilTerminated, ResultCode);
        Exec (ExpandConstant ('{cmd}'), ExpandConstant('/C mysql_installservice.bat'), ExpandConstant ('{sd}\{#MyAppName}\xampp\mysql'), SW_SHOW, ewWaitUntilTerminated, ResultCode);
        Exec (ExpandConstant ('{cmd}'), ExpandConstant('/C mysqladmin.exe -u root -h localhost  --port=3891 password cultibox'), ExpandConstant ('{sd}\{#MyAppName}\xampp\mysql\bin'), SW_SHOW, ewWaitUntilTerminated, ResultCode);
        Exec (ExpandConstant ('{cmd}'), ExpandConstant('/C mysql.exe -u root -h localhost --port=3891 -pcultibox -e "source {sd}\{#MyAppName}\xampp\sql_install\user_cultibox.sql"'), ExpandConstant ('{sd}\{#MyAppName}\xampp\mysql\bin'), SW_SHOW, ewWaitUntilTerminated, ResultCode);
        Exec (ExpandConstant ('{cmd}'), ExpandConstant('/C mysql.exe -u root -h localhost --port=3891 -pcultibox -e "source {sd}\{#MyAppName}\xampp\sql_install\joomla.sql"'), ExpandConstant ('{sd}\{#MyAppName}\xampp\mysql\bin'), SW_SHOW, ewWaitUntilTerminated, ResultCode);
        Exec (ExpandConstant ('{cmd}'), ExpandConstant('/C mysql.exe -u root -h localhost --port=3891 -pcultibox -e "source {sd}\{#MyAppName}\xampp\sql_install\fake_log.sql"'), ExpandConstant ('{sd}\{#MyAppName}\xampp\mysql\bin'), SW_SHOW, ewWaitUntilTerminated, ResultCode);
        
        case ActiveLanguage() of  { ActiveLanguage() retourne la langue chosie }
        'french' :  
            begin
              Exec (ExpandConstant ('{cmd}'), ExpandConstant('/C mysql.exe -u root -h localhost --port=3891 -pcultibox -e "source {sd}\{#MyAppName}\xampp\sql_install\cultibox_fr.sql"'), ExpandConstant ('{sd}\{#MyAppName}\xampp\mysql\bin\'), SW_SHOW, ewWaitUntilTerminated, ResultCode);
              Exec (ExpandConstant ('{cmd}'), ExpandConstant('/C mysql.exe -u root -h localhost --port=3891 -pcultibox -e "UPDATE `cultibox`.`configuration` SET `LANG` = ''fr_FR'' WHERE `configuration`.`id` =1;"'), ExpandConstant ('{sd}\{#MyAppName}\xampp\mysql\bin\'), SW_SHOW, ewWaitUntilTerminated, ResultCode);
            end;
        'english' :
            begin
              Exec (ExpandConstant ('{cmd}'), ExpandConstant('/C mysql.exe -u root -h localhost --port=3891 -pcultibox -e "source {sd}\{#MyAppName}\xampp\sql_install\cultibox_en.sql"'), ExpandConstant ('{sd}\{#MyAppName}\xampp\mysql\bin\'), SW_SHOW, ewWaitUntilTerminated, ResultCode);         
              Exec (ExpandConstant ('{cmd}'), ExpandConstant('/C mysql.exe -u root -h localhost --port=3891 -pcultibox -e "UPDATE `cultibox`.`configuration` SET `LANG` = ''en_GB'' WHERE `configuration`.`id` =1;"'), ExpandConstant ('{sd}\{#MyAppName}\xampp\mysql\bin\'), SW_SHOW, ewWaitUntilTerminated, ResultCode);
            end;
         end;
     end;


     if (ForceInstall) then 
     begin
        Exec (ExpandConstant ('{cmd}'), ExpandConstant('/C setup_xampp.bat'), ExpandConstant ('{sd}\{#MyAppName}\xampp'), SW_SHOW, ewWaitUntilTerminated, ResultCode);
        Exec (ExpandConstant ('{cmd}'), '/C net start cultibox_apache', ExpandConstant ('{tmp}'), SW_SHOW, ewWaitUntilTerminated, ResultCode);
        Exec (ExpandConstant ('{cmd}'), '/C net start cultibox_mysql', ExpandConstant ('{tmp}'), SW_SHOW, ewWaitUntilTerminated, ResultCode);
        Exec (ExpandConstant ('{cmd}'), ExpandConstant('/C mysql.exe -u root -h localhost --port=3891 -pcultibox --force < {sd}\{#MyAppName}\xampp\sql_install\update_sql.sql 2>NULL'), ExpandConstant ('{sd}\{#MyAppName}\xampp\mysql\bin'), SW_SHOW, ewWaitUntilTerminated, ResultCode);
        Exec (ExpandConstant ('{cmd}'), ExpandConstant('/C mysql.exe -u root -h localhost --port=3891 -pcultibox -e "DROP DATABASE `cultibox_joomla`;"'), ExpandConstant ('{sd}\{#MyAppName}\xampp\mysql\bin\'), SW_SHOW, ewWaitUntilTerminated, ResultCode);
        Exec (ExpandConstant ('{cmd}'), ExpandConstant('/C mysql.exe -u root -h localhost --port=3891 -pcultibox -e "source {sd}\{#MyAppName}\xampp\sql_install\joomla.sql"'), ExpandConstant ('{sd}\{#MyAppName}\xampp\mysql\bin'), SW_SHOW, ewWaitUntilTerminated, ResultCode);
        Exec (ExpandConstant ('{cmd}'), ExpandConstant('/C del {sd}\{#MyAppName}\xampp\htdocs\cultibox\main\templates_c\*.ser'), ExpandConstant ('{sd}\{#MyAppName}\xampp'), SW_SHOW, ewWaitUntilTerminated, ResultCode);
        MsgBox(ExpandConstant('{cm:CleanCache}'), mbInformation, MB_OK);
     end;     
  end;

  if(CurStep=ssDone) then
  begin
      if MsgBox(ExpandConstant('{cm:StartCultibox}'), mbConfirmation, MB_YESNO or MB_DEFBUTTON2) = IDYES then                                                                                                                                 
       begin
          Exec (ExpandConstant ('{cmd}'), '/C start http://localhost:6891/cultibox', ExpandConstant ('{tmp}'), SW_SHOW, ewWaitUntilTerminated, ResultCode);
       end 
  end;
end; 




procedure CurUninstallStepChanged(CurUninstallStep: TUninstallStep);
var
  ResultCode: Integer;
begin
   
   if CurUninstallStep = usUninstall then
   begin
      Exec (ExpandConstant ('{cmd}'), '/C net stop cultibox_apache', ExpandConstant ('{tmp}'), SW_SHOW, ewWaitUntilTerminated, ResultCode);
      Exec (ExpandConstant ('{cmd}'), '/C net stop cultibox_mysql', ExpandConstant ('{tmp}'), SW_SHOW, ewWaitUntilTerminated, ResultCode);
      Exec (ExpandConstant ('{cmd}'), '/C apache_uninstallservice.bat', ExpandConstant ('{sd}\{#MyAppName}\xampp\apache'), SW_SHOW, ewWaitUntilTerminated, ResultCode);
      Exec (ExpandConstant ('{cmd}'), '/C mysql_uninstallservice.bat', ExpandConstant ('{sd}\{#MyAppName}\xampp\mysql'), SW_SHOW, ewWaitUntilTerminated, ResultCode);
   end;
end;



procedure CancelButtonClick(CurPageID: Integer; var Cancel, Confirm: Boolean);
var
  ResultCode: Integer;
begin
  Confirm := False;
  if (MsgBox (SetupMessage(msgExitSetupMessage),mbConfirmation, MB_YESNO) = IDYES) then
  begin
      Exec (ExpandConstant ('{cmd}'), '/C net start cultibox_apache', ExpandConstant ('{tmp}'), SW_SHOW, ewWaitUntilTerminated, ResultCode);
      Exec (ExpandConstant ('{cmd}'), '/C net start cultibox_mysql', ExpandConstant ('{tmp}'), SW_SHOW, ewWaitUntilTerminated, ResultCode);
  end;  
end;


[Files]
; Backup file. Used in pre install
Source: "C:\users\yann\Desktop\Project\cultibox\01_software\01_install\02_windows\conf-script\backup.bat"; DestDir: "{app}\run"; DestName: "backup.bat"; Flags: ignoreversion recursesubdirs createallsubdirs
; load file. Used in post install
Source: "C:\users\yann\Desktop\Project\cultibox\01_software\01_install\02_windows\conf-script\load.bat"; DestDir: "{app}\run"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "C:\users\yann\Desktop\Project\cultibox\01_software\01_install\02_windows\conf-package\lgpl3.txt"; DestDir: "{app}\LICENSE.txt"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "C:\users\yann\Desktop\Project\cultibox\01_software\01_install\01_src\01_xampp\cultibox\*"; DestDir: "{app}\xampp"; Flags: onlyifdoesntexist ignoreversion recursesubdirs createallsubdirs 
Source: "C:\users\yann\Desktop\Project\cultibox\01_software\01_install\01_src\01_xampp\cultibox\htdocs\cultibox\*"; DestDir: "{app}\xampp\htdocs\cultibox"; Flags: ignoreversion recursesubdirs createallsubdirs   
Source: "C:\users\yann\Desktop\Project\cultibox\02_documentation\02_userdoc\documentation.pdf"; DestDir: "{app}\xampp\htdocs\cultibox\main\modules\docs\documentation_cultibox.pdf"; Flags: ignoreversion recursesubdirs createallsubdirs   
Source: "C:\users\yann\Desktop\Project\cultibox\01_software\01_install\02_windows\conf-script\backup.bat"; DestDir: "{app}"; DestName: "backup.bat"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "C:\users\yann\Desktop\Project\cultibox\01_software\01_install\02_windows\conf-script\load.bat"; DestDir: "{app}"; DestName: "load.bat"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "C:\users\yann\Desktop\Project\cultibox\01_software\01_install\01_src\01_xampp\02_sql\*"; DestDir: "{app}\xampp\sql_install"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "C:\users\yann\Desktop\Project\cultibox\01_software\01_install\01_src\03_sd\*"; DestDir: "{app}\sd"; Flags: ignoreversion recursesubdirs createallsubdirs
;Source: "C:\users\yann\Desktop\Project\cultibox\01_software\01_install\01_src\04_run\*"; DestDir: "{app}\run"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "C:\users\yann\Desktop\Project\cultibox\02_documentation\02_userdoc\*"; DestDir: "{app}\doc"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "C:\users\yann\Desktop\Project\cultibox\01_software\01_install\02_windows\conf-script\cultibox.bat"; DestDir: "{app}"; Flags: ignoreversion
Source: "C:\users\yann\Desktop\Project\cultibox\01_software\01_install\02_windows\conf-lampp\httpd.conf"; DestDir: "{app}\xampp\apache\conf"; Flags: ignoreversion onlyifdoesntexist  
Source: "C:\users\yann\Desktop\Project\cultibox\01_software\01_install\02_windows\conf-lampp\php.ini"; DestDir: "{app}\xampp\php"; Flags: ignoreversion  onlyifdoesntexist
Source: "C:\users\yann\Desktop\Project\cultibox\01_software\01_install\02_windows\conf-lampp\my.ini"; DestDir: "{app}\xampp\mysql\bin\"; Flags: ignoreversion onlyifdoesntexist
Source: "C:\users\yann\Desktop\Project\cultibox\01_software\01_install\01_src\03_sd\firm.hex"; DestDir: "{app}\xampp\htdocs\cultibox\tmp"; Flags: ignoreversion 
Source: "C:\users\yann\Desktop\Project\cultibox\01_software\01_install\01_src\03_sd\cnf\*"; DestDir: "{app}\xampp\htdocs\cultibox\tmp\cnf"; Flags: ignoreversion 
Source: "C:\users\yann\Desktop\Project\cultibox\01_software\01_install\01_src\03_sd\emetteur.hex"; DestDir: "{app}\xampp\htdocs\cultibox\tmp"; Flags: ignoreversion
Source: "C:\users\yann\Desktop\Project\cultibox\01_software\01_install\01_src\03_sd\sht.hex"; DestDir: "{app}\xampp\htdocs\cultibox\tmp"; Flags: ignoreversion
Source: "C:\users\yann\Desktop\Project\cultibox\01_software\01_install\01_src\03_sd\cultibox.ico"; DestDir: "{app}\xampp\htdocs\cultibox\tmp"; Flags: ignoreversion
Source: "C:\users\yann\Desktop\Project\cultibox\01_software\01_install\01_src\03_sd\cultibox.html"; DestDir: "{app}\xampp\htdocs\cultibox\tmp"; Flags: ignoreversion
; NOTE: Don't use "Flags: ignoreversion" on any shared system files


[Icons]
Name: "{group}\Cultibox"; Filename: "http://localhost:6891/cultibox"; Comment: "Run cultibox"; IconFilename: "{app}\sd\cultibox.ico"; AppUserModelID: "Cultibox.Cultibox"
Name: "{group}\{cm:UninstallProgram,{#MyAppName}}"; Filename: {uninstallexe}; Comment: "Uninstall cultibox"


[UninstallDelete]
Type: filesandordirs; Name: "{app}\xampp"
