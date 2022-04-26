program Lorenzfmx;

uses
  System.StartUpCopy,
  FMX.Forms,
  FMX.Types,
  Skia.FMX,
  ufMain in 'ufMain.pas' {frmMain},
  uPlotPanel in 'uPlotPanel.pas';

{$R *.res}

begin
  GlobalUseMetal := True;
  GlobalUseSkiaRasterWhenAvailable := False;
  GlobalUseSkia := True;
  Application.Initialize;
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.
