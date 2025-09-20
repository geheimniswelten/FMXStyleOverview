program FMXStyleOverview;

uses
  System.StartUpCopy,
  FMX.Forms,
  h5u.ResFile in 'h5u.ResFile.pas',
  FMXStyleOverviewMain in 'FMXStyleOverviewMain.pas' {FMXStyleOverviewForm},
  FMXStyleOverviewDemo in 'FMXStyleOverviewDemo.pas' {FMXStyleDemoForm};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TFMXStyleOverviewForm, FMXStyleOverviewForm);
  Application.CreateForm(TFMXStyleDemoForm, FMXStyleDemoForm);
  Application.Run;
end.

