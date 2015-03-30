; Script generated by the Inno Setup Script Wizard.
; SEE THE DOCUMENTATION FOR DETAILS ON CREATING INNO SETUP SCRIPT FILES!

[Setup]
AppName=Dover
AppVerName=Dover - BRANCH - TAG
AppVersion=TAG
AppPublisher=Eduardo Piva
AppPublisherURL=http://efpiva.github.io/
AppSupportURL=http://efpiva.github.io/
AppUpdatesURL=http://efpiva.github.io/
DefaultDirName={code:GetDefaultAddOnDir}
DisableDirPage=yes
Compression=lzma
SolidCompression=yes
UsePreviousAppDir=no
AppendDefaultDirName=yes
Uninstallable=yes

[Files]
Source: "C:\Program Files (x86)\SAP\SAP Business One\AddOnInstallAPI.dll"; Flags: dontcopy;

;Archivo .Exe del AddOn
Source: "Dover.exe"; DestDir: {app}; Flags: ignoreversion
Source: "Castle.Core.dll"; DestDir: {app}; Flags: ignoreversion
Source: "Castle.Facilities.Logging.dll"; DestDir: {app}; Flags: ignoreversion
Source: "Castle.Services.Logging.Log4netIntegration.dll"; DestDir: {app}; Flags: ignoreversion
Source: "Castle.Windsor.dll"; DestDir: {app}; Flags: ignoreversion
Source: "FrameworkInterface.dll"; DestDir: {app}; Flags: ignoreversion
Source: "ICSharpCode.SharpZipLib.dll"; DestDir: {app}; Flags: ignoreversion
Source: "SAPbouiCOM.dll"; DestDir: {app}; Flags: ignoreversion
Source: "log4net.dll"; DestDir: {app}; Flags: ignoreversion
Source: "Framework.dll"; DestDir: {app}; Flags: ignoreversion
Source: "Interop.SAPbobsCOM.dll"; DestDir: {app}; Flags: ignoreversion
Source: "pt-BR/Framework.resources.dll"; DestDir: {app}/pt-BR; Flags: ignoreversion

;Información para la desinstalación
[Registry]
Root: HKCU; Subkey: "Software\Dover"; Flags: uninsdeletekey
Root: HKCU; Subkey: "Software\Dover\Framework"; Flags: uninsdeletekey
Root: HKLM; Subkey: "Software\Dover"; Flags: uninsdeletekey
Root: HKLM; Subkey: "Software\Dover\Framework"; Flags: uninsdeletekey
Root: HKLM; Subkey: "Software\Dover\Framework"; ValueType: string; ValueName: "InstallPath"; ValueData: "{app}"

[Languages]
Name: en; MessagesFile: "compiler:Default.isl"

[Messages]
en.BeveledLabel=English

[CustomMessages]
en.MyDescription=My description
en.MyAppName=My Program
en.MyAppVerName=My Program %1


[Code]
//-Public Vars
var
  CurrentLocation : string;
  AddOnDir : string;
  FinishedInstall : Boolean;
  Uninstalling : Boolean;

//-External Functions (AddOnInstallAPI.dll)
function EndInstall: integer; external 'EndInstall@files:AddOnInstallAPI.dll stdcall';
function SetAddOnFolder(srcPath : string): integer; external 'SetAddOnFolder@files:AddOnInstallAPI.dll stdcall';
function RestartNeeded :integer; external 'RestartNeeded@files:AddOnInstallAPI.dll stdcall delayload ';


//-Check if the application is installed;
//- if yes --> suggest to Remove
//- if no --> Install
function CheckInstalled(): boolean;
  var
    ResultCode: Integer;
  begin
    result := False;
    //-if find...
    if RegQueryStringValue(HKEY_LOCAL_MACHINE, 'Software\Dover\Framework','InstallPath', CurrentLocation) then
      begin
        //-...Execute the uninstall to remove
        Exec(CurrentLocation + '\unins000.exe', '', '', SW_SHOW, ewWaitUntilTerminated, ResultCode)
        result := True;
      end;
  end;

//-When Setup starts, get the parameters of B1
function PreparePaths() : Boolean;
  var
    position : integer;
    aux : string;
    ResultCode : Integer;
  begin
    //-First Check if the application is installed
    if CheckInstalled then
      begin
        Result := False;
      end
    else
      //-If not yet installed, the 6th parameter has to be character "|" to be a valid call from B1
      if pos('|', paramstr(2)) <> 0 then
        begin
          aux := paramstr(2);
          position := Pos('|', aux)
          AddOnDir := Copy(aux,0, position - 1)
          Result := True;

        end
      else
        begin
          //-The Setup just Runs if Called from B1
          MsgBox('The Setup just can be run from Business One.', mbInformation, MB_OK)

          Result := False;
        end;
  end;

function GetDefaultAddOnDir(Param : string): string;
  begin
    //-Default Directory to Install the Add-On
       result := AddOnDir;
  end;

function InitializeSetup(): Boolean;
  begin
    result := PreparePaths;
  end;

function NextButtonClick(CurPageID: Integer): Boolean;
  begin
    Result := True;
    case CurPageID of
      wpSelectDir :
        begin
          AddOnDir := ExpandConstant('{app}');
          end;
      wpFinished :
        begin
          //-If All OK then
          if FinishedInstall then
            begin
              //-Send to B1 the Installation Folder and ...
              SetAddOnFolder( ExpandConstant('{app}'));
              //-...indicates finish installing
              EndInstall();
            end;
        end;
    end;
  end;

procedure CurStepChanged(CurStep: TSetupStep);
  begin
    if CurStep = ssPostInstall then
      FinishedInstall := True;
    end;



