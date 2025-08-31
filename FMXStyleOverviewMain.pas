/// <summary>FMX-Style-Overview</summary>
/// <remarks>Version: 1.0 2025-09-01<br />Copyright 2025 himitsu @ geheimniswelten<br />License: MPL v1.1 , GPL v3.0 or LGPL v3.0</remarks>
/// <seealso cref="http://geheimniswelten.de">Geheimniswelten</seealso>
/// <seealso cref="http://geheimniswelten.de/kontakt/#licenses">License Text</seealso>
/// <seealso cref="https://github.com/geheimniswelten/FMXStyleOverview">GitHub</seealso>
unit FMXStyleOverviewMain;

interface

uses
  Winapi.Windows, VCL.Dialogs,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Grid.Style, FMX.StdCtrls,
  FMX.Layouts, FMX.Controls.Presentation, FMX.ScrollBox, FMX.Grid, FMX.Header, FMX.Styles,
  FMX.Objects, FMX.Platform.Win,
  System.Types, System.UITypes, System.Math, System.SysUtils, System.StrUtils, System.IOUtils,
  System.Classes, System.Variants, System.Rtti, FMX.Memo.Types, FMX.Memo;

type
  TFMXStyleOverviewForm = class(TForm)
    Grid: TGrid;
    StyleBook: TStyleBook;
    MemoDescription: TMemo;
    CheckFixed: TCheckBox;
    LayoutInfo: TLayout;
    LayoutPreview: TLayout;
    SplitterInfo: TSplitter;
    SplitterPreview: TSplitter;
    CheckBackground: TCheckBox;
    CheckFullBackground: TCheckBox;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure GridGetValue(Sender: TObject; const ACol, ARow: Integer; var Value: TValue);
    procedure GridDrawColumnHeader(Sender: TObject; const Canvas: TCanvas; const Column: TColumn; const Bounds: TRectF);
    procedure GridDrawColumnCell(Sender: TObject; const Canvas: TCanvas; const Column: TColumn; const Bounds: TRectF; const Row: Integer; const Value: TValue; const State: TGridDrawStates);
    procedure GridSelectCell(Sender: TObject; const ACol, ARow: Integer; var CanSelect: Boolean);
    procedure CheckFixedChange(Sender: TObject);
    procedure CheckBackgroundChange(Sender: TObject);
  private
    FFileNames:  TArray<string>;               // [FileIdx]
    FFileDescr:  TArray<string>;               // [FileIdx]
    FStyleNames: TArray<string>;               // [StyleIdx]
    FStyleFound: TArray<TArray<Boolean>>;      // [StyleIdx, FileIdx]
    FStyleFixed: TArray<TArray<TAdjustType>>;  // [StyleIdx, FileIdx]
    procedure LoadStyles;
    procedure AddStyle(Style: TFmxObject; FileIdx: Integer);
    function  TrimFill(Value: string; Len: Integer=55): string;
  end;

var
  FMXStyleOverviewForm: TFMXStyleOverviewForm;

implementation

{$R *.fmx}

type
  TFmxObjectAccess = class(TFmxObject);
  TStyleBookAccess = class(TStyleBook);

procedure TFMXStyleOverviewForm.AddStyle(Style: TFmxObject; FileIdx: Integer);
begin
  if (Style is TStyleDescription) or (Style is TImage) then
    Exit;

  if Style.StyleName <> '' then begin
    var StyleIdx := -1;
    var StyleNam := Style.StyleName.ToLower;
    var NewStyle := Length(FStyleNames);
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
      SetLength(FStyleFound[StyleIdx], Grid.ColumnCount - 1);
      SetLength(FStyleFixed[StyleIdx], Grid.ColumnCount - 1);
      Grid.RowCount := Length(FStyleNames);
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
        AddStyle(Style.Children[idx], FileIdx)
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
  GridSelectCell(Grid, Grid.ColumnIndex, Grid.Row, Dummy);
end;

procedure TFMXStyleOverviewForm.CheckFixedChange(Sender: TObject);
begin
  Grid.Repaint;
end;

procedure TFMXStyleOverviewForm.FormCreate(Sender: TObject);
begin
  Height := Round(Screen.WorkAreaHeight - 20);
  Width  := 1333;
  MemoDescription.Lines.Clear;
end;

procedure TFMXStyleOverviewForm.FormShow(Sender: TObject);
begin
  OnShow := nil;
  LoadStyles;
end;

procedure TFMXStyleOverviewForm.GridDrawColumnCell(Sender: TObject; const Canvas: TCanvas; const Column: TColumn; const Bounds: TRectF; const Row: Integer; const Value: TValue; const State: TGridDrawStates);
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
  end else begin
    var CustomDraw := False;
    if CheckFixed.IsChecked then begin
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
      CustomDraw := True;
    end else begin
      // Grid.DefaultDrawing mu  True bleiben, sonst werden die CheckBoxen nicht mehr gemalt, auch nicht mit Column.DefaultDrawCell
      //CustomDraw := True;  // nicht n tig, weil DefaultDrawing=True
    end;

    var _State := State;
    if (Column.Index > 0) and (Column.Index = Grid.ColumnIndex) and (Row <> Grid.Selected) then begin
      //_State := _State + [TGridDrawState.RowSelected];
      //CustomDraw := True;
      // am Liebsten w rde ich den Hintergrund f rben/ bermalen, aber da sich die Checkboxen nicht manuell malen lassen .....
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

procedure TFMXStyleOverviewForm.GridDrawColumnHeader(Sender: TObject; const Canvas: TCanvas; const Column: TColumn; const Bounds: TRectF);
begin
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
  if Column.Index = 0 then begin  // Fixed-Column
    TextBounds.Inflate(-4, -2, -1.75, -3.75);
    Canvas.Fill.Color := TAlphaColors.Black;
    Canvas.FillText(TextBounds, Column.Header, True, 1, [], TTextAlign.Leading, TTextAlign.Trailing);
  end else begin
    TextBounds.Inflate(-2, -2, -1.75, -1.75);
    Canvas.Fill.Color := TAlphaColors.Black;
    Canvas.FillText(TextBounds, Column.Header, True, 1, [], TTextAlign.Leading, TTextAlign.Trailing);
  end;
end;

procedure TFMXStyleOverviewForm.GridGetValue(Sender: TObject; const ACol, ARow: Integer; var Value: TValue);
begin
  if ACol = 0 then
    Value := FStyleNames[ARow]
  else
    Value := FStyleFound[ARow, ACol - 1];
end;

procedure TFMXStyleOverviewForm.GridSelectCell(Sender: TObject; const ACol, ARow: Integer; var CanSelect: Boolean);
begin
  if ACol = 0 then
    MemoDescription.Lines.Clear
  else
    MemoDescription.Text := FFileDescr[ACol - 1];

  LayoutPreview.DeleteChildren;
  if (ACol > 0) and FStyleFound[ARow, ACol - 1] then
    try
      var Style := StyleBook.Styles[ACol - 1].Style;
      var Backg := Style.FindStyleResource('backgroundstyle');
      var Back  := TControl(nil);
      if Assigned(Backg) and (CheckBackground.IsChecked or CheckFullBackground.IsChecked) then begin
        Back        := Backg.Clone(LayoutPreview) as TControl;
        Back.Align  := TAlignLayout.None;
        Back.Parent := LayoutPreview;
      end;

      var Compo := Style.FindStyleResource(FStyleNames[ARow]);
      if Assigned(Compo) then begin  // das mu  eigentlich immer vorhanden sein, aber sicher is sicher
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
      end;
    except
    end;
  if ACol <> Grid.ColumnIndex then
    Grid.Repaint;  // nicht nur die aktuelle Zelle neu zeichnen, sondern auch die anderen (f r Column-Selection)
  LayoutPreview.Repaint;
end;

procedure TFMXStyleOverviewForm.LoadStyles;
begin
  var FolderDialog := VCL.Dialogs.TFileOpenDialog.Create(Self);
  try
    FolderDialog.Options := [fdoNoChangeDir,fdoPickFolders,fdoDontAddToRecent];
    FolderDialog.FavoriteLinks.Add.Location := 'C:\Program Files (x86)\Embarcadero\Studio\23.0\Redist\styles\Fmx';
    FolderDialog.FavoriteLinks.Add.Location := 'C:\Users\Public\Documents\Embarcadero\Studio\23.0\Styles';
    FolderDialog.FavoriteLinks.Add.Location := 'C:\Users\Public\Documents\Embarcadero\Studio';

    FolderDialog.DefaultFolder := 'C:\Users\Public\Documents\Embarcadero\Studio\23.0\Styles';
    if not TDirectory.Exists(FolderDialog.DefaultFolder) then
      FolderDialog.DefaultFolder := 'C:\Users\Public\Documents\Embarcadero\Studio';
    if not TDirectory.Exists(FolderDialog.DefaultFolder) then
      FolderDialog.DefaultFolder := '';
    if not FolderDialog.Execute(FormToHWND(Self)) then begin
      Application.Terminate;
      Exit;
    end;
    FFileNames := TDirectory.GetFiles(FolderDialog.FileName, '*.*', TSearchOption.soAllDirectories,
      function(const Path: string; const SearchRec: TSearchRec): Boolean
      begin
        Result := EndsText('.style', SearchRec.Name) or EndsText('.fsf', SearchRec.Name);
      end);
    SetLength(FFileDescr, Length(FFileNames));
  finally
    FolderDialog.Free;
  end;

  Grid.Enabled := False;
  Grid.BeginUpdate;
  try
    Grid.ClearColumns;
    Grid.RowCount := 0;
    begin
      var Col := TStringColumn.Create(Grid);
      Col.Header := 'Styles';
      Col.Width  := 200;
      Grid.AddObject(Col);
    end;

    SetLength(FStyleNames, 0);
    SetLength(FStyleFound, 0, 0);
    for var Filename in FFileNames do begin
      var Col := TCheckColumn.Create(Grid);
      Col.Header := TPath.GetFileNameWithoutExtension(Filename);
      Grid.AddObject(Col);
    end;

    var Header := Grid.FindStyleResource('header') as THeader;
    if Assigned(Header) then  // geht noch nicht im OnCreate und auch nicht im OnShow
      Header.Height := 120;

    // damit sich in TStyleCollectionItem.LoadFromStream die Styles f r alle Plattformen laden lassen
    // https://www.delphipraxis.net/217749-fmx-style-dateien-auslesen-und-ressourcen-enumerieren.html
    TStyleBookAccess(StyleBook).SetDesigning(True);

    StyleBook.Clear;
    for var FileIdx := 0 to High(FFileNames) do begin
      Caption := Format('%d / %d : %s', [FileIdx, Length(FFileNames), TPath.GetFileName(FFileNames[FileIdx])]);
      Application.ProcessMessages;

      // *.style  TextRepresentation einer StreamResource ( hnlich *.dfm und *.fmx)
      // *.fsf    FMX-Style (properit res Bin rged hns)
      // *.vsf    VCL-Style
      var Style := StyleBook.Styles.Add;
      Style.Platform := TPath.GetFileName(FFileNames[FileIdx]).Replace('.', '_');
      Style.LoadFromFile(FFileNames[FileIdx]);
      FFileDescr[FileIdx] := 'Filename     ' + FFileNames[FileIdx];

      var Stream := TFile.OpenRead(FFileNames[FileIdx]);
      try
        case TestStreamFormat(Stream) of  // TStreamOriginalFormat -> TStyleFormat
          sofUnknown:           FFileDescr[FileIdx] := FFileDescr[FileIdx] + #10'StyleFormat  Indexed';
          sofBinary:            FFileDescr[FileIdx] := FFileDescr[FileIdx] + #10'StyleFormat  Binary';
          sofText, sofUTF8Text: FFileDescr[FileIdx] := FFileDescr[FileIdx] + #10'StyleFormat  Text';
        end;
      finally
        Stream.Free;
      end;

      var Description := TStyleManager.FindStyleDescriptor(Style.Style);
      if Assigned(Description) then
        FFileDescr[FileIdx] := FFileDescr[FileIdx]
          + TrimFill(#10'Title        ' + Description.Title)
          + TrimFill(#10'Author       ' + Description.Author)      + 'PlatformTarget  ' + Description.PlatformTarget
          + TrimFill(#10'AuthorEMail  ' + Description.AuthorEMail) + 'MobilePlatform  ' + Description.MobilePlatform.ToString(TUseBoolStrs.True)
          + TrimFill(#10'AuthorURL    ' + Description.AuthorURL)   + 'Version         ' + Description.Version;

      AddStyle(Style.Style, FileIdx);
    end;

    Caption := 'FMX-Style-Overview';
  finally
    Grid.EndUpdate;
    Grid.Enabled := True;
    Grid.SetFocus;
  end;
end;

function TFMXStyleOverviewForm.TrimFill(Value: string; Len: Integer): string;
begin
  Result := Value.Substring(0, Len - 2).PadRight(Len, ' ');
end;

end.

