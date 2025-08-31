/// <summary>OSPathsDemo</summary>
/// <remarks>Version: 1.0 2025-09-01<br />Copyright 2025 himitsu @ geheimniswelten<br />License: MPL v1.1 , GPL v3.0 or LGPL v3.0</remarks>
/// <seealso cref="http://geheimniswelten.de">Geheimniswelten</seealso>
/// <seealso cref="http://geheimniswelten.de/kontakt/#licenses">License Text</seealso>
/// <seealso cref="https://github.com/geheimniswelten/OSPathsDemo">GitHub</seealso>
unit OSPathsDemoMain;

interface

uses
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Layouts,
  FMX.Memo.Types, FMX.Controls.Presentation, FMX.ScrollBox, FMX.Memo, FMX.StdCtrls,
  FMX.Edit, FMX.Objects,
  {$IFDEF MSWINDOWS} FMX.Platform.Win, System.Win.Registry, Winapi.Windows, {$ENDIF}
  {$IFDEF ANDROID} Androidapi.Helpers, Androidapi.JNI.JavaTypes, Androidapi.JNI.App, {$ENDIF}
  System.SysUtils, System.IOUtils, System.Types, System.UITypes, System.Classes, System.Variants, FMX.TabControl;

type
  TForm2 = class(TForm)
    ButtonTerminate: TButton;
    ButtonClose: TButton;
    ButtonFullClose: TButton;
    LabelSaveState: TEdit;
    EditSaveState: TMemo;
    UserEditSaveState: TMemo;
    LabelHomePath: TEdit;
    EditHomePath: TMemo;
    UserEditHomePath: TMemo;
    LabelDocuments: TEdit;
    EditDocuments: TMemo;
    UserEditDocuments: TMemo;
    LabelSharedDocuments: TEdit;
    EditSharedDocuments: TMemo;
    UserEditSharedDocuments: TMemo;
    LabelPublicPath: TEdit;
    EditPublicPath: TMemo;
    UserEditPublicPath: TMemo;
    MemoPaths: TMemo;
    spacerKeyboard: TLayout;
    ButtonDelete: TButton;
    LabelSharedPref: TEdit;
    EditSharedPref: TMemo;
    UserEditSharedPref: TMemo;
    TabControl: TTabControl;
    TabPaths: TTabItem;
    TabSaveUser: TTabItem;
    Label1: TLabel;
    Label2: TLabel;
    VertScrollBox1: TVertScrollBox;
    Layout1: TLayout;
    PanelMenu: TLayout;
    procedure FormCreate(Sender: TObject);
    procedure FormSaveState(Sender: TObject);
    procedure FormVirtualKeyboardHidden(Sender: TObject; KeyboardVisible: Boolean; const Bounds: TRect);
    procedure FormVirtualKeyboardShown(Sender: TObject; KeyboardVisible: Boolean; const Bounds: TRect);
    procedure ButtonDeleteClick(Sender: TObject);
    procedure ButtonCloseClick(Sender: TObject);
    procedure ButtonFullCloseClick(Sender: TObject);
    procedure ButtonTerminateClick(Sender: TObject);
    procedure LabelPathEnter(Sender: TObject);
    procedure LabelPathExit(Sender: TObject);
    procedure VertScrollBox1Resized(Sender: TObject);
  end;

var
  Form2: TForm2;

implementation

{$R *.fmx}

type
  TFormSaveStateAccess = class(TFormSaveState);

{$IF not Declared(Coalesce)}
function Coalesce(Str1, Str2: string): string; inline;
begin
  if Str1 <> '' then
    Result := Str1
  else
    Result := Str2;
end;
{$ENDIF}

procedure TForm2.ButtonCloseClick(Sender: TObject);
begin
  //Application.MainForm.Close;
  Self.Close;
end;

procedure TForm2.ButtonDeleteClick(Sender: TObject);
  procedure ClearData(Edit, UserEdit: TMemo); overload;
  begin
    Edit.Lines.Clear;
    UserEdit.Lines.Clear;
    try
      SaveState.Stream.Clear;
      //SaveState.UpdateToSaveState; OR SaveStateHandler(nil, nil); ????????
    except
      //
      FMX.Types.Log.d('except');
    end;
  end;
  procedure ClearData(Edit, UserEdit: TMemo; Path: string); overload;
  begin
    Edit.Lines.Clear;
    UserEdit.Lines.Clear;
    if Path.Trim <> '' then
      try
        Path := TPath.Combine(Path, Application.Title + '_' + Edit.Name + '.txt');
        if TFile.Exists(Path) then
          TFile.Delete(Path);
      except
        //
        FMX.Types.Log.d('except');
      end;
  end;
  procedure ClearData(Edit, UserEdit: TMemo; Dummy: Boolean); overload;
  begin
    Edit.Lines.Clear;
    UserEdit.Lines.Clear;
    try
      {$IFDEF ANDROID}
        var Prefs     := TAndroidHelper.Activity.getPreferences(TJActivity.JavaClass.MODE_PRIVATE);
        var Editor    := Prefs.edit;
        Editor.remove(StringToJString(Application.Title + '_' + Edit.Name));
        Editor.remove(StringToJString(Application.Title + '_' + UserEdit.Name));
        Editor.apply;
      {$ENDIF}
      {$IFDEF MSWINDOWS}
        var Reg := TRegistry.Create;
        try
          Reg.RootKey := HKEY_CURRENT_USER;
          if Reg.OpenKey('Software', False) then
            Reg.DeleteKey(Application.Title);
        finally
          Reg.Free;
        end;
      {$ENDIF}
    except
      //
      FMX.Types.Log.d('except');
    end;
  end;
begin
  ClearData(EditSaveState,       UserEditSaveState);
  ClearData(EditHomePath,        UserEditHomePath,        TPath.GetHomePath);
  ClearData(EditDocuments,       UserEditDocuments,       TPath.GetDocumentsPath);
  ClearData(EditSharedDocuments, UserEditSharedDocuments, TPath.GetSharedDocumentsPath);
  ClearData(EditPublicPath,      UserEditPublicPath,      TPath.GetPublicPath);
  ClearData(EditSharedPref,      UserEditSharedPref,      True);
end;

procedure TForm2.ButtonFullCloseClick(Sender: TObject);
begin
  {$IF Defined(IOS)}
    // https://developer.apple.com/library/archive/qa/qa1561/_index.html
    Abort;
  {$ELSEIF Defined(OSX)}
    //Application.MainForm.Close;
    Application.Terminate;
  {$ELSEIF Defined(ANDROID)}
    if TOSVersion.Check(5) then
      TAndroidHelper.Activity.finishAndRemoveTask
    else
      TAndroidHelper.Activity.finish;
    //TJSystem.JavaClass.exit(2);
  {$ELSEIF Defined(MSWINDOWS) and Defined(CPUARM)}
    {$MESSAGE Fatal 'unsupported OS'}
  {$ELSEIF Defined(MSWINDOWS)}
    //Application.MainForm.Close;
    Application.Terminate;
  {$ELSE}
    {$MESSAGE Fatal 'unsupported OS'}
  {$IFEND}
end;

procedure TForm2.ButtonTerminateClick(Sender: TObject);
begin
  Application.Terminate;
end;

procedure TForm2.FormCreate(Sender: TObject);
  procedure LoadData(EditLabel: TEdit; Edit, UserEdit: TMemo); overload;
  begin
    EditLabel.Text := EditLabel.Text + '  ' + Self.SaveState.StoragePath + ' : ' + TFormSaveStateAccess(Self.SaveState).GetUniqueName;
    try
      {$IF defined(ANDROID) or defined(MSWINDOWS)}
      // Windows speichert zwar, aber in %temp%, was jemand l schen k nnte
      SaveState.StoragePath := TPath.GetHomePath;
      {$ELSEIF defined(IOS)}
      // Warum im DLL-Pfad? https://www.delphipraxis.net/213907-settings-speichern-kamerabild-png-jpg.html#post1528261
      SaveState.StoragePath := TPath.GetLibraryPath;
      {$ENDIF}
      if SaveState.Stream.Size > 0 then begin
        var State := TBinaryReader.Create(SaveState.Stream);
        try
          Edit.Text     := State.ReadString;
          UserEdit.Text := State.ReadString;
        finally
          State.Free;
        end;
      end;
    except
      on E: Exception do
        UserEdit.Text := 'ERR: ' + E.Message;
    end;
    if Edit.Text.Trim = '' then
      Edit.Text := FormatDateTime('"c"=HH:MM:SS  ', Now);
  end;
  procedure LoadData(EditLabel: TEdit; Edit, UserEdit: TMemo; Path: string); overload;
  begin
    if Path.Trim <> '' then begin
      EditLabel.Text := EditLabel.Text + '   ' + TPath.Combine(Path, Application.Title + '_' + Edit.Name + '.txt');
      try
        Path := TPath.Combine(Path, Application.Title + '_' + Edit.Name + '.txt');
        if TFile.Exists(Path) then
          UserEdit.Text := TFile.ReadAllText(Path);
      except
        on E: Exception do
          UserEdit.Text := sLineBreak + 'ERR: ' + E.Message;
      end;
    end;
    if UserEdit.Text.Trim <> '' then begin
      Edit.Text := UserEdit.Lines[0];
      UserEdit.Lines.Delete(0);
    end;
    if Edit.Text.Trim = '' then
      Edit.Text := FormatDateTime('"c"=HH:MM:SS  ', Now);
  end;
  procedure LoadData(Edit, UserEdit: TMemo); overload;
  begin
    {$IFDEF ANDROID}
    try
      var Prefs     := TAndroidHelper.Activity.getPreferences(TJActivity.JavaClass.MODE_PRIVATE);
      Edit.Text     := JStringToString(Prefs.getString(StringToJString(Application.Title + '_' + Edit.Name),     StringToJString('')));
      UserEdit.Text := JStringToString(Prefs.getString(StringToJString(Application.Title + '_' + UserEdit.Name), StringToJString('')));
    except
      on E: Exception do
        UserEdit.Text := sLineBreak + 'ERR: ' + E.Message;
    end;
    if Edit.Text.Trim = '' then
      Edit.Text := FormatDateTime('"c"=HH:MM:SS  ', Now);
    {$ENDIF}
    {$IFDEF MSWINDOWS}
    try
      var Reg := TRegistry.Create;
      try
        Reg.RootKey := HKEY_CURRENT_USER;
        if Reg.OpenKeyReadOnly('Software\' + Application.Title) then
        begin
          Edit.Text     := Reg.ReadString(Edit.Name);
          UserEdit.Text := Reg.ReadString(UserEdit.Name);
        end;
      finally
        Reg.Free;
      end;
    except
      on E: Exception do
        UserEdit.Text := sLineBreak + 'ERR: ' + E.Message;
    end;
    if Edit.Text.Trim = '' then
      Edit.Text := FormatDateTime('"c"=HH:MM:SS  ', Now);
    {$ENDIF}
  end;
begin
  FMX.Types.Log.d('create');
  {$IFDEF MSWINDOWS}
    ButtonFullClose.Enabled := False;

    //MemoPaths.TextSettings.Font.Size := 12;

    Self.Position := TFormPosition.ScreenCenter;
    Self.Width    := 666;
    Self.Height   := 600;
  {$ENDIF}

  TabControl.ActiveTab := TabPaths;

  {$IFDEF MSWINDOWS}
    LabelSharedPref.Text := 'Registry  HKCU:Software\' + Application.Title;
  {$ELSE}
    {$IFnDEF ANDROID}
      LabelSharedPref.Enabled    := False;
      EditSharedPref.Enabled     := False;
      UserEditSharedPref.Enabled := False;
    {$ENDIF}
  {$ENDIF}

  (*                     WINDOWS                                     ANDROID
    AppPath              %ExePath%                                   -
    LibraryPath          %ExePath%\                                  /data/app/~~#####/com.embarcadero.APPNAME-#####/lib/arm
    DesktopPath          C:\Users\%username%\Desktop                 /data/user/0/com.embarcadero.APPNAME/files/Desktop
    HomePath             C:\Users\%username%\AppData\Roaming         /data/user/0/com.embarcadero.APPNAME/files
    TempPath             C:\Users\%username%\AppData\Local\Temp\     /storage/emulated/0/Android/data/com.embarcadero.APPNAME/files/tmp
    CachePath            C:\Users\%username%\AppData\Local           /data/user/0/com.embarcadero.APPNAME/cache
    DocumentsPath        C:\Users\%username%\Documents               /data/user/0/com.embarcadero.APPNAME/files
    SharedDocumentsPath  C:\Users\Public\Documents                   /storage/emulated/0/Documents
    PublicPath           C:\ProgramData                              /storage/emulated/0/Android/data/com.embarcadero.APPNAME/files

    PicturesPath         C:\Users\%username%\Pictures                /storage/emulated/0/Android/data/com.embarcadero.APPNAME/files/Picture
    CameraPath           C:\Users\%username%\Pictures                /storage/emulated/0/Android/data/com.embarcadero.APPNAME/files/DCIM
    MusicPath            C:\Users\%username%\Music                   /storage/emulated/0/Android/data/com.embarcadero.APPNAME/files/Music
    DownloadsPath        C:\Users\%username%\Downloads               /storage/emulated/0/Android/data/com.embarcadero.APPNAME/files/Download
    SharedPicturesPath   C:\Users\Public\Pictures                    /storage/emulated/0/Pictures
    SharedCameraPath     C:\Users\Public\Pictures                    /storage/emulated/0/DCIM
    SharedMusicPath      C:\Users\Public\Music                       /storage/emulated/0/Music
    SharedDownloadsPath  C:\Users\Public\Downloads                   /storage/emulated/0/Download
  *)
  MemoPaths.Lines.Clear;
  MemoPaths.Lines.Add('AppPath '#9#9 +           Coalesce(TPath.GetAppPath, '(empty)'));
  MemoPaths.Lines.Add('LibraryPath '#9#9 +       TPath.GetLibraryPath);
  MemoPaths.Lines.Add('DesktopPath '#9#9 +       TPath.GetDesktopPath);
  MemoPaths.Lines.Add('HomePath '#9#9 +          TPath.GetHomePath);
  MemoPaths.Lines.Add('TempPath '#9#9 +          TPath.GetTempPath);
  MemoPaths.Lines.Add('CachePath '#9#9 +         TPath.GetCachePath);
  MemoPaths.Lines.Add('DocumentsPath '#9#9 +     TPath.GetDocumentsPath);
  MemoPaths.Lines.Add('SharedDocumentsPath '#9 + TPath.GetSharedDocumentsPath);
  MemoPaths.Lines.Add('PublicPath '#9#9 +        TPath.GetPublicPath);
  MemoPaths.Lines.Add('');
  MemoPaths.Lines.Add('PicturesPath '#9#9 +      TPath.GetPicturesPath);
  MemoPaths.Lines.Add('CameraPath '#9#9 +        TPath.GetCameraPath);
  MemoPaths.Lines.Add('MusicPath '#9#9 +         TPath.GetMusicPath);
  MemoPaths.Lines.Add('DownloadsPath '#9#9 +     TPath.GetDownloadsPath);
  MemoPaths.Lines.Add('SharedPicturesPath '#9 +  TPath.GetSharedPicturesPath);
  MemoPaths.Lines.Add('SharedCameraPath '#9 +    TPath.GetSharedCameraPath);
  MemoPaths.Lines.Add('SharedMusicPath '#9#9 +   TPath.GetSharedMusicPath);
  MemoPaths.Lines.Add('SharedDownloadsPath '#9 + TPath.GetSharedDownloadsPath);
  MemoPaths.Lines.Add('');

  LoadData(LabelSaveState,       EditSaveState,       UserEditSaveState);
  LoadData(LabelHomePath,        EditHomePath,        UserEditHomePath,        TPath.GetHomePath);
  LoadData(LabelDocuments,       EditDocuments,       UserEditDocuments,       TPath.GetDocumentsPath);
  LoadData(LabelSharedDocuments, EditSharedDocuments, UserEditSharedDocuments, TPath.GetSharedDocumentsPath);
  LoadData(LabelPublicPath,      EditPublicPath,      UserEditPublicPath,      TPath.GetPublicPath);
  LoadData(                      EditSharedPref,      UserEditSharedPref);
end;

procedure TForm2.FormSaveState(Sender: TObject);
  procedure SaveData(Edit, UserEdit: TMemo); overload;
  begin
    var TextE := Edit.Text + '            ';
    if TextE.Trim = '' then
      TextE := FormatDateTime('"c"=HH:MM:SS  ', Now);
    TextE := TextE.Substring(0, 12) + FormatDateTime('"s"=HH:MM:SS', Now);
    Edit.Text := TextE + ' ***';

    var TextU := UserEdit.Text;
    if TextU.Trim.StartsWith('ERR:', True) then
      TextU := '';

    try
      SaveState.Stream.Clear;
      var State := TBinaryWriter.Create(SaveState.Stream);
      try
        State.Write(TextE);
        State.Write(TextU);
      finally
        State.Free;
      end;
    except
      //
      FMX.Types.Log.d('except');
    end;
  end;
  procedure SaveData(Edit, UserEdit: TMemo; Path: string); overload;
  begin
    var TextE := Edit.Text + '            ';
    if TextE.Trim = '' then
      TextE := FormatDateTime('"c"=HH:MM:SS  ', Now);
    TextE := TextE.Substring(0, 12) + FormatDateTime('"s"=HH:MM:SS', Now);
    Edit.Text := TextE + ' ***';

    var TextU := UserEdit.Text;
    if TextU.Trim.StartsWith('ERR:', True) then
      TextU := '';

    if Path.Trim <> '' then
      try
        Path := TPath.Combine(Path, Application.Title + '_' + Edit.Name + '.txt');
        TFile.WriteAllText(Path, TextE + sLineBreak + TextU);
      except
        //
        FMX.Types.Log.d('except');
      end;
  end;
  procedure SaveData(Edit, UserEdit: TMemo; Dummy: Boolean); overload;
  begin
    var TextE := Edit.Text + '            ';
    if TextE.Trim = '' then
      TextE := FormatDateTime('"c"=HH:MM:SS  ', Now);
    TextE := TextE.Substring(0, 12) + FormatDateTime('"s"=HH:MM:SS', Now);
    Edit.Text := TextE + ' ***';

    var TextU := UserEdit.Text;
    if TextU.Trim.StartsWith('ERR:', True) then
      TextU := '';

    try
      {$IFDEF ANDROID}
        var Prefs     := TAndroidHelper.Activity.getPreferences(TJActivity.JavaClass.MODE_PRIVATE);
        var Editor    := Prefs.edit;
        Editor.putString(StringToJString(Application.Title + '_' + Edit.Name),     StringToJString(TextE));
        Editor.putString(StringToJString(Application.Title + '_' + UserEdit.Name), StringToJString(TextU));
        Editor.apply;
      {$ENDIF}
      {$IFDEF MSWINDOWS}
        var Reg := TRegistry.Create;
        try
          Reg.RootKey := HKEY_CURRENT_USER;
          if Reg.OpenKey('Software\' + Application.Title, True) then
          begin
            Reg.WriteString(Edit.Name,     TextE);
            Reg.WriteString(UserEdit.Name, TextU);
          end;
        finally
          Reg.Free;
        end;
      {$ENDIF}
    except
      //
      FMX.Types.Log.d('except');
    end;
  end;
begin
  FMX.Types.Log.d('save');
  if EditSaveState.Text.Trim = '' then begin
    SaveState.Stream.Clear;  // weil in ButtonDeleteClick nicht gespeichert werden konnte (alles PRIVATE)
    Exit;
  end;
  SaveData(EditSaveState,       UserEditSaveState);
  SaveData(EditHomePath,        UserEditHomePath,        TPath.GetHomePath);
  SaveData(EditDocuments,       UserEditDocuments,       TPath.GetDocumentsPath);
  SaveData(EditSharedDocuments, UserEditSharedDocuments, TPath.GetSharedDocumentsPath);
  SaveData(EditPublicPath,      UserEditPublicPath,      TPath.GetPublicPath);
  SaveData(EditSharedPref,      UserEditSharedPref,      True);
end;

procedure TForm2.FormVirtualKeyboardHidden(Sender: TObject; KeyboardVisible: Boolean; const Bounds: TRect);
begin
  {$IF defined(Android) or defined(iOS)}
  spacerKeyboard.Height := 0;
  {$ENDIF}
end;

procedure TForm2.FormVirtualKeyboardShown(Sender: TObject; KeyboardVisible: Boolean; const Bounds: TRect);
begin
  {$IF defined(Android) or defined(iOS)}
  spacerKeyboard.Height := Bounds.Height - PanelMenu.Height;
  {$ENDIF}
end;

procedure TForm2.LabelPathEnter(Sender: TObject);
begin
  (Sender as TEdit).SelStart := (Sender as TEdit).Text.Length;
end;

procedure TForm2.LabelPathExit(Sender: TObject);
begin
  (Sender as TEdit).SelStart := 0;
end;

procedure TForm2.VertScrollBox1Resized(Sender: TObject);
begin
  Layout1.Width := VertScrollBox1.Width;
end;

end.

