/// <summary>FMX-Style-Overview</summary>
/// <remarks>Version: 1.0 2025-09-01<br />Copyright 2025 himitsu @ geheimniswelten<br />License: MPL v1.1 , GPL v3.0 or LGPL v3.0</remarks>
/// <seealso cref="http://geheimniswelten.de">Geheimniswelten</seealso>
/// <seealso cref="http://geheimniswelten.de/kontakt/#licenses">License Text</seealso>
/// <seealso cref="https://github.com/geheimniswelten/FMXStyleOverview">GitHub</seealso>
/// <dependence> h5u.ResFile 1.0 or 2.x </dependence>
unit FMXStyleOverviewMain;

interface

uses
  Winapi.Windows,  // for MessageBeep (inlined from Beep)
  Vcl.Dialogs,     // for TFileOpenDialog
  (*
  // Default-Styles importieren (aber ist eventuell nicht alles installiert und sowieso nicht im Suchpfad für Platform "Windows")
  // Daher siehe nachfolgend {$R ***.res}
  FMX.Controls.Win, FMX.Controls.Mac, FMX.Controls.iOS, FMX.Controls.Android,
  *)
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Grid.Style, FMX.StdCtrls, FMX.ImgList,
  FMX.Layouts, FMX.Controls.Presentation, FMX.ScrollBox, FMX.Grid, FMX.Header, FMX.Styles, FMX.Ani,
  FMX.Objects, FMX.Platform.Win, FMX.Memo.Types, FMX.Memo, FMX.Edit, FMX.TabControl, FMX.Menus, FMX.ExtCtrls,
  FMX.ListView.Types, FMX.ListView.Appearances, FMX.ListView.Adapters.Base, FMX.ListView, FMX.ListBox,
  //
  System.Types, System.UITypes, System.SysUtils, System.StrUtils, System.IOUtils, System.ImageList,
  System.Classes, System.Variants, System.Rtti, System.Math, System.Math.Vectors,
  //
  FMXStyleOverviewDemo, h5u.ResFile;

type
  TGrid = class(FMX.Grid.TGrid)
  public
    property OnEnter;
    property OnExit;
    property OnKeyDown;
  end;

  TFMXStyleOverviewForm = class(TForm)
    {$REGION 'Components'}
    DataGrid: TGrid;
    StylesList: TStyleBook;
    MemoDescription: TMemo;
    LayoutInfo: TLayout;
    LayoutPreview: TLayout;
    SplitterInfo: TSplitter;
    SplitterPreview: TSplitter;
    ExpanderViewOptions: TExpander;
    CheckBackground: TCheckBox;
    CheckFullBackground: TCheckBox;
    CheckAsComponent: TCheckBox;
    CheckFixed: TCheckBox;
    LayoutLeft: TLayout;
    LayoutSearch: TLayout;
    EditSearch: TEdit;
    ButtonSearchDown: TButton;
    ButtonSearchUp: TButton;
    CheckDemoForm: TCheckBox;
    LayoutStyles: TLayout;
    ListPlatforms: TListBox;
    LayoutPrevTabs: TLayout;
    TabControlPreview: TTabControl;
    TabItemCode: TTabItem;
    TabItemTree: TTabItem;
    TabItemPreview: TTabItem;
    MemoPreviewCode: TMemo;
    LabelPreviewHint: TLabel;
    ButtonLoad: TButton;
    ButtonSave: TButton;
    DropTarget1: TDropTarget;
    PopupLoad: TPopupMenu;
    PopupSave: TPopupMenu;
    MenuLoadFolder: TMenuItem;
    MenuLoadFile: TMenuItem;
    MenuItemSave: TMenuItem;
    SaveDialog: TSaveDialog;
    OpenDialog: TOpenDialog;
    Label1: TLabel;
    ImagesOS: TImageList;
    {$ENDREGION}
    {$REGION 'Events'}
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure DataGridEnter(Sender: TObject);
    procedure DataGridKeyDown(Sender: TObject; var Key: Word; var KeyChar: WideChar; Shift: TShiftState);
    procedure DataGridGetValue(Sender: TObject; const ACol, ARow: Integer; var Value: TValue);
    procedure DataGridDrawColumnHeader(Sender: TObject; const Canvas: TCanvas; const Column: TColumn; const Bounds: TRectF);
    procedure DataGridDrawColumnCell(Sender: TObject; const Canvas: TCanvas; const Column: TColumn; const Bounds: TRectF; const Row: Integer; const Value: TValue; const State: TGridDrawStates);
    procedure DataGridSelectCell(Sender: TObject; const ACol, ARow: Integer; var CanSelect: Boolean);
    procedure CheckFixedChange(Sender: TObject);
    procedure CheckBackgroundChange(Sender: TObject);
    procedure ExpanderViewOptionsExpandedChanged(Sender: TObject);
    procedure ExpanderViewOptionsMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
    procedure CheckAsComponentChange(Sender: TObject);
    procedure CheckDemoFormChange(Sender: TObject);
    procedure EditSearchChange(Sender: TObject);
    procedure EditSearchKeyDown(Sender: TObject; var Key: Word; var KeyChar: WideChar; Shift: TShiftState);
    procedure LayoutPrevTabsResized(Sender: TObject);
    procedure MenuLoadClick(Sender: TObject);
    procedure MenuItemSaveClick(Sender: TObject);
    procedure ButtonLoadSaveClick(Sender: TObject);
    procedure DropTarget1Dropped(Sender: TObject; const Data: TDragObject; const Point: TPointF);
    procedure DropTarget1DragOver(Sender: TObject; const Data: TDragObject; const Point: TPointF; var Operation: TDragOperation);
    {$ENDREGION}
  private type
    TStyleInfo = record
      Source:   TArray<string>;       // Filename(s)
      System:   TArray<string>;       // Platform
      Images:   TArray<string>;       // TImage im Rootpfad des Style
      Descr:    string;
      SysImage: Integer;              // Platform-HeaderImage
      FileData: TBytes;
      //Found:  TArray<Boolean>;      // see FStyleFound
      //Fixed:  TArray<TAdjustType>;  // see FStyleFixed (FixedSize/FixedWidth/FixedHeight)
    end;
  private
    FStyleInfos: TArray<TStyleInfo>;           // [FileIdx]
    FStyleNames: TArray<string>;               // [StyleIdx]
    FStyleFound: TArray<TArray<Boolean>>;      // [StyleIdx, FileIdx]
    FStyleFixed: TArray<TArray<TAdjustType>>;  // [StyleIdx, FileIdx]
    FStyleSort:  Integer;         // Offset statischer Plattformnamen
    FDelphiDir:  string;
    FDemoSizes:  TArray<TRectF>;  // beim Laden der Styles werden komponenten in der Größe verändert, aber beim Entfernen des Styles nicht wiederhergestellt.
    FDemoMoved:  Boolean;         // beim ersten Anzeigen der Demo wir die Mainform verschoben
    FLockCell:   TPoint;          // für Sperre während Application.ProcessMessages
    procedure BuildFolderList;
    function  OpenFolderDialog(InitialFolder: string): TArray<string>;
    function  FindStyleFiles(FolderName: string): TArray<string>;
    procedure InitGridAndStyleBook;
    procedure LoadDefaultStyles;
    procedure LoadStyleFile(FileData: TBytesStream; Source, Header: string); overload;
    procedure LoadStyleFile(FileName: string); overload;
    procedure AddStyleNames(Style: TFmxObject; FileIdx: Integer);
    procedure AddPlatformNames(PlatformTarget: string; var Platforms: TArray<string>);

    function  TrimFill(Value: string; Len: Integer=45): string;
    procedure ListPlatformsItemPaint(Sender: TObject; Canvas: TCanvas; const ARect: TRectF);
  end;

var
  FMXStyleOverviewForm: TFMXStyleOverviewForm;

implementation

{$R *.fmx}

{.$R Resources\FMX.Controls.Win.res}     // C:\Program Files (x86)\Embarcadero\Studio\23.0\lib\win32\release
{$R Resources\FMX.Controls.Mac.res}      // C:\Program Files (x86)\Embarcadero\Studio\23.0\lib\osxarm64\release
{$R Resources\FMX.Controls.iOS.res}      // C:\Program Files (x86)\Embarcadero\Studio\23.0\lib\iossimarm64\release
{$R Resources\FMX.Controls.Android.res}  // C:\Program Files (x86)\Embarcadero\Studio\23.0\lib\android\release

(*
const
  // leider liegen sie nicht direkt auf der Festplatte, drum aus den Ressourcen laden
  DefaultStyles: array[0..8] of array[0..1] of string = (
    ('win7style',      'FMX.Controls.Win.rc :Win7.fsf'),
    ('win8style',      'FMX.Controls.Win.rc :Win8.fsf'),
    ('win10style',     'FMX.Controls.Win.rc :Win10.fsf'),
    ('win11style',     'FMX.Controls.Win.rc :Win11.fsf'),
    ('osxstyle',       'FMX.Controls.Mac.rc :Yosemite.fsf'),
    ('lionstyle',      'FMX.Controls.Mac.rc :Lion.fsf'),
    ('iosstyle',       'FMX.Controls.iOS.res'),
    ('ios13darkstyle', 'FMX.Controls.iOS.res'),
    ('androidstyle',   'FMX.Controls.Android.res')
  );
*)

type
  TFmxObjectAccess = class(TFmxObject);
  TStyleBookAccess = class(TStyleBook);

procedure TFMXStyleOverviewForm.AddPlatformNames(PlatformTarget: string; var Platforms: TArray<string>);
begin
  Platforms := PlatformTarget.Trim.ToUpper.Replace(',', '').Replace('][', ']*[').Split(['*']);

  // add to list
  for var P in Platforms do
    if ListPlatforms.Items.IndexOf(P) < 0 then
      ListPlatforms.Items.Add(P);
  // sort (excluding default platforms)
  for var A := FStyleSort to ListPlatforms.Items.Count - 2 do
    for var B := A + 1 to ListPlatforms.Items.Count - 1 do
      if ListPlatforms.Items[A].Replace(']', '') > ListPlatforms.Items[B].Replace(']', '') then
        ListPlatforms.Items.Move(B, A);
  // custom draw event
  for var A := 0 to ListPlatforms.Items.Count - 1 do
    ListPlatforms.ListItems[A].OnPaint := ListPlatformsItemPaint;
end;

procedure TFMXStyleOverviewForm.AddStyleNames(Style: TFmxObject; FileIdx: Integer);
begin
  if Style is TStyleDescription then
    Exit;
  if (Style is TImage) and (Style.ChildrenCount = 0) then begin
    FStyleInfos[FileIdx].Images := FStyleInfos[FileIdx].Images + [Style.StyleName];
    Exit;
  end;

  if Style.StyleName <> '' then begin
    var FileCount := Length(FStyleInfos);
    var StyleIdx  := -1;
    var StyleNam  := Style.StyleName.ToLower;
    var NewStyle  := Length(FStyleNames);
    for var idx := 0 to High(FStyleNames) do
      if FStyleNames[idx] = StyleNam then begin
        StyleIdx := idx;
        Break;
      end else if FStyleNames[idx] > StyleNam then begin
        NewStyle := idx;
        Break;
      end;
    if StyleIdx < 0 then begin
      StyleIdx := NewStyle;
      Insert(StyleNam, FStyleNames, StyleIdx);
      Insert([nil], FStyleFound, StyleIdx);
      Insert([nil], FStyleFixed, StyleIdx);
      SetLength(FStyleFound[StyleIdx], FileCount);
      SetLength(FStyleFixed[StyleIdx], FileCount);
      DataGrid.RowCount := Length(FStyleNames);
    end;
    FStyleFound[StyleIdx, FileIdx] := True;

    FStyleFixed[StyleIdx, FileIdx] := TAdjustType.None;
    if Style is TControl then
      if TControl(Style).FixedSize.Width <> 0 then
        if TControl(Style).FixedSize.Height <> 0 then
          FStyleFixed[StyleIdx, FileIdx] := TAdjustType.FixedSize
        else
          FStyleFixed[StyleIdx, FileIdx] := TAdjustType.FixedWidth
      else
        if TControl(Style).FixedSize.Height <> 0 then
          FStyleFixed[StyleIdx, FileIdx] := TAdjustType.FixedHeight
        else
          FStyleFixed[StyleIdx, FileIdx] := TAdjustType.None;

  end else  // ELSE: nur die StyleRessourcen finden, keine SubStyles (Einzelteile sind oft ebenfalls benamt, wie z.B. 'background')
    if TFmxObjectAccess(Style).SearchInto then
      for var idx := 0 to Style.ChildrenCount - 1 do
        AddStyleNames(Style.Children[idx], FileIdx)
end;

procedure TFMXStyleOverviewForm.BuildFolderList;
begin
  var InitFolder := PopupLoad.ItemsCount;

  for var Version := 35 downto 10 do begin
    var IDEPath := Format('C:\Users\Public\Documents\Embarcadero\Studio\%d.0\Styles', [Version]);
    if DirectoryExists(IDEPath) then begin
      var MenuItem       := TMenuItem.Create(PopupLoad);
      MenuItem.Parent    := PopupLoad;
      MenuItem.Text      := Format('Public %d.0', [Version]);
      MenuItem.TagString := IDEPath;
      MenuItem.OnClick   := MenuLoadClick;
    end;
  end;
  begin
    var MenuItem       := TMenuItem.Create(PopupLoad);
    MenuItem.Parent    := PopupLoad;
    MenuItem.Text      := 'Public ALL';
    MenuItem.TagString := 'C:\Users\Public\Documents\Embarcadero\Studio';
    MenuItem.OnClick   := MenuLoadClick;
  end;
  for var Version := 35 downto 10 do begin
    var IDEPath := Format('C:\Program Files (x86)\Embarcadero\Studio\%d.0\Redist\styles\Fmx', [Version]);
    if DirectoryExists(IDEPath) then begin
      var MenuItem       := TMenuItem.Create(PopupLoad);
      MenuItem.Parent    := PopupLoad;
      MenuItem.Text      := Format('Redist %d.0', [Version]);
      MenuItem.TagString := IDEPath;
      MenuItem.OnClick   := MenuLoadClick;
    end;
    if FDelphiDir = '' then begin
      IDEPath := ExtractFileDir(ExtractFileDir(ExtractFileDir(IDEPath)));
      if DirectoryExists(IDEPath) then
        FDelphiDir := IDEPath;
    end;
  end;

  OpenDialog.InitialDir := PopupLoad.Items[InitFolder].TagString;
end;

procedure TFMXStyleOverviewForm.ButtonLoadSaveClick(Sender: TObject);
begin
  var PopupPos   := PointF(0, TButton(Sender).Height + 1);
  var PopupPoint := TButton(Sender).LocalToScreen(PopupPos);
  TButton(Sender).PopupMenu.Popup(PopupPoint.X, PopupPoint.Y)
end;

procedure TFMXStyleOverviewForm.CheckAsComponentChange(Sender: TObject);
begin
  // not implemented yet
end;

procedure TFMXStyleOverviewForm.CheckBackgroundChange(Sender: TObject);
begin
  CheckBackground.OnChange     := nil;
  CheckFullBackground.OnChange := nil;
  try
    if Sender = CheckBackground     then CheckFullBackground.IsChecked := False;
    if Sender = CheckFullBackground then CheckBackground.IsChecked     := not CheckFullBackground.IsChecked;
  finally
    CheckBackground.OnChange     := CheckBackgroundChange;
    CheckFullBackground.OnChange := CheckBackgroundChange;
  end;

  var Dummy := True;
  DataGridSelectCell(DataGrid, DataGrid.ColumnIndex, DataGrid.Row, Dummy);
end;

procedure TFMXStyleOverviewForm.CheckDemoFormChange(Sender: TObject);
begin
  if CheckDemoForm.IsChecked then begin
    if not FMXStyleDemoForm.Visible then begin
      if not FDemoMoved then begin
        var Display := Screen.DisplayFromRect(Self.Bounds);  // Warum kein Property TForm.Display|Screen|Monitor?
        Self.Left   := Max(Round(Display.Workarea.Left + 5),
                           Self.Left - FMXStyleDemoForm.Width div 2 - 10);
        if Self.Width > Display.Workarea.Width - FMXStyleDemoForm.Width - 25 then
          Self.Width := Max(800, Round(Display.Workarea.Width) - FMXStyleDemoForm.Width - 25);
        FDemoMoved  := True;
      end;
      FMXStyleDemoForm.Left := Self.Bounds.Right + 10;
      FMXStyleDemoForm.Top  := Max(Self.Top, Self.Top + (Self.Height - FMXStyleDemoForm.Height) div 2);
    end;

    FMXStyleDemoForm.BeginUpdate;
    try
      FMXStyleDemoForm.StyleBook := nil;
      FMXStyleDemoForm.StyleName := '';
      FMXStyleDemoForm.Tag       := -1;
      CheckSynchronize;
//      {}FLockCell.X := DataGrid.ColumnIndex; FLockCell.Y := DataGrid.Row; try
//      {CheckSynchronize;} Application.ProcessMessages;  // Einiges läuft verzögert, z.B. in TStyledControl.KillResourceLink via ForceQueue
//      {}finally FLockCell.X := -1; end;
      for var idx := High(FDemoSizes) downto 0 do
        if FMXStyleDemoForm.Components[idx] is TControl then begin
          var Control := TControl(FMXStyleDemoForm.Components[idx]);
          Control.FixedSize  := TSize.Create(0, 0);
          {}Control.Width    := FDemoSizes[idx].Width + 5;  // kurz ändern, damit die innere Darstellungsgröße neu berechnet wird, oder so?
          Control.BoundsRect := FDemoSizes[idx];
          TButton(Control).Scale.Point := PointF(1, 1);
          {}Control.InvalidateRect(Control.BoundsRect);
        end;

      if (DataGrid.ColumnIndex > 0) and (DataGrid.ColumnIndex < StylesList.Styles.Count) then begin
        //FMXStyleDemoForm.StyleBook := nil;
        //FMXStyleDemoForm.StyleName := StylesList.Styles[DataGrid.ColumnIndex].Platform;
        //FMXStyleDemoForm.StyleBook := StylesList;
        FMXStyleDemoForm.StyleBook := nil;
        FMXStyleDemoForm.StyleBookDemo.Styles.Clear;
        CheckSynchronize;//Application.ProcessMessages;
        var StyleItem  := FMXStyleDemoForm.StyleBookDemo.Styles.Add;
        var StyleClone := StylesList.Styles[DataGrid.ColumnIndex].Style.Clone(StyleItem.Style);
        StyleItem.Style.AddObject(StyleClone);
        FMXStyleDemoForm.StyleName := '';
        FMXStyleDemoForm.StyleBook := FMXStyleDemoForm.StyleBookDemo;
        FMXStyleDemoForm.Tag       := DataGrid.ColumnIndex;
      end;

      CheckSynchronize;
      Application.ProcessMessages;
      for var idx := High(FDemoSizes) downto 0 do
        if FMXStyleDemoForm.Components[idx] is TControl then begin
          var Control := TControl(FMXStyleDemoForm.Components[idx]);
          Control.FixedSize  := TSize.Create(0, 0);
          {}Control.Width    := FDemoSizes[idx].Width + 2;  // kurz ändern, damit die innere Darstellungsgröße neu berechnet wird, oder so?
          Control.BoundsRect := FDemoSizes[idx];
          TButton(Control).Scale.Point := PointF(1, 1);
          Control.InvalidateRect(Control.BoundsRect);
          if Control is TPresentedControl then
            TPresentedControl(Control).ApplyStyleLookup;
        end;

      FMXStyleDemoForm.Button8.ApplyStyleLookup;
      FMXStyleDemoForm.Button16.ApplyStyleLookup;
      var ButtonScale := 32 / Max(FMXStyleDemoForm.Button8.Height, FMXStyleDemoForm.Button16.Height);
      FMXStyleDemoForm.LabelToolButtonScale.Text := Round(ButtonScale * 100).ToString + ' %';
      for var idx := FMXStyleDemoForm.GroupToolButtons.ControlsCount - 1 downto 0 do
        if FMXStyleDemoForm.GroupToolButtons.Controls[idx] is TButton then begin
          var Control := TButton(FMXStyleDemoForm.GroupToolButtons.Controls[idx]);
          Control.Scale.Point := PointF(ButtonScale, ButtonScale);
        end;
    finally
      FMXStyleDemoForm.EndUpdate;
      FMXStyleDemoForm.Visible := True;
    end;
  end else begin
    FMXStyleDemoForm.Hide;
    FMXStyleDemoForm.StyleBook := nil;
    FMXStyleDemoForm.StyleName := '';
    FMXStyleDemoForm.Tag       := -1;
  end;
end;

procedure TFMXStyleOverviewForm.CheckFixedChange(Sender: TObject);
begin
  DataGrid.Repaint;
end;

procedure TFMXStyleOverviewForm.EditSearchChange(Sender: TObject);
begin
  var idx  := DataGrid.Row;
  var Loop := Length(FStyleNames);
  if (Sender = EditSearch) and (idx >= 0) and (idx < Length(FStyleNames))
      and ContainsText(FStyleNames[idx], EditSearch.Text) then begin
    DataGrid.Repaint;
    Exit;
  end;
  while (Loop >= 0) and Assigned(FStyleNames) do begin
    Dec(Loop);
    if Sender = ButtonSearchUp then
      if idx > 0 then
        Dec(idx)
      else
        idx := High(FStyleNames)
    else
      if idx < High(FStyleNames) then
        Inc(idx)
      else
        idx := 0;
    if ContainsText(FStyleNames[idx], EditSearch.Text) then begin
      DataGrid.Row := idx;
      DataGrid.Repaint;
      Exit;
    end;
  end;
  DataGrid.Repaint;
  Beep;
end;

procedure TFMXStyleOverviewForm.EditSearchKeyDown(Sender: TObject; var Key: Word; var KeyChar: WideChar; Shift: TShiftState);
begin
  if Key = vkReturn then
    EditSearchChange(nil);
end;

procedure TFMXStyleOverviewForm.ExpanderViewOptionsExpandedChanged(Sender: TObject);
begin
  if ExpanderViewOptions.IsExpanded then begin
    CheckDemoForm.Position.Y := CheckAsComponent.LocalToAbsolute(Point(0, 0)).Y + 32;
    CheckFixed.Position.Y    := ExpanderViewOptions.BoundsRect.Bottom - CheckFixed.Height - 10;
    CheckFixed.Visible       := True;
    CheckDemoForm.Visible    := True;
  end else begin
    CheckDemoForm.Position.Y := ExpanderViewOptions.BoundsRect.Bottom + 10;
    CheckFixed.Position.Y    := ExpanderViewOptions.BoundsRect.Bottom + 35;
  end;

  if Self.Visible then
    if ExpanderViewOptions.IsExpanded then
      CheckBackground.SetFocus
    else
      DataGrid.SetFocus;
end;

procedure TFMXStyleOverviewForm.ExpanderViewOptionsMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
  if Y < ExpanderViewOptions.cDefaultHeaderHeight then begin
    ExpanderViewOptions.IsExpanded := not ExpanderViewOptions.IsExpanded;
    Abort;
  end;
end;

function TFMXStyleOverviewForm.FindStyleFiles(FolderName: string): TArray<string>;
begin
  Caption := 'searching...';
  Result := TDirectory.GetFiles(FolderName, '*.*', TSearchOption.soAllDirectories,
    function(const Path: string; const SearchRec: TSearchRec): Boolean
    begin
      Result := EndsText('.style', SearchRec.Name) or EndsText('.fsf', SearchRec.Name);
    end);
end;

procedure TFMXStyleOverviewForm.FormCreate(Sender: TObject);
begin
  FLockCell.X := -1;

  Height := Round(Screen.WorkAreaHeight - 20);
  Width  := 1333;

  DataGrid.OnEnter               := DataGridEnter;  // not public/published
  DataGrid.OnKeyDown             := DataGridKeyDown;
  LabelPreviewHint.Align         := TAlignLayout.Top;
  LabelPreviewHint.Parent        := nil;  // LabelPreviewHint.Hide;
  MemoPreviewCode.Align          := TAlignLayout.Client;
  MemoPreviewCode.Parent         := nil;  // MemoPreviewCode.Hide;
  MemoDescription.Lines.Clear;
  ExpanderViewOptions.IsExpanded := False;
  TabControlPreview.ActiveTab    := TabItemPreview;
  TabControlPreview.Width        := LayoutPrevTabs.Height;     // Align funktioniert bei Rotated nicht "richtig"
  LayoutPrevTabs.Width           := TabControlPreview.Height;  //
  CheckBackgroundChange(nil);
end;

procedure TFMXStyleOverviewForm.FormShow(Sender: TObject);
begin
  OnShow := nil;

  FStyleSort := ListPlatforms.Items.Count;

  // Standard-Größe aller DemoControls speichern (für Wiederherstellung nach Entladen/Wechsel des Styles)
  SetLength(FDemoSizes,  FMXStyleDemoForm.ComponentCount);
  for var idx := FMXStyleDemoForm.ComponentCount - 1 downto 0 do
    if FMXStyleDemoForm.Components[idx] is TControl then
      FDemoSizes[idx] := (FMXStyleDemoForm.Components[idx] as TControl).BoundsRect;

  DataGrid.Enabled := False;
  DataGrid.BeginUpdate;
  try
    BuildFolderList;
    InitGridAndStyleBook;
    if FMX.Dialogs.MessageDlg('Load Default-Styles?', TMsgDlgType.mtConfirmation, [mbYes, mbNo], 0, mbYes) = mrYes then
      LoadDefaultStyles;
    if not Application.Terminated then
      MenuLoadClick(MenuLoadFolder);
  finally
    Caption := 'FMX-Style-Overview';
    DataGrid.EndUpdate;
    DataGrid.Enabled := True;
    DataGrid.SetFocus;
    if Length(FStyleInfos) <= 1 then
      ExpanderViewOptions.IsExpanded := True;
  end;
end;

procedure TFMXStyleOverviewForm.InitGridAndStyleBook;
begin
  SetLength(FStyleInfos, 1);
  SetLength(FStyleNames, 0);
  SetLength(FStyleFound, 0, 1);
  SetLength(FStyleFixed, 0, 1);

  StylesList.Clear;
  StylesList.Styles.Add.Platform := '';  // Empty (Default) Style : damit bei Zuweisung an die Form nicht ausversehn irgendwas verwendet wird.

  DataGrid.ClearColumns;
  DataGrid.RowCount := 0;

  var Col := TStringColumn.Create(DataGrid);
  Col.Header := 'Styles';
  Col.Width  := 200;
  DataGrid.AddObject(Col);

  DataGrid.ApplyStyleLookup;
  var Header := DataGrid.FindStyleResource('header') as THeader;
  if Assigned(Header) then  // ~geht~ ging noch nicht im OnCreate und auch nicht im OnShow oder leicht verzögert im ForceQueue
    Header.Height := 140
  else
    raise Exception.Create('DataGrid-HeaderStyle');

  // damit sich in TStyleCollectionItem.LoadFromStream die Styles für alle Plattformen laden lassen
  // https://www.delphipraxis.net/217749-fmx-style-dateien-auslesen-und-ressourcen-enumerieren.html
  TStyleBookAccess(StylesList).SetDesigning(True);
end;

procedure TFMXStyleOverviewForm.DataGridDrawColumnCell(Sender: TObject; const Canvas: TCanvas; const Column: TColumn; const Bounds: TRectF; const Row: Integer; const Value: TValue; const State: TGridDrawStates);
begin
  if Column.Index = 0 then begin
    (*
    // Border
    Canvas.Fill.Kind := TBrushKind.Solid;
    Canvas.Fill.Color := TAlphaColorRec.Dimgray;
    Canvas.FillRect(Bounds, 1);

    // Background
    Canvas.Fill.Color := TAlphaColorRec.Whitesmoke;
    Canvas.FillRect(Bounds, 1);  // selbst ohne Offset wird es viel zu klein gemalt, mit mehrern Pixeln Rahmen drumrum, auch bei positivem Offest

    // Text
    Canvas.Fill.Color := TAlphaColors.Black;
    Canvas.FillText(Bounds, Value.ToString, True, 1, [], TTextAlign.Leading, TTextAlign.Center);
    *)
    if (EditSearch.Text <> '') and ContainsText(Value.ToString, EditSearch.Text) then begin
      Canvas.Fill.Color := TAlphaColors.Red;
      Canvas.FillText(Bounds, Value.ToString, True, 1, [], TTextAlign.Leading, TTextAlign.Center);
    end;
  end else begin
    var CustomDraw := False;
    if CheckFixed.IsChecked then begin
      Bounds.Offset(1, 1);
      case FStyleFixed[Row, Column.Index - 1] of
        TAdjustType.FixedSize: begin
          Canvas.Fill.Color := TAlphaColorRec.Red;
          Canvas.FillPolygon([Bounds.BottomRight, PointF(Bounds.Right, Bounds.Top),
            PointF(Bounds.Right - Bounds.Height, Bounds.Bottom)], 0.25);
        end;
        TAdjustType.FixedWidth: begin
          Canvas.Fill.Color := TAlphaColorRec.Red;
          Canvas.FillRect(TRectF.Create(PointF(Bounds.Right - Bounds.Height,
            Bounds.Top + Bounds.Height / 2 + 3), Bounds.BottomRight), 0.25);
        end;
        TAdjustType.FixedHeight: begin
          Canvas.Fill.Color := TAlphaColorRec.Red;
          Canvas.FillRect(TRectF.Create(PointF(Bounds.Right - Bounds.Height / 2 + 3,
            Bounds.Top), Bounds.BottomRight), 0.25);
        end;
      end;
      Bounds.Offset(-1, -1);
      CustomDraw := True;
    end else begin
      // DataGrid.DefaultDrawing muß True bleiben, sonst werden die CheckBoxen nicht mehr gemalt, auch nicht mit Column.DefaultDrawCell
      //CustomDraw := True;  // nicht nötig, weil DefaultDrawing=True
    end;

    var _State := State;
    if (Column.Index > 0) and (Column.Index = DataGrid.ColumnIndex) and (Row <> DataGrid.Selected) then begin
      //_State := _State + [TGridDrawState.RowSelected];
      //CustomDraw := True;
      // am Liebsten würde ich den Hintergrund färben/übermalen, aber da sich die Checkboxen nicht manuell malen lassen .....
      { TODO : eventuell TCheckCell.DrawCell direkt aufrufen? }
      var CellBounds := Bounds;
      CellBounds.Inflate(+4, +4, +4, +4);
      Canvas.Fill.Color := TAlphaColorRec.Gray;
      Canvas.FillRect(CellBounds, 0.15);
    end;

    if CustomDraw then
      Column.DefaultDrawCell(Canvas, Bounds, Row, Value, _State);
  end;
end;

procedure TFMXStyleOverviewForm.DataGridDrawColumnHeader(Sender: TObject; const Canvas: TCanvas; const Column: TColumn; const Bounds: TRectF);
begin
  var OptionsVisible := ExpanderViewOptions.IsExpanded
    or not DataGrid.HScrollBar.IsVisible or (DataGrid.HScrollBar.Value < 20);
  CheckDemoForm.Visible := OptionsVisible;
  CheckFixed.Visible    := OptionsVisible;

  // Border
  Canvas.Fill.Kind := TBrushKind.Solid;
  Canvas.Fill.Color := TAlphaColorRec.Dimgray;
  Canvas.FillRect(Bounds, 1);

  // Background
  var TextBounds := Bounds;
  TextBounds.Inflate(0, 0, -0.25, -0.25);
  Canvas.Fill.Color := TAlphaColorRec.Whitesmoke;
  Canvas.FillRect(TextBounds, 1);

  // Text
  if Column.Index = 0 then begin  // Fixed-Column-Header
    TextBounds.Inflate(-4, -2, -1.75, -3.75);
    Canvas.Fill.Color := TAlphaColors.Black;
    Canvas.FillText(TextBounds, Column.Header, True, 1, [], TTextAlign.Leading, TTextAlign.Trailing);
  end else begin  // CheckBox-Column-Header
    TextBounds.Inflate(-1, -1, -1.75, -1.75);
    if FStyleInfos[Column.Index].SysImage >= 0 then begin
      var ImageBounds := RectF(TextBounds.Left, TextBounds.Bottom - 21, TextBounds.Right, TextBounds.Bottom - 3);
      ImagesOS.Draw(Canvas, ImageBounds, FStyleInfos[Column.Index].SysImage);
    end;
    TextBounds.Inflate(0, 0, 0, -21);
    var TextRect := RectF(3, 0, TextBounds.Height, TextBounds.Width);
    var TxMatrix := TMatrix.CreateRotation(DegToRad(-90));
    var MxBackup := Canvas.Matrix;
    TxMatrix.m31 := TextBounds.Left   + Canvas.Matrix.m31;  // TGrid nutzt selbst eine Matrix, für Column-Position, drum muß sie mit eingerechnet werden.
    TxMatrix.m32 := TextBounds.Bottom + Canvas.Matrix.m32;
    Canvas.SetMatrix(TxMatrix);
    Canvas.Fill.Color := TAlphaColors.Black;
    Canvas.FillText(TextRect, Column.Header, {True}False, 1, [], TTextAlign.Leading, TTextAlign.Center);
    Canvas.SetMatrix({TMatrix.Identity}MxBackup);
  end;
end;

procedure TFMXStyleOverviewForm.DataGridEnter(Sender: TObject);
begin
  ExpanderViewOptions.IsExpanded := False;
end;

procedure TFMXStyleOverviewForm.DataGridGetValue(Sender: TObject; const ACol, ARow: Integer; var Value: TValue);
begin
  if ACol = 0 then
    Value := FStyleNames[ARow]
  else
    Value := FStyleFound[ARow, ACol];
end;

procedure TFMXStyleOverviewForm.DataGridKeyDown(Sender: TObject; var Key: Word; var KeyChar: WideChar; Shift: TShiftState);
begin
  if FLockCell.X >= 0 then
    Exit;

  // gehe zu nächstem Style (überspringe leere Zellen)
  if (Shift = [ssShift]) and (Key in [vkLeft..vkDown]) then begin
    var CellLoop := (DataGrid.ColumnCount - 1) * DataGrid.RowCount;
    if Key in [vkUp, vkDown] then begin
      CellLoop := DataGrid.RowCount;
      if DataGrid.ColumnIndex = 0 then
        DataGrid.ColumnIndex := 1;
    end;
    while True do begin
      case Key of
        vkLeft:
          if DataGrid.ColumnIndex <= 1 then begin
            DataGrid.ColumnIndex := DataGrid.ColumnCount - 1;
            if DataGrid.Row = 0 then
              DataGrid.Row := DataGrid.RowCount - 1
            else
              DataGrid.Row := DataGrid.Row - 1;
          end else
            DataGrid.ColumnIndex := DataGrid.ColumnIndex - 1;
        vkRight:
          if DataGrid.ColumnIndex = DataGrid.ColumnCount - 1 then begin
            DataGrid.ColumnIndex := 1;
            if DataGrid.Row = DataGrid.RowCount - 1 then
              DataGrid.Row := 0
            else
              DataGrid.Row := DataGrid.Row + 1;
          end else
            DataGrid.ColumnIndex := DataGrid.ColumnIndex + 1;
        vkUp:
          if DataGrid.Row = 0 then
            DataGrid.Row := DataGrid.RowCount - 1
          else
            DataGrid.Row := DataGrid.Row - 1;
        vkDown:
          if DataGrid.Row = DataGrid.RowCount - 1 then
            DataGrid.Row := 0
          else
            DataGrid.Row := DataGrid.Row + 1;
      end;
      if FStyleFound[DataGrid.Row, DataGrid.ColumnIndex] then
        Break;
      Dec(CellLoop);
      if CellLoop = 0 then begin
        Beep;
        Break;
      end;
    end;
    DataGrid.ScrollToSelectedCell;
    Key := 0;
  end;

  case KeyChar of
    'a'..'z':
      EditSearch.Text := EditSearch.Text + KeyChar;
    'A'..'Z':
      EditSearch.Text := EditSearch.Text + Char(Ord(Key) and not $0020);
    #0:  ;
    else Exit;
  end;
  case Key of
    //Ord('A')..Ord('Z'):
    //  EditSearch.Text := EditSearch.Text + Char(Key and not $0020);
    vkBack, vkDelete{Entf}:
      EditSearch.Text := LeftStr(EditSearch.Text, Length(EditSearch.Text) - 1);
    vkEscape:
      EditSearch.Text := '';
    0:   ;
    else Exit;
  end;
  Key     := 0;
  KeyChar := #0;
end;

procedure TFMXStyleOverviewForm.DataGridSelectCell(Sender: TObject; const ACol, ARow: Integer; var CanSelect: Boolean);
  procedure IterateComponentTree(var Tree: string; Comp: TFmxObject; Ident: string);
  begin
    if Assigned(Comp) then begin
      if Comp.StyleName <> '' then
        if Ident = '' then
          Tree := Tree + Ident + Comp.ClassName + ' [' + Comp.StyleName + ']'#10
        else
          Tree := Tree + Ident + Comp.ClassName + ' (' + Comp.StyleName + ')'#10
      else
        Tree := Tree + Ident + Comp.ClassName + #10;
      for var idx := 0 to Comp.ChildrenCount - 1 do
        IterateComponentTree(Tree, Comp.Children[idx], Ident + '   ');
    end else
      Tree := Tree + Ident + 'NONE'#10;
  end;
begin
  if FLockCell.X >= 0 then begin
    DataGrid.ColumnIndex := FLockCell.X;
    DataGrid.Row         := FLockCell.Y;
    Exit;
  end;

  ButtonSave.Enabled := ACol > 0;
  if ({DataGrid.Row}ARow < 0) or ({DataGrid.ColumnIndex}ACol < 0) then
    Exit;
  DataGrid.Paint;

  var Description := '';
  if ACol > 0 then begin
    var Images := '';
    if Assigned(FStyleInfos[ACol].Images) then
      Images := #10'Images:      ' + string.Join(', ', FStyleInfos[ACol].Images);
    Description := string.Join(#10, FStyleInfos[ACol].Source) + #10#10
                 + FStyleInfos[ACol].Descr + Images;
  end;

  //ListPlatforms.Enabled := False;  // das Mistding krallt sich den Fokus, wenn die Checkboxen gesetzt werden
  for var idx := ListPlatforms.Items.Count - 1 downto 0 do begin
    var IsSystem := MatchStr(ListPlatforms.Items[idx], FStyleInfos[ACol].System);
    ListPlatforms.ListItems[idx].FontColor := IfThen(IsSystem, TAlphaColors.Red, TAlphaColors.Black);
    //ListPlatforms.ListItems[idx].IsChecked := IsSystem;
  end;
  //ListPlatforms.Enabled := True;
  ListPlatforms.Repaint;

  LabelPreviewHint.Parent := nil;
  MemoPreviewCode.Parent  := nil;
  LayoutPreview.DeleteChildren;
  if TabControlPreview.ActiveTab = TabItemCode then begin
    MemoPreviewCode.Parent := LayoutPreview;  // MemoPreviewCode.Show;

    var Style  := StylesList.Styles[ACol].Style.FindStyleResource(FStyleNames[ARow]);
    var Stream := TMemoryStream.Create;
    var AsText := TStringStream.Create;
    try
      if Assigned(Style) then begin
        Stream.WriteComponentRes(StylesList.Styles[ACol].Platform, Style);
        Stream.Position := 0;
        ObjectResourceToText(Stream, AsText);
        MemoPreviewCode.Text := AsText.DataString;
      end else
        MemoPreviewCode.Text := 'NONE';
    finally
      AsText.Free;
      Stream.Free;
    end;

  end else if TabControlPreview.ActiveTab = TabItemTree then begin
    MemoPreviewCode.Parent := LayoutPreview;  // MemoPreviewCode.Show;

    var Tree := '';
    var Comp := StylesList.Styles[ACol].Style.FindStyleResource(FStyleNames[ARow]);
    IterateComponentTree(Tree, Comp, '');
    MemoPreviewCode.Text := Tree;

  end else {if TabControlPreview.ActiveTab = TabItemPreview then} begin
    if (ACol > 0) and FStyleFound[ARow, ACol] then
      try
        var Style := StylesList.Styles[ACol].Style;
        var Backg := Style.FindStyleResource('backgroundstyle');
        var Back  := TControl(nil);
        if Assigned(Backg) and (CheckBackground.IsChecked or CheckFullBackground.IsChecked) then begin
          Back         := Backg.Clone(LayoutPreview) as TControl;
          Back.Align   := TAlignLayout.None;
          Back.Parent  := LayoutPreview;
          Back.Visible := True;
        end;

        var Compo := Style.FindStyleResource(FStyleNames[ARow]);
        if Assigned(Compo) then begin  // das muß eigentlich immer vorhanden sein, aber sicher is sicher
          if ( (Compo is TLayout) or (Compo is TStyledControl) ) and (Compo.ChildrenCount > 0) then
            Description := Description + #10'StyleClass   ' + Compo.ClassName + ' -> ' + Compo.Children[0].ClassName
          else
            Description := Description + #10'StyleClass   ' + Compo.ClassName;  // FStyleInfos[].Source|Descr + StyleInfo

          var Comp := Compo.Clone(LayoutPreview) as TControl;
          if Assigned(Back) then begin
            Comp.Align      := TAlignLayout.None;
            Comp.Position.X := 3;
            Comp.Position.Y := 3;
            Comp.Parent     := Back;
            if CheckFullBackground.IsChecked then begin
              Back.Align    := TAlignLayout.Client;
              Comp.Align    := TAlignLayout.Center;
            end else begin
              Back.Width    := Comp.Width  + 2*3;
              Back.Height   := Comp.Height + 2*3;
              Back.Align    := TAlignLayout.Center;
            end;
          end else begin
            Comp.Align  := TAlignLayout.Center;
            Comp.Parent := LayoutPreview;
          end;

          if not TControl(Comp).Visible then begin
            TControl(Comp).Visible := True;
            LabelPreviewHint.Text   := 'Visible=False';
            LabelPreviewHint.Parent := LayoutPreview;  // LabelPreviewHint.Show;
          end;
        end else begin
          LabelPreviewHint.Text     := 'NONE';
          LabelPreviewHint.Parent   := LayoutPreview;  // LabelPreviewHint.Show;
        end;
      except
      end;
  end;

  MemoDescription.Text := Description;

  if ACol <> DataGrid.ColumnIndex then
    DataGrid.Repaint;  // nicht nur die aktuelle Zelle neu zeichnen, sondern auch die anderen (f r Column-Selection)
  LayoutPreview.Repaint;

  if FMXStyleDemoForm.Visible and (ACol <> FMXStyleDemoForm.Tag) then
    TThread.ForceQueue(nil, procedure
      begin
        CheckDemoFormChange(nil);  // drin wird auf DataGrid.ColumnIndex und das ist jetzt noch nicht aktuell
      end);
end;

procedure TFMXStyleOverviewForm.DropTarget1DragOver(Sender: TObject; const Data: TDragObject; const Point: TPointF; var Operation: TDragOperation);
begin
  Operation := TDragOperation.Copy;
end;

procedure TFMXStyleOverviewForm.DropTarget1Dropped(Sender: TObject; const Data: TDragObject; const Point: TPointF);
var
  DropFiles: TArray<string>;
begin
  DropFiles := Copy(TArray<string>(Data.Files));
  TThread.ForceQueue(nil, procedure  // sonst geht das DropImage nicht mehr weg
    begin
      DataGrid.Enabled := False;
      DataGrid.BeginUpdate;
      try
        for var FileName in DropFiles do
          LoadStyleFile(FileName);
      finally
        Caption := 'FMX-Style-Overview';
        DataGrid.EndUpdate;
        DataGrid.Enabled := True;
        //DataGrid.SetFocus;  // NICHT, damit das DropDown nicht geschlossen wird
      end;
    end);
end;

procedure TFMXStyleOverviewForm.LayoutPrevTabsResized(Sender: TObject);
begin
  TabControlPreview.Width := LayoutPrevTabs.Height;  // siehe FormCreate
end;

procedure TFMXStyleOverviewForm.ListPlatformsItemPaint(Sender: TObject; Canvas: TCanvas; const ARect: TRectF);
begin
  Assert(Sender is TListBoxItem);
  if TListBoxItem(Sender).FontColor <> TAlphaColors.Black then begin
    ARect.Inflate(-23, -1, -1, -1);
    if TListBoxItem(Sender).Index <> ListPlatforms.ItemIndex then begin
      Canvas.Fill.Color := TAlphaColors.White;
      Canvas.FillRect(ARect, 1);
    end;
    Canvas.Fill.Color := TListBoxItem(Sender).FontColor;
    Canvas.FillText(ARect, TListBoxItem(Sender).Text, False, 1, [], TTextAlign.Leading, TTextAlign.Center);
  end;
end;

procedure TFMXStyleOverviewForm.LoadDefaultStyles;
var
  ResNames: array of string;
  ResFiles: array[0..4] of TResFile;
  ResCount: Integer;
  ResLoad:  Integer;
begin
  try
    ResNames := [
      ParamStr(0),
      FDelphiDir + '\lib\win32\release\FMX.Controls.Win.res',
      FDelphiDir + '\lib\osxarm64\release\FMX.Controls.Mac.res',
      FDelphiDir + '\lib\iossimarm64\release\FMX.Controls.iOS.res',
      FDelphiDir + '\lib\android\release\FMX.Controls.Android.res'];

    ResFiles[0].LoadMine;
    ResCount := ResFiles[0].ResCount;
    for var idx := 1 to 4 do
      if FileExists(ResNames[idx]) then begin
        try
          Caption := Format('%d / %d : %s', [idx, Length(ResNames), TPath.GetFileName(ResNames[idx])]);
          ResFiles[idx].LoadFrom(ResNames[idx]);
        except
        end;
        Inc(ResCount, ResFiles[idx].ResCount);
      end;

    DataGrid.Enabled := False;
    DataGrid.BeginUpdate;
    try
      ResLoad  := 0;
      for var idx := 0 to 4 do
        for var Resource in ResFiles[idx].Resources do begin
          Inc(ResLoad);
          if (Resource.Type_ = 'RT_RCDATA') then begin
            Application.ProcessMessages;
            if Application.Terminated then
              Break;
            var Data := TBytesStream.Create(Resource.Data);
            try
              try
                //if TestStreamFormat(Data) in [...] then          // Prüft alles nur, was für eine Style-Resource es ~ist~ wäre, aber nicht ob es eine ist.
                //if TStyleStreaming.CanLoadFromStream(Data) then  // Prüft nur nochmal den Typ und ob die aktuelle Platform passt. -> UND vorher SetDesigning nicht vergessen (wegen der Platform)
                if MatchText(Resource.Name, ['CLOUDS', 'DVCLAL', 'MSG_ERROR', 'MSG_INFO', 'MSG_WARNING', 'PACKAGEINFO', 'PLATFORMTARGETS'])
                  or ( StartsText('T', Resource.Name) and ContainsText(Resource.Name, 'FORM') )
                then
                  Continue;
                Caption := Format('%d / %d : %s', [ResLoad, ResCount, TPath.GetFileName(ResNames[idx]) + ' : ' + Resource.Name]);
                LoadStyleFile(Data, TPath.GetFileName(ResNames[idx]) + ' :' + Resource.Name, Resource.Name);
              except
              end;
            finally
              Data.Free;
            end;
          end;
        end;
    finally
      DataGrid.EndUpdate;
      if not DataGrid.IsUpdating then begin
        Caption := 'FMX-Style-Overview';
        DataGrid.Enabled := True;
        DataGrid.SetFocus;
      end;
    end;
  except
    on E: Exception do
      ShowMessage('LoadDefaultStyles: ' + E.Message);
  end;
end;

procedure TFMXStyleOverviewForm.LoadStyleFile(FileName: string);
begin
  if EndsText('.res', FileName) or TResFile.CheckIsPEFile(FileName) then begin
    var ResFiles := TResFile.Create(FileName);
    for var Resource in ResFiles.Resources do
      if (Resource.Type_ = 'RT_RCDATA') then begin
        var Data := TBytesStream.Create(Resource.Data);
        try
          try
            //Caption := Format('%d / %d : %s %s', [idx + 1, Length(FileList), TPath.GetFileName(FileName), Resource.Name]);
            LoadStyleFile(Data, TPath.GetFileName(FileName) + ' :' + Resource.Name, Resource.Name);
          except
          end;
        finally
          Data.Free;
        end;
      end;
  end else begin
    var Stream := TBytesStream.Create;
    try
      Stream.LoadFromFile(FileName);
      LoadStyleFile(Stream, FileName, TPath.GetFileName(FileName));
    finally
      Stream.Free;
    end;
  end;
end;

procedure TFMXStyleOverviewForm.LoadStyleFile(FileData: TBytesStream; Source, Header: string);
begin
  DataGrid.Enabled := False;
  DataGrid.BeginUpdate;
  try
    var NewSize := Length(FileData.Bytes);
    var NewData := Pointer(FileData.Bytes);
    for var idx := 0 to High(FStyleInfos) do begin
      var Size := Length(FStyleInfos[idx].FileData);
      var Data := Pointer(FStyleInfos[idx].FileData);
      if (Size = NewSize) and CompareMem(Data, NewData, NewSize) then begin
        if not MatchText(Source, FStyleInfos[idx].Source) then
          FStyleInfos[idx].Source := FStyleInfos[idx].Source + [Source];
        Exit;
      end;
    end;

    var FileIdx := {High}Length(FStyleInfos);  // SetLength afterwards

    // *.style  TextRepresentation einer StreamResource (ähnlich *.dfm und *.fmx)
    // *.fsf    FMX-Style (properitäres Binärgedöhns)
    // *.vsf    VCL-Style
    FileData.Position := 0;
    var Style := StylesList.Styles.Add;
    Style.Platform := 'Style' + FileIdx.ToString;  // Source instead of Index?
    try
      Style.LoadFromStream(FileData);
      if Style.Platform <> 'Style' + FileIdx.ToString then
        raise Exception.Create('style name from "' + Source + '" changed to "' + Style.Platform);
      if Style.Index <> FileIdx then
        raise Exception.Create('style index from "' + Source + '" has moved');
      if (StylesList.Styles[0].Platform <> '') and (StylesList.Styles[0].Style.ChildrenCount <> 0) then
        raise Exception.Create('default style 0 was overriden');
    except
      StylesList.Styles.Delete(FileIdx);
      raise;
    end;

    var FileCount  := Length(FStyleInfos) + 1; //StylesList.Styles.Count + 1;
    var StyleCount := Length(FStyleNames);
    SetLength(FStyleInfos, FileCount);
    SetLength(FStyleFound, StyleCount, FileCount);
    SetLength(FStyleFixed, StyleCount, FileCount);

    FStyleInfos[FileIdx].FileData := Copy(FileData.Bytes);
    FStyleInfos[FileIdx].Source   := [Source];
    var Col := TCheckColumn.Create(DataGrid);
    Col.Header    := Header;
    Col.HorzAlign := TTextAlign.Center;
    DataGrid.AddObject(Col);

    var StreamFormat, RootClass: string;
    FileData.Position := 0;
    case TestStreamFormat(FileData) of  // TStreamOriginalFormat -> TStyleFormat
      sofUnknown:           StreamFormat := 'StyleFormat  Indexed';
      sofBinary:            StreamFormat := 'StyleFormat  Binary';
      sofText, sofUTF8Text: StreamFormat := 'StyleFormat  Text';
    end;
    if Assigned(Style.Style) then
      RootClass := 'RootClass       ' + Style.Style.ClassName
    else
      RootClass := 'RootClass       ' + '(none)';
    FStyleInfos[FileIdx].Descr := TrimFill(StreamFormat, 44) + RootClass;

    var Description := TStyleManager.FindStyleDescriptor(Style.Style);
    if Assigned(Description) then begin
      AddPlatformNames(Description.PlatformTarget, FStyleInfos[FileIdx].System);
      FStyleInfos[FileIdx].Descr := FStyleInfos[FileIdx].Descr
        + TrimFill(#10'Title        ' + Description.Title)
        + TrimFill(#10'Author       ' + Description.Author)      + 'PlatformTarget  ' + Description.PlatformTarget
        + TrimFill(#10'AuthorEMail  ' + Description.AuthorEMail) + 'MobilePlatform  ' + Description.MobilePlatform.ToString(TUseBoolStrs.True)
        + TrimFill(#10'AuthorURL    ' + Description.AuthorURL)   + 'Version         ' + Description.Version
    end else
      FStyleInfos[FileIdx].Descr := FStyleInfos[FileIdx].Descr + #10#10#10#10;

    var ImSystem := FStyleInfos[FileIdx].System;
    var SysImage := -1;
    if MatchStr('[MSWINDOWS]', ImSystem) then
      SysImage := 0;
    if MatchStr('[MACOS]', ImSystem) then
      if SysImage < 0 then SysImage := 2 else SysImage := 8;
    if MatchStr('[IOS]', ImSystem) or MatchStr('[IOSALTERNATE]', ImSystem) then
      if SysImage < 0 then SysImage := 4 else SysImage := 8;
    if MatchStr('[ANDROID]', ImSystem) then
      if SysImage < 0 then SysImage := 6 else SysImage := 8;
    if MatchStr('[DARKSTYLE]', ImSystem) then
      if SysImage >= 0 then Inc(SysImage);
    FStyleInfos[FileIdx].SysImage := SysImage;

    AddStyleNames(Style.Style, FileIdx);
  finally
    DataGrid.EndUpdate;
    if not DataGrid.IsUpdating then begin
      Caption := 'FMX-Style-Overview';
      DataGrid.Enabled := True;
      DataGrid.SetFocus;
    end;
  end;
end;

procedure TFMXStyleOverviewForm.MenuLoadClick(Sender: TObject);
var
  FileList: TArray<string>;
begin
  if Sender = MenuLoadFolder then
    FileList := OpenFolderDialog(OpenDialog.InitialDir)

  else if Sender = MenuLoadFile then begin
    if OpenDialog.Execute then
      FileList := OpenDialog.Files.ToStringArray
    else
      Exit;

  end else {if TMenuItem(Sender).TagString <> '' then}
    FileList := FindStyleFiles(TMenuItem(Sender).TagString);

  DataGrid.Enabled := False;
  DataGrid.BeginUpdate;
  try
    for var idx := 0 to High(FileList) do begin
      Application.ProcessMessages;
      if Application.Terminated then
        Break;
      Caption := Format('%d / %d : %s', [idx + 1, Length(FileList), TPath.GetFileName(FileList[idx])]);
      LoadStyleFile(FileList[idx]);
    end;
  finally
    DataGrid.EndUpdate;
    if not DataGrid.IsUpdating then begin
      Caption := 'FMX-Style-Overview';
      DataGrid.Enabled := True;
      DataGrid.SetFocus;
    end;
  end;
end;

procedure TFMXStyleOverviewForm.MenuItemSaveClick(Sender: TObject);
begin
  if (DataGrid.Row < 0) or (DataGrid.ColumnIndex <= 0) then
    Exit;
  if SaveDialog.Execute then begin
    var Styles := StylesList.Styles[DataGrid.ColumnIndex];
    var Stream := TFile.Create(SaveDialog.FileName);
    try
      case IndexText(ExtractFileExt(SaveDialog.FileName), ['', '.fsf', '.style']) of
        0: Styles.SaveToStream(Stream, TStyleFormat.Indexed);
        1: Styles.SaveToStream(Stream, TStyleFormat.Binary);
        2: Styles.SaveToStream(Stream, TStyleFormat.Text);
        else raise Exception.Create('unknown format');
      end;
    finally
      Stream.Free;
    end;
  end;
end;

function TFMXStyleOverviewForm.OpenFolderDialog(InitialFolder: string): TArray<string>;
begin
  Caption := 'FMX-Style-Overview';
  var FolderDialog := VCL.Dialogs.TFileOpenDialog.Create(Self);
  try
    FolderDialog.Options := [fdoNoChangeDir,fdoPickFolders,fdoDontAddToRecent];
    FolderDialog.DefaultFolder := InitialFolder;
    if FolderDialog.Execute(FormToHWND(Self)) then begin
      Result := FindStyleFiles(FolderDialog.FileName);
      if not Assigned(Result) then
        ShowMessage('no styles found');
    end else
      Result := nil;
  finally
    FolderDialog.Free;
  end;
end;

function TFMXStyleOverviewForm.TrimFill(Value: string; Len: Integer): string;
begin
  Result := Value.Substring(0, Len - 2).PadRight(Len, ' ');
end;

end.

