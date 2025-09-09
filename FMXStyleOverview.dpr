program FMXStyleOverview;

uses
  System.StartUpCopy,
  FMX.Forms,
  FMXStyleOverviewHelper in 'FMXStyleOverviewHelper.pas',
  FMXStyleOverviewMain in 'FMXStyleOverviewMain.pas' {FMXStyleOverviewForm},
  FMXStyleOverviewDemo in 'FMXStyleOverviewDemo.pas' {FMXStyleDemoForm};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TFMXStyleOverviewForm, FMXStyleOverviewForm);
  Application.CreateForm(TFMXStyleDemoForm, FMXStyleDemoForm);
  Application.Run;
end.

