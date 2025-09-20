/// <summary> Resource File Reader </summary>
/// <remarks> Version: 1.0 2025-09-12 <br/> Copyright 2025 himitsu @ geheimniswelten <br/> License: MPL v1.1 , GPL v3.0 or LGPL v3.0 </remarks>
/// <seealso cref="http://geheimniswelten.de"> Geheimniswelten </seealso>
/// <seealso cref="http://geheimniswelten.de/kontakt/#licenses"> License Text </seealso>
/// <seealso cref="https://github.com/geheimniswelten/h5uSingleCollection"> GitHub </seealso>
unit h5u.ResFile;

interface

uses
  System.RTLConsts, System.Math, System.Classes,
  System.SysUtils, System.StrUtils, System.IOUtils,
  Winapi.Windows;

type
  TResFile = record
  public type
    {$REGION 'SubTypes'}
    TCharacteristics = DWORD;
    TLangID = record
    private
      FLangID: WORD;
      function  GetLang(idx: Integer):       Word;
      procedure SetLang(idx: Integer; Value: Word);
      function  GetName:       string;
      procedure SetName(Value: string); inline;
    public
      property  LangID:          WORD index 0 read FLangID write SetLang;
      property  PrimaryLanguage: Word index 1 read GetLang write SetLang;
      property  SubLanguage:     Word index 2 read GetLang write SetLang;
      property  Language:        string       read GetName write SetName;
      procedure SetLangID(Primary, SubLang: Word); inline;
      class function GetDefaultLangID: TLangID; static; inline;
      class function GetLangID(LangName: string): TLangID; static;
    end;
    TVersion = record
    private
      function  GetVer:       Single;
      procedure SetVer(Value: Single);
      function  GetStr:       string; inline;
      procedure SetStr(Value: string);
    public
      property Version: Single read GetVer write SetVer;
      property VerStr:  string read GetStr write SetStr;
      case Integer of
        0: ( Minor, Major: Word );
        1: ( Raw: DWORD );
    end;
    TResource = record
      Type_:           string;
      Name:            string;
      ResVersion:      TVersion;
      Flags:           Word;
      Language:        TLangID;
      Version:         TVersion;
      Characteristics: TCharacteristics;
      Data:            TBytes;
    private
      SortOrder:       Pointer;
      function  IsInt (idx: Integer): Boolean;
      function  GetInt(idx: Integer): Word;
      procedure SetInt(idx: Integer; Value: Word);
      procedure ReadRecord (const FileData: TBytes; var Pos: Integer);
      procedure WriteRecord(var   FileData: TBytes; var Pos: Integer);
      procedure NormalizeTypeAndDefaults;
      function  GetNormalizedType: string;
    public
      property TypeIsInt: Boolean index 0 read IsInt;
      property TypeAsInt: Word    index 0 read GetInt write SetInt;
      property NameIsInt: Boolean index 1 read IsInt;
      property NameAsInt: Word    index 1 read GetInt write SetInt;
      function DataSize:  Integer; inline;
      function IsEmpty: Boolean;
      class operator Initialize(out Dest: TResource);
    end;
  private
    class function EnumResTypeProc(hModule: HMODULE; lpszType: PChar; lParam: NativeInt): BOOL; stdcall; static;
    class function EnumResNameProc(hModule: HMODULE; lpszType, lpszName: PChar; lParam: NativeInt): BOOL; stdcall; static;
    class function EnumResLangProc(hModule: HMODULE; lpszType, lpszName: PChar; wIDLanguage: Word; lParam: NativeInt): BOOL; stdcall; static;
    procedure SortEnumResources;
    {$ENDREGION}
  public class var
    DefaultLangID:    TLangID;           // 0 = neutral language / $FFFF = current system language (DEFAULT = $FFFF)
    DefaultVersion:   TVersion;          // DEFAULT = 0
    DefaultFlags:     Word;              // DEFAULT = 0
    DefaultCharacter: TCharacteristics;  // DEFAULT = 0
  public
    Resources: TArray<TResource>;

    class function CheckIsPEFile(FileName: string): Boolean; static;
    class function Create: TResFile; overload; static; inline;
    constructor Create(FileName: string); overload;

    procedure Clear;
    function  ResCount: Integer; inline;
    function  Add    (Resource: TResource): Integer; overload;
    function  Add    (&Type: string;  Name: string;  Data: TBytes; Language: LANGID=$FFFF; Flags: Word=$FFFF): Integer; overload;
    function  Add    (&Type: Integer; Name: string;  Data: TBytes; Language: LANGID=$FFFF; Flags: Word=$FFFF): Integer; overload; inline;
    function  Add    (&Type: Integer; Name: Integer; Data: TBytes; Language: LANGID=$FFFF; Flags: Word=$FFFF): Integer; overload; inline;
    function  IndexOf(&Type: string;  Name: string;                Language: LANGID=$FFFF; Flags: Word=$FFFF): Integer; overload;
    function  IndexOf(&Type: string;  Name: Integer;               Language: LANGID=$FFFF; Flags: Word=$FFFF): Integer; overload; inline;
    function  IndexOf(&Type: Integer; Name: Integer;               Language: LANGID=$FFFF; Flags: Word=$FFFF): Integer; overload; inline;
    function  IndexOf(Resource: TResource; IgnoreLanguage: Boolean=False): Integer; overload;
    procedure Delete(idx: Integer); inline;

    /// <summary>
    ///   LoadMine loads the resources of its own EXE. <param/>
    ///   LoadFrom and SaveTo (Stream) loads and saves in *.res files. <param/>
    ///   And LoadFrom and SaveTo (FileName) processes *.res, *.exe, *.dll and *.bpl.
    /// </summary>
    procedure LoadMine;
    procedure LoadFrom(FileName: string); overload;
    procedure LoadFrom(FileData: TBytes); overload;
    procedure SaveTo  (FileName: string; RemoveMissingFromPEFiles: Boolean=False); overload;
    function  SaveTo: TBytes; overload;

    class operator Initialize(out Dest: TResFile);
  public const
    {$REGION 'constants and helpers'}
    cDataTypes: array[#0..#24] of string = (
            '',
      {#1}  'RT_CURSOR',
      {#2}  'RT_BITMAP',
      {#3}  'RT_ICON',
      {#4}  'RT_MENU',
      {#5}  'RT_DIALOG',
      {#6}  'RT_STRING',
      {#7}  'RT_FONTDIR',
      {#8}  'RT_FONT',
      {#9}  'RT_ACCELERATOR',
      {#10} 'RT_RCDATA',
      {#11} 'RT_MESSAGETABLE',
      {#12} 'RT_GROUP_CURSOR',  // 11+RT_CURSOR
            '',
      {#14} 'RT_GROUP_ICON',    // 11+RT_ICON
            '',
      {#16} 'RT_VERSION',
      {#17} 'RT_DLGINCLUDE',
            '',
      {#19} 'RT_PLUGPLAY',
      {#20} 'RT_VXD',
      {#21} 'RT_ANICURSOR',
      {#22} 'RT_ANIICON',
      {#23} 'RT_HTML',
      {#24} 'RT_MANIFEST'
    );
    // the 4 languages of the Delphi IDE
    Lang_deDE    = LANGID($0407);  // MakeLangID(LANG_GERMAN,   SUBLANG_DEFAULT)
    Lang_enUS    = LANGID($0409);  // MakeLangID(LANG_ENGLISH,  SUBLANG_DEFAULT)
    Lang_frFR    = LANGID($040C);  // MakeLangID(LANG_FRENCH,   SUBLANG_DEFAULT)
    Lang_jaJP    = LANGID($0411);  // MakeLangID(LANG_JAPANESE, SUBLANG_DEFAULT)
    Lang_Neutral = LANGID($0000);  // MakeLangID(LANG_NEUTRAL,  SUBLANG_NEUTRAL)
  public
    /// <summary> e.q. RT_RCDATA to 'RT_RCDATA' </summary>
    class function ResTypeToStr(ResType: PChar): string; static;
    class function ResNameToStr(ResName: PChar): string; static;
    {$ENDREGION}
  end;

implementation

{ TResFile.TLangID }

class function TResFile.TLangID.GetDefaultLangID: TLangID;
begin
  Result.FLangID := {GetUserDefaultLangID}GetThreadLocale;
end;

function TResFile.TLangID.GetLang(idx: Integer): Word;
begin
  case idx of
    //0: Result := FLangID;
    1:   Result := Winapi.Windows.PRIMARYLANGID(FLangID);
    2:   Result := Winapi.Windows.SUBLANGID(FLangID);
    else Result := 0;
  end;
end;

class function TResFile.TLangID.GetLangID(LangName: string): TLangID;
begin
  Result.FLangID := LocaleNameToLCID(PChar(LangName), LOCALE_ALLOW_NEUTRAL_NAMES);
  if Result.FLangID = 0 then
    RaiseLastOSError;
  if Result.FLangID = LOCALE_CUSTOM_DEFAULT then
    Result := GetDefaultLangID;
end;

function TResFile.TLangID.GetName: string;
begin
  SetLength(Result, LOCALE_NAME_MAX_LENGTH);
  var Len := LCIDToLocaleName(FLangID, PChar(Result), LOCALE_NAME_MAX_LENGTH, LOCALE_ALLOW_NEUTRAL_NAMES);
  if Len = 0 then
    RaiseLastOSError;
  SetLength(Result, Len - 1);
end;

procedure TResFile.TLangID.SetLang(idx: Integer; Value: Word);
begin
  case idx of
    0: if Value = $FFFF then
         FLangID := GetDefaultLangID.FLangID
       else
         FLangID := Value;
    1:   FLangID := Winapi.Windows.MAKELANGID(Value, SubLanguage);
    2:   FLangID := Winapi.Windows.MAKELANGID(PrimaryLanguage, Value);
  end;
end;

procedure TResFile.TLangID.SetLangID(Primary, SubLang: Word);
begin
  FLangID := Winapi.Windows.MAKELANGID(Primary, SubLang);
end;

procedure TResFile.TLangID.SetName(Value: string);
begin
  Self := GetLangID(Value);
end;

{ TResFile.TVersion }

function TResFile.TVersion.GetStr: string;
begin
  Result := Format('%.2d.%.2d', [Major, Minor]);
end;

function TResFile.TVersion.GetVer: Single;
begin
  Result := Major + (Min(Minor, 99) / 100)
end;

procedure TResFile.TVersion.SetStr(Value: string);
begin
  Version := Single.Parse(Value, TFormatSettings.Invariant);
end;

procedure TResFile.TVersion.SetVer(Value: Single);
begin
  Major := Trunc(Value);
  Minor := Trunc(Frac(Value) * 100 + 0.0001);
end;

{ TResFile.TResource }

function TResFile.TResource.DataSize: Integer;
begin
  Result := Length(Data);
end;

function TResFile.TResource.GetInt(idx: Integer): Word;
begin
  case idx of
    0:   Result := Type_.Replace('#', '').ToInteger;
    1:   Result :=  Name.Replace('#', '').ToInteger;
    else Result := 0;
  end;
end;

function TResFile.TResource.GetNormalizedType: string;
begin
  var Index := IndexText(Type_, cDataTypes);
  if (Index >= 0) and (cDataTypes[Char(Index)] <> '') then
    Result := '#' + Index.ToString
  else
    Result := Type_;
end;

class operator TResFile.TResource.Initialize(out Dest: TResource);
begin
  Dest.Type_            := '';
  Dest.Name             := '';
  Dest.ResVersion.Raw   := 0;
  Dest.Flags            := 0; //TResFile.DefaultFlags;
  Dest.Language.FLangID := 0; //TResFile.DefaultLangID;
  Dest.Version.Raw      := 0; //TResFile.DefaultVersion;
  Dest.Characteristics  := 0; //TResFile.DefaultCharacter;
  Dest.Data             := nil;
end;

function TResFile.TResource.IsEmpty: Boolean;
begin
  Result := not Assigned(Data) and MatchStr(Name, ['', '#0']);
end;

function TResFile.TResource.IsInt(idx: Integer): Boolean;
var
  Dummy: Word;
begin
  case idx of
    0:   Result := Word.TryParse(GetNormalizedType.Replace('#', ''), Dummy);
    1:   Result := Word.TryParse(Name.Replace('#', ''), Dummy);
    else Result := False;
  end;
end;

procedure TResFile.TResource.NormalizeTypeAndDefaults;
var
  Index: Word;
begin
  if Word.TryParse(Type_.Replace('#', ''), Index) then begin
    if (Index <= Ord(High(cDataTypes))) and (cDataTypes[Char(Index)] <> '') then
      Type_ := cDataTypes[Char(Index)];
  end else begin
    SmallInt(Index) := IndexText(Type_, cDataTypes);
    if SmallInt(Index) >= 0 then
      Type_ := cDataTypes[Char(Index)];
  end;

  if Flags = $FFFF then
    Flags := TResFile.DefaultFlags;
  if Language.FLangID = $FFFF then
    Language := TResFile.DefaultLangID;
  if Language.FLangID = $FFFF then
    Language := TResFile.TLangID.GetDefaultLangID;
end;

procedure TResFile.TResource.ReadRecord(const FileData: TBytes; var Pos: Integer);
function GetPos(Size: Integer): Pointer;
  begin
    Result := PByte(FileData) + Pos;
    Inc(Pos, Size);
    if Pos > Length(FileData) then
      raise EReadError.CreateRes(@SReadPastEndOfStream) at ReturnAddress;
  end;
function GetString: string;
  begin
    Result := PWideChar(GetPos(2));
    GetPos(Length(Result) * 2);
    if Result = '' then
      raise EReadError.CreateRes(@SInvalidStringLength) at ReturnAddress;
  end;
function GetIndexString: string;
  begin
    var DataType := pWORD(GetPos(2))^;
    if DataType = MAXWORD then
      Result := '#' + pWORD(GetPos(2))^.ToString
    else begin
      Dec(Pos, 2);  // revert DataType
      Result := GetString;
    end;
  end;
procedure DataAlign;
  begin
    if Pos mod 4 <> 0 then
      Inc(Pos, 4 - Pos mod 4);
  end;
begin
  var HeaderStart  := Pos;
  var DataSize     := pDWORD(GetPos(4))^;
  var HeaderSize   := pDWORD(GetPos(4))^;

  Type_            := GetIndexString;
  DataAlign;
  Name             := GetIndexString;
  DataAlign;
  ResVersion.Raw   := pDWORD(GetPos(4))^;
  Flags            :=  pWORD(GetPos(2))^;
  Language.FLangID :=  pWORD(GetPos(2))^;
  Version.Raw      := pDWORD(GetPos(4))^;
  Characteristics  := pDWORD(GetPos(4))^;
  if Pos - HeaderStart <> HeaderSize then
    raise EReadError.CreateRes(@SReadError);
  NormalizeTypeAndDefaults;

  Data := Copy(FileData, Pos, DataSize);
  GetPos(DataSize);
  DataAlign;
end;

procedure TResFile.TResource.SetInt(idx: Integer; Value: Word);
begin
  case idx of
    0: Type_ := '#' + Value.ToString;
    1: Name  := '#' + Value.ToString;
  end;
end;

procedure TResFile.TResource.WriteRecord(var FileData: TBytes; var Pos: Integer);
function GetPos(Size: Integer): Pointer;
  begin
    Result := PByte(FileData) + Pos;
    Inc(Pos, Size);
    if Pos > Length(FileData) then
      SetLength(FileData, Pos + 65_000);
  end;
procedure WriteIndexString(Value: string);
  begin
    if StartsStr('#', Value) then begin
      pWORD(GetPos(2))^ := MAXWORD;
      pWORD(GetPos(2))^ := Value.Substring(1).ToInteger;
    end else begin
      if Value <> Value.Replace(#0, '') then
        raise EReadError.CreateRes(@SInvalidBinary) at ReturnAddress;
      var Bytes := TEncoding.Unicode.GetBytes(Value + #0);
      GetPos(0);
      Insert(Bytes, FileData, Pos);
      GetPos(Length(Bytes));
    end;
  end;
procedure DataAlign;
  begin
    if Pos mod 4 <> 0 then
      GetPos(4 - Pos mod 4);
  end;
begin
  var HeaderStart    := Pos;
  pDWORD(GetPos(4))^ := Length(Data);  // DataSize
  pDWORD(GetPos(4))^ := DWORD(-1);     // HeaderSize

  NormalizeTypeAndDefaults;
  WriteIndexString(GetNormalizedType);
  DataAlign;
  WriteIndexString(Name);
  DataAlign;
  pDWORD(GetPos(4))^ := ResVersion.Raw;
   pWORD(GetPos(2))^ := Flags;
   pWORD(GetPos(2))^ := Language.FLangID;
  pDWORD(GetPos(4))^ := Version.Raw;
  pDWORD(GetPos(4))^ := Characteristics;

  pDWORD(PByte(FileData) + HeaderStart + 4)^ := Pos - HeaderStart;

  GetPos(0);
  Insert(Data, FileData, Pos);
  GetPos(Length(Data));
  DataAlign;
end;

{ TResFile }

function TResFile.Add(Resource: TResource): Integer;
begin
  Resource.NormalizeTypeAndDefaults;
  if Resource.IsEmpty then
    Exit(-1);
  if IndexOf(Resource) >= 0 then
    raise EReadError.CreateRes(@SGenericDuplicateItem);
  Result := Length(Resources);
  Insert(Resource, Resources, Result);
end;

function TResFile.Add(&Type, Name: string; Data: TBytes; Language: LANGID; Flags: Word): Integer;
begin
  var Resource: TResource;
  Resource.Type_           := &Type;
  Resource.Name            := Name;
  Resource.ResVersion.Raw  := 0;
  Resource.Flags           := Flags;     // $FFFF => DefaultFlags
  Resource.Language.LangID := Language;  // $FFFF => DefaultLangID or TLangID.GetDefaultLangID
  Resource.Version         := DefaultVersion;
  Resource.Characteristics := DefaultCharacter;
  Resource.Data            := Data;
  Result := Add(Resource);
end;

function TResFile.Add(&Type: Integer; Name: string; Data: TBytes; Language: LANGID; Flags: Word): Integer;
begin
  Result := Add('#' + &Type.ToString, Name, Data, Language, Flags);
end;

function TResFile.Add(&Type, Name: Integer; Data: TBytes; Language: LANGID; Flags: Word): Integer;
begin
  Result := Add('#' + &Type.ToString, '#' + Name.ToString, Data, Language, Flags);
end;

class function TResFile.CheckIsPEFile(FileName: string): Boolean;
begin
  Result := not EndsText('.res', FileName) and FileExists(FileName);
  if Result then begin
    var TestFile := TFile.OpenRead(Filename);
    try
      var MagicBytes: array[0..1] of AnsiChar;
      Result := (TestFile.Read(MagicBytes, 2) = 2) and (MagicBytes = 'PE');
    finally
      TestFile.Free;
    end;
  end;
end;

procedure TResFile.Clear;
begin
  Self := Default(TResFile);
end;

constructor TResFile.Create(FileName: string);
begin
  Clear;
  if FileName <> '' then
    LoadFrom(FileName);
end;

class function TResFile.Create: TResFile;
begin
  Result := Default(TResFile);
end;

procedure TResFile.Delete(idx: Integer);
begin
  System.Delete(Resources, idx, 1);
end;

class function TResFile.EnumResLangProc(hModule: HMODULE; lpszType, lpszName: PChar; wIDLanguage: Word; lParam: NativeInt): BOOL;
var
  Type_, Name: string;
  ResStream:   TResourceStream;
  ResData:     TBytes;
begin
  if (lpszType <> nil) and (UIntPtr(lpszType) <= MAXWORD) then
    Type_ := '#' + IntPtr(lpszType).ToString else Type_ := lpszType;
  if (lpszName <> nil) and (UIntPtr(lpszName) <= MAXWORD) then
    Name  := '#' + IntPtr(lpszName).ToString else Name  := lpszName;

  if StartsStr('#', Name) then
    ResStream := TResourceStream.CreateFromID(hModule, IntPtr(lpszName), lpszType)
  else
    ResStream := TResourceStream.Create(hModule, Name, lpszType);
  try
    SetLength(ResData, ResStream.Size);
    ResStream.ReadBuffer(ResData, ResStream.Size);
    var Index := TResFile(Pointer(lParam)^).Add(Type_, Name, ResData, wIDLanguage);
    TResFile(Pointer(lParam)^).Resources[Index].SortOrder := ResStream.Memory;
  finally
    ResStream.Free;
  end;
  Result := True;
end;

class function TResFile.EnumResNameProc(hModule: HMODULE; lpszType, lpszName: PChar; lParam: NativeInt): BOOL;
begin
  if not EnumResourceLanguages(hModule, lpszType, lpszName, @EnumResLangProc, lParam) then
    RaiseLastOSError;
end;

class function TResFile.EnumResTypeProc(hModule: HMODULE; lpszType: PChar; lParam: NativeInt): BOOL;
begin
  if not EnumResourceNames(HInstance, lpszType, @EnumResNameProc, lParam) then
    RaiseLastOSError;
end;

function TResFile.IndexOf(&Type, Name: Integer; Language: LANGID; Flags: Word): Integer;
begin
  Result := IndexOf('#' + &Type.ToString, '#' + Name.ToString, Language, Flags);
end;

function TResFile.IndexOf(&Type: string; Name: Integer; Language: LANGID; Flags: Word): Integer;
begin
  Result := IndexOf(&Type, '#' + Name.ToString, Language, Flags);
end;

function TResFile.IndexOf(&Type, Name: string; Language: LANGID; Flags: Word): Integer;
begin
  var Resource: TResource;
  Resource.Type_           := &Type;
  Resource.Name            := Name;
  Resource.ResVersion.Raw  := 0;
  Resource.Flags           := Flags;     // $FFFF = ignore
  Resource.Language.LangID := Language;  // $FFFF = ignore
  Resource.Version         := DefaultVersion;
  Resource.Characteristics := DefaultCharacter;
  Resource.Data            := nil;
  Result := IndexOf(Resource);
end;

function TResFile.IndexOf(Resource: TResource; IgnoreLanguage: Boolean): Integer;
begin
  Result := -1;
  Resource.NormalizeTypeAndDefaults;
  if Resource.IsEmpty then
    Exit;
  var ResultMode := 8;
  for var idx := 0 to High(Resources) do begin
    Resources[idx].NormalizeTypeAndDefaults;
    if (Resources[idx].Type_ = Resource.Type_) and (Resources[idx].Name = Resource.Name) then
      if Resources[idx].Language.FLangID = Resource.Language.FLangID then
        Exit(idx)
      else
        if IgnoreLanguage and (Result < 0) then
          Result := idx;
  end;
end;

class operator TResFile.Initialize(out Dest: TResFile);
begin
  Dest.Resources             := nil;
  Dest.DefaultLangID.FLangID := $FFFF;
  Dest.DefaultVersion.Raw    := 0;
  Dest.DefaultFlags          := 0;
  Dest.DefaultCharacter      := 0;
end;

procedure TResFile.LoadFrom(FileData: TBytes);
begin
  FileData := Copy(FileData);
  var idx  := 0;
  var Pos  := 0;
  try
    SetLength(Resources, 10);
    Resources[0].ReadRecord(FileData, Pos);
    if (Pos <> 32{4+4 + 4+4 + 4+2+2+4+4}) or not Resources[0].IsEmpty then
      raise EReadError.CreateRes(@SInvalidImage);  // 16 bit resource files are not supported
    while Pos + 2 * SizeOf(DWORD) < Length(FileData) do begin
      if idx >= High(Resources) then
        SetLength(Resources, Length(Resources) + 25);
      Resources[idx].ReadRecord(FileData, Pos);
      if not Resources[idx].IsEmpty then
        Inc(idx);
    end;
  finally
    SetLength(Resources, idx);
  end;
end;

procedure TResFile.LoadMine;
begin
  Clear;
  if not EnumResourceTypes(HInstance, @EnumResTypeProc, IntPtr(@Self)) then
    RaiseLastOSError;
  SortEnumResources;
end;

function TResFile.ResCount: Integer;
begin
  Result := Length(Resources);
end;

class function TResFile.ResNameToStr(ResName: PChar): string;
begin
  if (ResName <> nil) and (UIntPtr(ResName) <= MAXWORD) then
    Result := '#' + IntPtr(ResName).ToString
  else
    Result := ResName;
end;

class function TResFile.ResTypeToStr(ResType: PChar): string;
begin
  if (ResType <> nil) and (UIntPtr(ResType) <= MAXWORD) then
    if (IntPtr(ResType) <= Ord(High(cDataTypes))) and (cDataTypes[Char(ResType)] <> '') then
      Result := cDataTypes[Char(ResType)]
    else
      Result := '#' + IntPtr(ResType).ToString
  else
    Result := ResType;
end;

procedure TResFile.LoadFrom(FileName: string);
begin
  if CheckIsPEFile(FileName) then begin
    var Module := LoadLibraryEx(PChar(FileName), 0, LOAD_LIBRARY_AS_DATAFILE);
    if Module = 0 then
      RaiseLastOSError;
    try
      Clear;
      if not EnumResourceTypes(Module, @EnumResTypeProc, IntPtr(@Self)) then
        RaiseLastOSError;
      SortEnumResources;
    finally
      FreeLibrary(Module);
    end;
  end else
    LoadFrom(TFile.ReadAllBytes(FileName));
end;

function TResFile.SaveTo: TBytes;
begin
  var Pos := 0;
  Result  := nil;
  try
    Default(TResource).WriteRecord(Result, Pos);  // empty record as marker for 32 bit resources
    for var idx := 0 to High(Resources) do begin
      Resources[idx].NormalizeTypeAndDefaults;
      if IndexOf(Resources[idx]) < idx then
        raise EReadError.CreateRes(@SGenericDuplicateItem);
      if not Resources[idx].IsEmpty then
        Resources[idx].WriteRecord(Result, Pos);
    end;
  finally
    SetLength(Result, Pos);
  end;
end;

procedure TResFile.SortEnumResources;
begin
  // Was loaded sorted by type, but I want them in the order they were saved/created.
  // EnumResourceTypes > EnumResourceNames > EnumResourceLanguages > FindResource > LoadResource
  for var a := 0 to High(Resources) - 1 do
    for var b := a + 1 to High(Resources) do
      if IntPtr(Resources[a].SortOrder) > IntPtr(Resources[b].SortOrder) then begin
        var Temp     := Resources[a];
        Resources[a] := Resources[b];
        Resources[b] := Temp;
      end;
end;

procedure TResFile.SaveTo(FileName: string; RemoveMissingFromPEFiles: Boolean);
begin
  if CheckIsPEFile(FileName) then begin
    var Success := True;
    var Module  := BeginUpdateResource(PChar(Filename), RemoveMissingFromPEFiles);
    if Module = 0 then
      RaiseLastOSError;
    try
      for var Index := 0 to High(Resources) do begin
        {$REGION 'resource info'}
        Resources[Index].NormalizeTypeAndDefaults;
        var Resource := Resources[Index];
        var ResTypeN := Resource.GetNormalizedType;
        var ResType  := PChar(ResTypeN);
        var ResName  := PChar(Resource.Name);
        var ResLang  := Resource.Language.LangID;
        var ResData  := Pointer(Resource.Data);
        var ResSize  := Resource.DataSize;
        if StartsStr('#', ResTypeN) then
          ResType := PChar(ResTypeN.Substring(1).ToInteger);
        if StartsStr('#', Resource.Name) then
          ResName := PChar(Resource.Name.Substring(1).ToInteger);
        {$ENDREGION}
        {$REGION 'check update'}
        var DoUpdate := RemoveMissingFromPEFiles;  // all resources were deleted during BeginUpdate
        if not RemoveMissingFromPEFiles then begin
          var ResInfo := FindResourceEx(Module, ResName, ResType, ResLang);
          if ResInfo = 0 then
            DoUpdate := True;
          var HGlobal := LoadResource(Module, ResInfo);
          if HGlobal = 0 then
            DoUpdate := True
          else
            try
              var _ResSize := SizeOfResource(Module, ResInfo);
              var _ResData := LockResource(HGlobal);
              if _ResData = nil then
                DoUpdate := True
              else
                DoUpdate := (ResSize <> Integer(_ResSize)) or CompareMem(ResData, _ResData, ResSize);
            finally
              UnlockResource(HGlobal);
              FreeResource(HGlobal);
            end;
        end;
        {$ENDREGION}
        if DoUpdate then
          if not UpdateResource(Module, ResType, ResName, ResLang, ResData, ResSize) then begin
            Success := False;
            Break;
          end;
      end;
    finally
      EndUpdateResource(Module, not Success);
    end;
  end else
    TFile.WriteAllBytes(FileName, SaveTo);
end;

end.

