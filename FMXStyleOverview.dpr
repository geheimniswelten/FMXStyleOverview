program FMXStyleOverview;

uses
  System.StartUpCopy,
  FMX.Forms,
  FMXStyleOverviewMain in 'FMXStyleOverviewMain.pas' {FMXStyleOverviewForm};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TFMXStyleOverviewForm, FMXStyleOverviewForm);
  Application.Run;
end.

