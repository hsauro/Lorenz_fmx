unit ufMain;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Ani,
  FMX.Controls.Presentation, FMX.StdCtrls, Skia, Skia.FMX, System.UIConsts,
  FMX.Colors, FMX.Layouts, FMX.ListBox, uPlotPanel, FMX.Edit, FMX.EditBox,
  FMX.NumberBox;

type
  TVector = array[0..2] of double;

  TfrmMain = class(TForm)
    Panel1: TPanel;
    pnlRight: TPanel;
    Panel3: TPanel;
    trackSigma: TTrackBar;
    Label2: TLabel;
    trackBeta: TTrackBar;
    trackRho: TTrackBar;
    Label3: TLabel;
    Label4: TLabel;
    GroupBox1: TGroupBox;
    rdoTime: TRadioButton;
    rdoX: TRadioButton;
    rdoY: TRadioButton;
    rdoZ: TRadioButton;
    GroupBox2: TGroupBox;
    ChkX: TCheckBox;
    chkY: TCheckBox;
    chkZ: TCheckBox;
    colorComboX: TColorComboBox;
    colorComboY: TColorComboBox;
    colorComboZ: TColorComboBox;
    btnPdf: TButton;
    SavePDFDialog: TSaveDialog;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    StyleBook: TStyleBook;
    Label1: TLabel;
    ColorComboBackground: TColorComboBox;
    Label8: TLabel;
    btnSaveAsPng: TButton;
    SavePNGDialog: TSaveDialog;
    lblCoords: TLabel;
    edtSigma: TNumberBox;
    edtBeta: TNumberBox;
    edtRho: TNumberBox;
    SkLabel1: TSkLabel;
    btnAbout: TButton;
    btnAllYAxis: TButton;
    btnRandomize: TButton;
    procedure FormCreate(Sender: TObject);
    procedure trackSigmaChange(Sender: TObject);
    procedure trackBetaChange(Sender: TObject);
    procedure trackRhoChange(Sender: TObject);
    procedure rdoTimeChange(Sender: TObject);
    procedure rdoXChange(Sender: TObject);
    procedure rdoYChange(Sender: TObject);
    procedure rdoZChange(Sender: TObject);
    procedure ChkXChange(Sender: TObject);
    procedure chkYChange(Sender: TObject);
    procedure chkZChange(Sender: TObject);
    procedure colorComboXChange(Sender: TObject);
    procedure colorComboYChange(Sender: TObject);
    procedure colorComboZChange(Sender: TObject);
    procedure btnPdfClick(Sender: TObject);
    procedure ColorComboBackgroundChange(Sender: TObject);
    procedure btnSaveAsPngClick(Sender: TObject);
    procedure btnAboutClick(Sender: TObject);
    procedure btnRandomizeClick(Sender: TObject);
    procedure btnAllYAxisClick(Sender: TObject);
    procedure edtSigmaChange(Sender: TObject);
    procedure edtBetaChange(Sender: TObject);
    procedure edtRhoChange(Sender: TObject);
  private
    { Private declarations }
    hstep : double;
    numPoints : integer;
    procedure OnMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Single);
  public
    { Public declarations }
    plotPanel : TPlotPanel;
    sigma, rho, beta : double;
    procedure runSimulation;
    procedure lorenz (var x, dy : TVector);
  end;

var
  frmMain: TfrmMain;

implementation

{$R *.fmx}

const
  TIME_COLUMN = 0;
  X_COLUMN = 1;
  Y_COLUMN = 2;
  Z_COLUMN = 3;


// -----------------------------------------------------------------------------------


procedure TfrmMain.OnMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Single);
begin
  lblCoords.text := 'Mouse Coords: ' + inttostr (trunc (x)) + ', ' + inttostr (trunc (y));
end;


// Generate pdf output
procedure TfrmMain.btnAboutClick(Sender: TObject);
begin
  ShowMessage('Veison 1.1, running skia ' + skia.SkVersion);
end;


procedure TfrmMain.btnPdfClick(Sender: TObject);
begin
  if plotPanel.data.nRows = 0 then exit;

  if SavePDFDialog.Execute then
     plotPanel.exportToPdf(SavePDFDialog.FileName);
end;


// Generate png output
procedure TfrmMain.btnSaveAsPngClick(Sender: TObject);
begin
  if plotPanel.data.nRows = 0 then exit;

  if SavePDFDialog.Execute then
     plotPanel.exportToPng(SavePDFDialog.FileName);
end;

procedure AnimateTrackBarChange(targetTB: TTrackBar; newValue, duration: Single);
begin

end;

procedure RandomizeTrackBarValue(targetTB: TTrackBar);
begin
  var newValue := random(trunc(targetTB.Max));
  var duration := Abs(newValue - targetTB.Value) / 50;

  FMX.Ani.TAnimator.AnimateFloat(targetTB, 'Value',
    newValue, duration);
end;

procedure TfrmMain.btnRandomizeClick(Sender: TObject);
begin
  RandomizeTrackBarValue(trackSigma);
  RandomizeTrackBarValue(trackRho);
  RandomizeTrackBarValue(trackBeta);
end;

procedure TfrmMain.btnAllYAxisClick(Sender: TObject);
begin
  chkX.IsChecked := True;
  chkY.IsChecked := True;
  chkZ.IsChecked := True;
end;

procedure TfrmMain.ChkXChange(Sender: TObject);
begin
   if chkX.IsChecked then
      plotPanel.setDataColumnVisibility(X_COLUMN, True)
   else
     plotPanel.setDataColumnVisibility(X_COLUMN, False);
  plotPanel.Redraw;
end;


procedure TfrmMain.chkYChange(Sender: TObject);
begin
   if chkY.IsChecked then
      plotPanel.setDataColumnVisibility(Y_COLUMN, True)
   else
      plotPanel.setDataColumnVisibility(Y_COLUMN, False);
  plotPanel.Redraw;
end;


procedure TfrmMain.chkZChange(Sender: TObject);
begin
   if chkZ.IsChecked then
      plotPanel.setDataColumnVisibility(Z_COLUMN, True)
   else
      plotPanel.setDataColumnVisibility(Z_COLUMN, False);
  plotPanel.Redraw;
end;


procedure TfrmMain.ColorComboBackgroundChange(Sender: TObject);
begin
  plotPanel.backgroundColor := ColorComboBackground.Color;
  plotPanel.Redraw;
end;


procedure TfrmMain.colorComboXChange(Sender: TObject);
begin
  plotPanel.setColumnColor (X_COLUMN, colorComboX.Color);
  plotPanel.Redraw;
end;


procedure TfrmMain.colorComboYChange(Sender: TObject);
begin
  plotPanel.setColumnColor (Y_COLUMN, colorComboY.Color);
  plotPanel.Redraw;
end;


procedure TfrmMain.colorComboZChange(Sender: TObject);
begin
  plotPanel.setColumnColor (Z_COLUMN, colorComboZ.Color);
  plotPanel.Redraw;
end;


procedure TfrmMain.FormCreate(Sender: TObject);
begin
  SkLabel1.Text := Format(SkLabel1.Text,[skia.SkVersion]);

  plotPanel := TPlotPanel.Create(self);
  plotPanel.Parent := pnlRight;
  plotPanel.Align := TAlignLayout.Client;

  plotPanel.x_wmin := 0;
  plotPanel.x_wmax := 30;
  plotPanel.y_wmin := -40;
  plotPanel.y_wmax := 60;

  // Lorenz parameters
  sigma := 10.0;
  beta := 8/3.0;
  rho := 28.0;

  plotPanel.OnMouseMove := OnMouseMove;

  // Create initial simulation data for the lorenz model
  hstep := 0.004;
  numPoints := trunc ((plotPanel.x_wmax - plotPanel.x_wmin)/hstep) + 1;
  plotPanel.allocateSpace(numPoints, 4);
  runSimulation;

  colorComboX.Color := plotPanel.getColumnColor (X_COLUMN);
  colorComboY.Color := plotPanel.getColumnColor (Y_COLUMN);
  colorComboZ.Color := plotPanel.getColumnColor (Z_COLUMN);
  colorComboBackground.Color := plotPanel.backgroundColor;

  plotPanel.setXAxisColumn (TIME_COLUMN);
  plotPanel.setDataColumnVisibility (TIME_COLUMN, False);

  trackSigma.Value := Sigma*10;
  trackBeta.Value := beta*10;
  trackRho.Value := rho*10;

  // Turn them on to allow track events to operate
  trackSigma.enabled := True;
  trackBeta.enabled := True;
  trackRho.enabled := True;
end;


procedure TfrmMain.runSimulation;
var i, j : integer;
    x, dy : TVector;
    t : double;
begin
  // Initial conditions
  x[0] := 1.0; x[1]:= 1.0; x[2] := 1.0;

  t := 0;
  for i := 0 to numPoints - 1 do
      begin
      plotPanel.setData (i, 0, t);
      plotPanel.setData (i, 1, x[0]);
      plotPanel.setData (i, 2, x[1]);
      plotPanel.setData (i, 3, x[2]);
      lorenz (x, dy);
      for j := 0 to 2 do
         x[j] := x[j] + hstep*dy[j];
      t := t + hstep;
      end;
end;


procedure TfrmMain.edtBetaChange(Sender: TObject);
begin
  if Abs(trackBeta.Value*10 - edtBeta.Value) > 0.001 then
    trackBeta.Value := edtBeta.Value*10;
end;

procedure TfrmMain.edtRhoChange(Sender: TObject);
begin
  if Abs(trackRho.Value*10 - edtRho.Value) > 0.001 then
    trackRho.Value := edtRho.Value*10;
end;

procedure TfrmMain.edtSigmaChange(Sender: TObject);
begin
  if Abs(trackSigma.Value*10 - edtSigma.Value) > 0.001 then
    trackSigma.Value := edtSigma.Value*10;
end;

procedure TfrmMain.lorenz (var x, dy :  TVector);
begin
  dy[0] := sigma * (x[1] - x[0]);
  dy[1] := x[0] * (rho - x[2]) - x[1];
  dy[2] := x[0] * x[1] - beta * x[2];
end;


procedure TfrmMain.rdoTimeChange(Sender: TObject);
begin
  plotPanel.x_wmin := 0;
  plotPanel.x_wmax := 30;
  plotPanel.setXAxisColumn(TIME_COLUMN);
  plotpanel.Redraw;
end;


procedure TfrmMain.rdoXChange(Sender: TObject);
begin
  plotPanel.x_wmin := -30;
  plotPanel.x_wmax := 30;
  plotPanel.setXAxisColumn(X_COLUMN);
  plotpanel.Redraw;
end;


procedure TfrmMain.rdoYChange(Sender: TObject);
begin
  plotPanel.x_wmin := -30;
  plotPanel.x_wmax := 30;
  plotPanel.setXAxisColumn(Y_COLUMN);
  plotpanel.Redraw;
end;


procedure TfrmMain.rdoZChange(Sender: TObject);
begin
  plotPanel.x_wmin := 0;
  plotPanel.x_wmax := 60;
  plotPanel.setXAxisColumn(Z_COLUMN);
  plotpanel.Redraw;
end;


procedure TfrmMain.trackBetaChange(Sender: TObject);
begin
  if trackBeta.Enabled then
     begin
     edtbeta.text := Format ('%2.2f', [trackBeta.Value/10]);
     beta := trackBeta.Value/10;
     runSimulation;
     plotPanel.Redraw;
     end;
end;


procedure TfrmMain.trackRhoChange(Sender: TObject);
begin
  if trackRho.Enabled then
     begin
     edtRho.text := Format ('%2.2f', [trackRho.Value/10]);
     rho := trackRho.Value/10;
     runSimulation;
     plotPanel.Redraw;
     end;
end;


procedure TfrmMain.trackSigmaChange(Sender: TObject);
begin
  if trackSigma.Enabled then
     begin
     edtSigma.Text := Format ('%2.2f', [trackSigma.Value/10]);
     sigma := trackSigma.Value/10;
     runSimulation;
     plotPanel.Redraw;
     end;
end;

end.
