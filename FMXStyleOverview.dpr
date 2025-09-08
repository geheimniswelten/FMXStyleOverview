program FMXStyleOverview;

uses
  System.StartUpCopy,
  FMX.Forms,
  FMXStyleOverviewMain in 'FMXStyleOverviewMain.pas' {FMXStyleOverviewForm},
  FMXStyleOverviewDemo in 'FMXStyleOverviewDemo.pas' {FMXStyleDemoForm},
  FMXStyleOverviewHelper in 'FMXStyleOverviewHelper.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TFMXStyleOverviewForm, FMXStyleOverviewForm);
  Application.CreateForm(TFMXStyleDemoForm, FMXStyleDemoForm);
  Application.Run;
end.

