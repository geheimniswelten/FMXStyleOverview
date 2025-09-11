unit FMXStyleOverviewDemo;

interface

uses
  Winapi.Windows,
  System.SysUtils, System.StrUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  System.UIConsts, System.ImageList, System.TypInfo, System.Skia, System.Rtti, System.Math.Vectors,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.ImgList, FMX.Menus, FMX.StdCtrls,
  FMX.Controls.Presentation, FMX.Memo.Types, FMX.Grid.Style, FMX.Effects, FMX.Ani, FMX.Objects,
  FMX.Colors, FMX.TabControl, FMX.Grid, FMX.Skia, FMX.MagnifierGlass, FMX.ExtCtrls, FMX.ComboTrackBar,
  FMX.ComboEdit, FMX.SpinBox, FMX.Edit, FMX.EditBox, FMX.NumberBox, FMX.DateTimeCtrls, FMX.Calendar,
  FMX.TreeView, FMX.ScrollBox, FMX.Memo, FMX.ListBox, FMX.Layouts, FMX.Controls3D, FMX.Layers3D;

type
  TFMXStyleDemoForm = class(TForm)
    {$REGION 'Components'}
    MainMenu1: TMainMenu;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    MenuItem5: TMenuItem;
    MenuItem6: TMenuItem;
    MenuItem7: TMenuItem;
    MenuItem8: TMenuItem;
    MenuItem9: TMenuItem;
    MenuItem10: TMenuItem;
    MenuItem11: TMenuItem;
    MenuItem12: TMenuItem;
    ImageList1: TImageList;
    PopupMenu1: TPopupMenu;
    MenuItem13: TMenuItem;
    MenuItem14: TMenuItem;
    MenuItem15: TMenuItem;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    Button6: TButton;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    CheckBox3: TCheckBox;
    RadioButton1: TRadioButton;
    RadioButton2: TRadioButton;
    GroupToolButtons: TGroupBox;
    CheckToolButtonBorders: TCheckBox;
    Panel1: TPanel;
    CalloutPanel1: TCalloutPanel;
    Label2: TLabel;
    Panel2: TPanel;
    PathLabel1: TPathLabel;
    ProgressBar1: TProgressBar;
    ScrollBar1: TScrollBar;
    SmallScrollBar1: TSmallScrollBar;
    TrackBar1: TTrackBar;
    Switch1: TSwitch;
    Panel3: TPanel;
    Panel4: TPanel;
    Panel5: TPanel;
    Splitter1: TSplitter;
    SizeGrip1: TSizeGrip;
    SizeGrip2: TSizeGrip;
    ListBox1: TListBox;
    ComboBox1: TComboBox;
    Memo1: TMemo;
    TreeView1: TTreeView;
    SpeedButton1: TSpeedButton;
    CornerButton1: TCornerButton;
    ArcDial1: TArcDial;
    AniIndicator1: TAniIndicator;
    AniIndicator2: TAniIndicator;
    Calendar1: TCalendar;
    DateEdit1: TDateEdit;
    DropTarget1: TDropTarget;
    NumberBox1: TNumberBox;
    Edit1: TEdit;
    SpinBox1: TSpinBox;
    ComboEdit1: TComboEdit;
    ComboTrackBar1: TComboTrackBar;
    MagnifierGlass1: TMagnifierGlass;
    SkLabel1: TSkLabel;
    Grid1: TGrid;
    TabControl1: TTabControl;
    TabItem1: TTabItem;
    TabItem2: TTabItem;
    HueTrackBar1: THueTrackBar;
    AlphaTrackBar1: TAlphaTrackBar;
    BWTrackBar1: TBWTrackBar;
    ColorQuad1: TColorQuad;
    ColorPicker1: TColorPicker;
    GradientEdit1: TGradientEdit;
    ColorBox1: TColorBox;
    ColorPanel1: TColorPanel;
    ComboColorBox1: TComboColorBox;
    ColorButton1: TColorButton;
    ColorComboBox1: TColorComboBox;
    ColorListBox1: TColorListBox;
    Label1: TLabel;
    TimeEdit1: TTimeEdit;
    TreeViewItem1: TTreeViewItem;
    TreeViewItem2: TTreeViewItem;
    TreeViewItem3: TTreeViewItem;
    TreeViewItem4: TTreeViewItem;
    TreeViewItem5: TTreeViewItem;
    TreeViewItem6: TTreeViewItem;
    TreeViewItem7: TTreeViewItem;
    StringColumn1: TStringColumn;
    ProgressColumn1: TProgressColumn;
    ListBoxItem1: TListBoxItem;
    ListBoxItem2: TListBoxItem;
    ListBoxGroupHeader1: TListBoxGroupHeader;
    MetropolisUIListBoxItem1: TMetropolisUIListBoxItem;
    ListBoxItem3: TListBoxItem;
    ListBoxGroupFooter1: TListBoxGroupFooter;
    CheckColumn1: TCheckColumn;
    Button7: TButton;
    Button8: TButton;
    Button9: TButton;
    Button10: TButton;
    Button11: TButton;
    Button12: TButton;
    Button13: TButton;
    Button14: TButton;
    Button15: TButton;
    Button16: TButton;
    StyleBookDemo: TStyleBook;
    ControlHintPanel: TCalloutRectangle;
    ControlHintAnimation: TFloatAnimation;
    ControlHintLabel: TLabel;
    Button17: TButton;
    Button18: TButton;
    Button19: TButton;
    Button20: TButton;
    Button21: TButton;
    Button22: TButton;
    Button23: TButton;
    Button24: TButton;
    Button25: TButton;
    Button26: TButton;
    Button27: TButton;
    Button28: TButton;
    Button29: TButton;
    Button30: TButton;
    Button31: TButton;
    Button32: TButton;
    Button33: TButton;
    Button34: TButton;
    Button35: TButton;
    Button36: TButton;
    Button37: TButton;
    Button38: TButton;
    Button39: TButton;
    Button40: TButton;
    Button41: TButton;
    Button42: TButton;
    Button43: TButton;
    Button44: TButton;
    Button45: TButton;
    Button46: TButton;
    Button47: TButton;
    Button48: TButton;
    Button49: TButton;
    Button50: TButton;
    Button51: TButton;
    Button52: TButton;
    Button53: TButton;
    Button54: TButton;
    Button55: TButton;
    Button56: TButton;
    Button57: TButton;
    LabelToolButtonScale: TLabel;
    SmallScrollBar2: TSmallScrollBar;
    FloatAnimation1: TFloatAnimation;
    TrackMagnifierGlass: TTrackBar;
    Label3: TLabel;
    SmallScrollBar3: TSmallScrollBar;
    FloatAnimation2: TFloatAnimation;
    SmallScrollBar4: TSmallScrollBar;
    FloatAnimation3: TFloatAnimation;
    SmallScrollBar5: TSmallScrollBar;
    FloatAnimation4: TFloatAnimation;
    SmallScrollBar6: TSmallScrollBar;
    FloatAnimation5: TFloatAnimation;
    SmallScrollBar7: TSmallScrollBar;
    FloatAnimation6: TFloatAnimation;
    SmallScrollBar9: TSmallScrollBar;
    FloatAnimation9: TFloatAnimation;
    Panel6: TPanel;
    Edit2: TEdit;
    EditButton1: TEditButton;
    Edit3: TEdit;
    SpinEditButton1: TSpinEditButton;
    Edit4: TEdit;
    DropDownEditButton1: TDropDownEditButton;
    Edit5: TEdit;
    EllipsesEditButton1: TEllipsesEditButton;
    Edit6: TEdit;
    ClearEditButton1: TClearEditButton;
    Edit7: TEdit;
    PasswordEditButton1: TPasswordEditButton;
    Edit8: TEdit;
    SearchEditButton1: TSearchEditButton;
    TimerButtonEdit: TTimer;
    {$ENDREGION}
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Single);
    procedure SkLabel1Words5Click(Sender: TObject);
    procedure ColorPicker1Click(Sender: TObject);
    procedure TrackBar1Change(Sender: TObject);
    procedure NumberBox1Change(Sender: TObject);
    procedure Edit1Change(Sender: TObject);
    procedure CheckBox1Change(Sender: TObject);
    procedure CheckBox2Change(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure DateEdit1Change(Sender: TObject);
    procedure TrackMagnifierGlassChange(Sender: TObject);
    procedure CheckBox2Exit(Sender: TObject);
    procedure Grid1GetValue(Sender: TObject; const ACol, ARow: Integer; var Value: TValue);
    procedure DropTarget1Dropped(Sender: TObject; const Data: TDragObject; const Point: TPointF);
    procedure DropTarget1DragOver(Sender: TObject; const Data: TDragObject; const Point: TPointF; var Operation: TDragOperation);
    procedure DropTarget1DragLeave(Sender: TObject);
    procedure DropTarget1DragEnter(Sender: TObject; const Data: TDragObject; const Point: TPointF);
    procedure DropTarget1DragEnd(Sender: TObject);
    procedure DropTarget1DragDrop(Sender: TObject; const Data: TDragObject; const Point: TPointF);
    procedure CheckToolButtonBordersChange(Sender: TObject);
    procedure SpinEditButton1UpClick(Sender: TObject);
    procedure SpinEditButton1DownClick(Sender: TObject);
    procedure EditButton1Click(Sender: TObject);
    procedure Edit2Change(Sender: TObject);
    procedure TimerButtonEditTimer(Sender: TObject);
  private
    FEnableChangeEvents:  Boolean;
    FBorderedToolButtons: TArray<TButton>;
    FClickNotifierHint:   string;
    procedure ButtonClickNotifier(Sender: TObject);
  end;

var
  FMXStyleDemoForm: TFMXStyleDemoForm;

implementation

{$R *.fmx}

uses
  FMXStyleOverviewMain;

{$if not Declared(Coalesce)}
function Coalesce(Value1, Value2: string): string;
begin
  if Value1 <> '' then
    Result := Value1
  else
    Result := Value2;
end;
{$endif}

procedure TFMXStyleDemoForm.Button7Click(Sender: TObject);
begin
  var CtrlRect   := RectF(0, 0, Button7.Width, Button7.Height);
  var PopupPoint := Button7.LocalToScreen(CtrlRect.CenterPoint);
  Button7.PopupMenu.Popup(PopupPoint.X, PopupPoint.Y)
end;

procedure TFMXStyleDemoForm.ButtonClickNotifier(Sender: TObject);
begin
  var Button := Sender as TControl;
  var Point  := Button.LocalToAbsolute(PointF(-15, Button.Height + 2));
  ControlHintLabel.Text    := Coalesce(FClickNotifierHint, 'Clicked');
  ControlHintPanel.BringToFront;
  ControlHintPanel.Position.Point := Point;
  ControlHintPanel.Opacity := ControlHintAnimation.StartValue;
  ControlHintPanel.Visible := True;
  ControlHintAnimation.Start;
  FClickNotifierHint := '';
end;

procedure TFMXStyleDemoForm.CheckBox1Change(Sender: TObject);
begin
  if not FEnableChangeEvents then
    Exit;
  FEnableChangeEvents := False;
  try
    var Value := CheckBox1.IsChecked;
    if Sender = Button6 then
      Value := Button6.IsPressed;
    if Sender = Switch1 then
      Value := Switch1.IsChecked;

    CheckBox1.IsChecked := Value;  // TCheckBox       FIsChecked
    Button6.IsPressed   := Value;  // TCustomButton   FIsPressed
    Switch1.IsChecked   := Value;  // TCustomSwitch   Model.Value
  finally
    FEnableChangeEvents := True;
  end;
end;

procedure TFMXStyleDemoForm.CheckBox2Change(Sender: TObject);
begin
  if not FEnableChangeEvents then
    Exit;
  FEnableChangeEvents := False;
  try
    var Value := TCheckBox(Sender).IsChecked;

    CheckBox2.IsChecked   := Value;  // TCheckBox   FIsChecked
    CheckBox3.IsChecked := Value;  // TCheckBox   FIsChecked
  finally
    FEnableChangeEvents := True;
  end;
end;

procedure TFMXStyleDemoForm.CheckBox2Exit(Sender: TObject);
begin
  CheckBox2.IsChecked := True;
end;

procedure TFMXStyleDemoForm.CheckToolButtonBordersChange(Sender: TObject);
begin
  if not Assigned(FBorderedToolButtons) then
    for var idx := GroupToolButtons.ControlsCount - 1 downto 0 do
      if GroupToolButtons.Controls[idx] is TButton then begin
        var Button := TButton(GroupToolButtons.Controls[idx]);
        if EndsText('bordered', Button.StyleLookup) then
          Insert(Button, FBorderedToolButtons, 0);
      end;
  for var Button in FBorderedToolButtons do
    if CheckToolButtonBorders.IsChecked then
      Button.StyleLookup := Button.StyleLookup + 'bordered'
    else
      Button.StyleLookup := (Button.StyleLookup + '*').Replace('bordered*', '');
end;

procedure TFMXStyleDemoForm.ColorPicker1Click(Sender: TObject);
begin
  if not FEnableChangeEvents then
    Exit;
  FEnableChangeEvents := False;
  try
    var Value:   TColor := 0;
    var H, S, L: Single;
    var idx := IndexText((Sender as TControl).Name, [
      HueTrackBar1.Name,   AlphaTrackBar1.Name, BWTrackBar1.Name,
      ColorQuad1.Name,     ColorPicker1.Name,   GradientEdit1.Name,
      ColorBox1.Name,      ColorButton1.Name,   ColorPanel1.Name,
      ComboColorBox1.Name, ColorComboBox1.Name, ColorListBox1.Name]);
    try
      case idx of
        0..2: begin
          H := HueTrackBar1.Value;
          L := AlphaTrackBar1.Value;
          S := BWTrackBar1.Value;
        end;
        3, 4: begin
          H := ColorQuad1.Hue;
          S := ColorQuad1.Lum;
          L := ColorQuad1.Sat;
          if Sender = ColorPicker1 then
            H := ColorPicker1.Hue;
        end;
        5:  ;//Value := AlphaColorToColor(GradientEdit1.Gradient.Color);
        6:  Value := ColorBox1.Color;
        7:  Value := ColorButton1.Color;
        8:  Value := ColorPanel1.Color;
        9:  Value := ComboColorBox1.Color;
        10: Value := ColorComboBox1.Color;
        11: Value := ColorListBox1.Color;
      end;
    except
    end;
    try
      if Cardinal(idx) < 5 then
        Value := HSLtoRGB(H, S, L)
      else
        RGBtoHSL(Value, H, S, L);
    except
    end;

    try
      HueTrackBar1.Value   := H;      // TCustomTrack   FValueRange.Value
      AlphaTrackBar1.Value := L;      // TCustomTrack   FValueRange.Value
      BWTrackBar1.Value    := S;      // TCustomTrack   FValueRange.Value
    except
    end;

    try
      ColorQuad1.Hue       := H;      // TColorQuad     FHue FLum FSat
      ColorQuad1.Lum       := S;
      ColorQuad1.Sat       := L;
      ColorPicker1.Hue     := H;      // TColorPicker   FHue
      GradientEdit1.Gradient.Color := Value;  // TGradientEdit  FGradient
    except
    end;

    try
      ColorBox1.Color      := Value;  // TColorBox              FColor
      ColorButton1.Color   := Value;  // TColorButton           FColor
      ColorPanel1.Color    := Value;  // TColorPanel            MakeColor(HSLtoRGB(FColorQuad.Hue, FColorQuad.Sat, FColorQuad.Lum), FColorQuad.Alpha)
      ComboColorBox1.Color := Value;  // TComboColorBox         FColorPanel.Color
      ColorComboBox1.Color := Value;  // TCustomColorComboBox   ColorsMap.Color[ItemIndex].Value
      ColorListBox1.Color  := Value;  // TColorListBox          ColorsMap.Color[ItemIndex].Value
    except
    end;
  finally
    FEnableChangeEvents := True;
  end;
end;

procedure TFMXStyleDemoForm.DateEdit1Change(Sender: TObject);
begin
  if not FEnableChangeEvents then
    Exit;
  FEnableChangeEvents := False;
  try
    var Value := DateEdit1.Date;
    if Sender = Calendar1 then
      Value := Calendar1.Date;
    DateEdit1.Date := Value;  // TCustomDateTimeEdit   FDTFormatter.DateTime
    Calendar1.Date := Value;  // TCustomCalendar       Model.DateTime
  finally
    FEnableChangeEvents := True;
  end;
end;

procedure TFMXStyleDemoForm.DropTarget1DragDrop(Sender: TObject; const Data: TDragObject; const Point: TPointF);
begin
  FClickNotifierHint := 'Drop';
  ButtonClickNotifier(Sender);
end;

procedure TFMXStyleDemoForm.DropTarget1DragEnd(Sender: TObject);
begin
  FClickNotifierHint := 'End';
  ButtonClickNotifier(Sender);
end;

procedure TFMXStyleDemoForm.DropTarget1DragEnter(Sender: TObject; const Data: TDragObject; const Point: TPointF);
begin
  FClickNotifierHint := 'Enter';
  ButtonClickNotifier(Sender);
end;

procedure TFMXStyleDemoForm.DropTarget1DragLeave(Sender: TObject);
begin
  FClickNotifierHint := 'Leave';
  ButtonClickNotifier(Sender);
end;

procedure TFMXStyleDemoForm.DropTarget1DragOver(Sender: TObject; const Data: TDragObject; const Point: TPointF; var Operation: TDragOperation);
begin
  if GetKeyState(VK_CONTROL) < 0 then
    Operation := TDragOperation.None   // OnDragOver: Default-Action (nothing allowed by default, if Filter is not set)
  else
  if GetKeyState(VK_SHIFT) < 0 then
    Operation := TDragOperation.Link
  else
    Operation := TDragOperation.Copy;

  FClickNotifierHint := 'Over';
  ButtonClickNotifier(Sender);
end;

procedure TFMXStyleDemoForm.DropTarget1Dropped(Sender: TObject; const Data: TDragObject; const Point: TPointF);
begin
  var Text := 'Files:'#10 + string.Join(#10, Data.Files)
            + #10#10'Data:'#10 + Data.Data.AsString;
  if Assigned(Data.Source) then
    Text := 'Source: ' + Data.Source.ClassName + #10 + Text;

  TThread.ForceQueue(nil, procedure  // sonst geht das DropImage nicht weg
    begin
      ShowMessage(Text);
    end);
end;

procedure TFMXStyleDemoForm.Edit1Change(Sender: TObject);
begin
  if not FEnableChangeEvents then
    Exit;
  FEnableChangeEvents := False;
  try
    var Value := (Sender as TEdit).Text;
    Edit1.Text      := Value;  // TCustomEdit   Model.Text
    ComboEdit1.Text := Value;  // TCustomEdit   Model.Text
    ComboBox1.ItemIndex := ComboBox1.Items.IndexOf(Value);
  finally
    FEnableChangeEvents := True;
  end;
end;

procedure TFMXStyleDemoForm.Edit2Change(Sender: TObject);
begin
  if not FEnableChangeEvents then
    Exit;
  FEnableChangeEvents := False;
  try
    for var idx := 2 to 8 do
      (Self.FindComponent('Edit' + idx.ToString) as TEdit).Text := (Sender as TEdit).Text;
    TimerButtonEdit.Enabled := False;
    TimerButtonEdit.Enabled := Edit2.Text.Trim = '';
  finally
    FEnableChangeEvents := True;
  end;
end;

procedure TFMXStyleDemoForm.EditButton1Click(Sender: TObject);
begin
  if Sender is TClearEditButton then
    FClickNotifierHint := 'Clear'
  else if Sender is TPasswordEditButton then
    FClickNotifierHint := 'Show';
  ButtonClickNotifier(Sender);
end;

procedure TFMXStyleDemoForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  FMXStyleOverviewForm.CheckDemoForm.IsChecked := False;
end;

procedure TFMXStyleDemoForm.FormCreate(Sender: TObject);
begin
  ControlHintPanel.Visible := False;

  var PathData:= TPathData.Create;
  PathData.AddRectangle(RectF(20, 20, 80, 80), 0, 0, AllCorners);
  PathData.AddRectangle(RectF(10, 10, 90, 90), 0, 0, AllCorners);
  PathData.AddRectangle(RectF(0, 0, 100, 100), 0, 0, AllCorners);
  PathLabel1.Data := PathData;

  // TButton with Style
  for var idx := GroupToolButtons.ControlsCount - 1 downto 0 do
    if GroupToolButtons.Controls[idx] is TButton then begin
      var Control := TButton(GroupToolButtons.Controls[idx]);
      Control.Hint := Control.StyleLookup;
    end;

  // TButton with EditButton
  for var idx := Panel6.ControlsCount - 1 downto 0 do
    if Panel6.Controls[idx] is TEdit then begin
      // All, such as TPasswordEditButton, is an TEditButton/TCustomButton,
      // except for TSpinEditButton, which is onle a TStyledControl.
      var Control   := TEdit(Panel6.Controls[idx]);
      var Button    := Control.ButtonsContent.Children[0] as TStyledControl;
      Control.Hint  := Control.ClassName + ' + ' + Button.ClassName;
      Button.Hint   := Button.ClassName;
    end;

  // Animation-Modes
  for var idx := Panel1.ControlsCount - 1 downto 0 do
    if Panel1.Controls[idx] is TSmallScrollBar then begin
      var Control   := TSmallScrollBar(Panel1.Controls[idx]);
      var Animation := Control.Children[0] as TFloatAnimation;
      Control.Hint  := GetEnumName(TypeInfo(TInterpolationType), Ord(Animation.Interpolation));
    end;

  // Splitter
  Panel3.Hint := TSplitter.ClassName;
  Label3.Hint := TSplitter.ClassName;
  for var idx := Panel3.ControlsCount - 1 downto 0 do begin
    var Control  := Panel3.Controls[idx];
    Control.Hint := TSplitter.ClassName;
   end;

  // Click-Notification on Buttons
  // MouseMove-Event for Magnifying Glass-View
  // Component Type-Names, for the rest
  // Enable Hints
  for var idx := ComponentCount - 1 downto 0 do
    if Components[idx] is TControl then begin
      var Control := TControl(Components[idx]);

      if not Assigned(Control.OnMouseMove) then
        Control.OnMouseMove := FormMouseMove;

      if (Control is TCustomButton) and not Assigned(Control.OnClick) then  // TButton, TCornerButton, TSpeedButton (TColorButton)
        Control.OnClick := ButtonClickNotifier;

      if (Control.Hint = '')
        and not MatchText(Control.ClassName, ['TLayout', 'TPanel', 'TGroupBox'])
        and not (Control = ControlHintPanel)
      then
        Control.Hint := Control.ClassName;

      if Control.Hint <> '' then begin
        Control.ShowHint := True;
        if not Control.HitTest then  // Labels
          Control.HitTest := True;
      end;
    end;

  FEnableChangeEvents := True;  // ab jetzt alle Change-Events aktiviert
end;

procedure TFMXStyleDemoForm.FormMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Single);
begin
  if Sender = Self then begin
    MagnifierGlass1.ZoomRegionCenter.X := X;
    MagnifierGlass1.ZoomRegionCenter.Y := Y;
  end else begin
    var Mouse := (Sender as TControl).LocalToAbsolute(PointF(X, Y));
    MagnifierGlass1.ZoomRegionCenter.X := Mouse.X;
    MagnifierGlass1.ZoomRegionCenter.Y := Mouse.Y;
  end;
end;

procedure TFMXStyleDemoForm.Grid1GetValue(Sender: TObject; const ACol, ARow: Integer; var Value: TValue);
begin
  case ACol of
    0: Value := 'a' + ARow.ToString;
    1: Value := (ARow * 10) mod Round(ProgressColumn1.Max + 1);
    2: case ARow mod 3 of
         0: Value.FromVariant(Null);
         1: Value := False;
         2: Value := True;
       end;
  end;
end;

procedure TFMXStyleDemoForm.NumberBox1Change(Sender: TObject);
begin
  if not FEnableChangeEvents then
    Exit;
  FEnableChangeEvents := False;
  try
    var Value := (Sender as TCustomEditBox).Value;
    NumberBox1.Value     := Value;  // TCustomEditBox   Model.Value
    SpinBox1.Value       := Value;  // TCustomEditBox   Model.Value
    ComboTrackBar1.Value := Value;  // TCustomEditBox   Model.Value
  finally
    FEnableChangeEvents := True;
  end;
end;

procedure TFMXStyleDemoForm.SkLabel1Words5Click(Sender: TObject);
begin
  ButtonClickNotifier(SkLabel1);
end;

procedure TFMXStyleDemoForm.SpinEditButton1DownClick(Sender: TObject);
begin
  FClickNotifierHint := 'DownClick';
  ButtonClickNotifier(SpinEditButton1);
end;

procedure TFMXStyleDemoForm.SpinEditButton1UpClick(Sender: TObject);
begin
  FClickNotifierHint := 'UpClick';
  ButtonClickNotifier(SpinEditButton1);
end;

procedure TFMXStyleDemoForm.TimerButtonEditTimer(Sender: TObject);
begin
  for var idx := 2 to 8 do
    if (Self.FindComponent('Edit' + idx.ToString) as TEdit).IsFocused then
      Exit;
  TimerButtonEdit.Enabled := False;
  if Edit2.Text.Trim = '' then
    Edit2.Text := 'Test';  // update Edit3 to Edit8, see Edit2Change
end;

procedure TFMXStyleDemoForm.TrackBar1Change(Sender: TObject);
begin
  if not FEnableChangeEvents then
    Exit;
  FEnableChangeEvents := False;
  try
    var Value := 0.0;
    case IndexText((Sender as TControl).Name, [ArcDial1.Name, TrackBar1.Name, ScrollBar1.Name, SmallScrollBar1.Name]) of
      0:  if ArcDial1.Value < 0 then
            Value := (ArcDial1.Value + 360) / 3.6  // 0..-180 -> 0..50
          else
            Value := ArcDial1.Value         / 3.6;  // +180..0 -> 50..100
      1:    Value := TrackBar1.Value;
      2, 3: Value := TScrollBar(Sender).Value;
    end;
    ArcDial1.Value        := Value * 3.6;  // TArcDial (FValueRange.RelativeValue * 360) - 180
    TrackBar1.Value       := Value;  // TCustomTrack   FValueRange.Value
    SmallScrollBar1.Value := Value;  // TScrollBar     FValueRange.Value
    ScrollBar1.Value      := Value;  // TScrollBar     FValueRange.Value
    ProgressBar1.Value    := Value;  // TProgressBar   FValueRange.Value
  finally
    FEnableChangeEvents := True;
  end;
end;

procedure TFMXStyleDemoForm.TrackMagnifierGlassChange(Sender: TObject);
begin
  MagnifierGlass1.LoupeScale := TrackMagnifierGlass.Value;
end;

end.

