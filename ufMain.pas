unit ufMain;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.Controls.Presentation, FMX.StdCtrls, Skia, Skia.FMX, System.UIConsts,
  FMX.Colors, FMX.Layouts, FMX.ListBox, uPlotPanel;

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
    lblSigma: TLabel;
    lblBeta: TLabel;
    lblRho: TLabel;
    SkLabel1: TSkLabel;
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
  private
    { Private declarations }
    procedure OnMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Single);
  public
    { Public declarations }
    plotPanel : TPlotPanel;
    sigma, rho, beta : double;
    procedure generateData;
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


procedure TfrmMain.ChkXChange(Sender: TObject);
begin
   if chkX.IsChecked then
         plotPanel.data.columns[X_COLUMN].visible := True
      else
         plotPanel.data.columns[X_COLUMN].visible := False;
  plotPanel.Redraw;
end;


procedure TfrmMain.chkYChange(Sender: TObject);
begin
   if chkY.IsChecked then
         plotPanel.data.columns[Y_COLUMN].visible := True
      else
         plotPanel.data.columns[Y_COLUMN].visible := False;
  plotPanel.Redraw;
end;


procedure TfrmMain.chkZChange(Sender: TObject);
begin
   if chkZ.IsChecked then
         plotPanel.data.columns[Z_COLUMN].visible := True
      else
         plotPanel.data.columns[Z_COLUMN].visible := False;
  plotPanel.Redraw;
end;


procedure TfrmMain.ColorComboBackgroundChange(Sender: TObject);
begin
  plotPanel.backgroundColor := ColorComboBackground.Color;
  plotPanel.Redraw;
end;


procedure TfrmMain.colorComboXChange(Sender: TObject);
begin
  plotPanel.data.columns[X_COLUMN].color := colorComboX.Color;
  plotPanel.Redraw;
end;


procedure TfrmMain.colorComboYChange(Sender: TObject);
begin
  plotPanel.data.columns[Y_COLUMN].color := colorComboY.Color;
  plotPanel.Redraw;
end;


procedure TfrmMain.colorComboZChange(Sender: TObject);
begin
  plotPanel.data.columns[Z_COLUMN].color := colorComboZ.Color;
  plotPanel.Redraw;
end;


procedure TfrmMain.FormCreate(Sender: TObject);
begin
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

  trackSigma.Value := Sigma*10;
  trackBeta.Value := beta*10;
  trackRho.Value := rho*10;

  plotPanel.OnMouseMove := OnMouseMove;

  // Create simulation data for lorenz model
  generateData;

  colorComboX.Color := plotPanel.data.columns[X_COLUMN].color;
  colorComboY.Color := plotPanel.data.columns[Y_COLUMN].color;
  colorComboZ.Color := plotPanel.data.columns[Z_COLUMN].color;
  colorComboBackground.Color := plotPanel.backgroundColor;

  plotPanel.setXAxisColumn (TIME_COLUMN);
  plotPanel.setDataColumnVisibility (TIME_COLUMN, False);

  plotPanel.Redraw;
end;


procedure TfrmMain.generateData;
var i, j : integer;
    x, dy : TVector;
    t, hstep : double;
    numPoints : integer;
begin
  hstep := 0.004;
  numPoints := trunc ((plotPanel.x_wmax - plotPanel.x_wmin)/hstep) + 1;
  x[0] := 1.0; x[1]:= 1.0; x[2] := 1.0;
  plotPanel.setUpData(numPoints, 4);
  plotPanel.data.columns[TIME_COLUMN].visible := False;

  t := 0;
  for i := 0 to numPoints - 1 do
      begin
      plotPanel.data.setData(i, 0, t);
      plotPanel.data.setData(i, 1, x[0]);
      plotPanel.data.setData(i, 2, x[1]);
      plotPanel.data.setData(i, 3, x[2]);
      lorenz (x, dy);
      for j := 0 to 2 do
         x[j] := x[j] + hstep*dy[j];
      t := t + hstep;
      end;
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
  plotPanel.data.XColumnIndex := TIME_COLUMN;
  plotpanel.Redraw;
end;

procedure TfrmMain.rdoXChange(Sender: TObject);
begin
  plotPanel.x_wmin := -30;
  plotPanel.x_wmax := 30;
  plotPanel.data.XColumnIndex := X_COLUMN;
  plotpanel.Redraw;
end;

procedure TfrmMain.rdoYChange(Sender: TObject);
begin
  plotPanel.x_wmin := -30;
  plotPanel.x_wmax := 30;
  plotPanel.data.XColumnIndex := Y_COLUMN;
  plotpanel.Redraw;
end;

procedure TfrmMain.rdoZChange(Sender: TObject);
begin
  plotPanel.x_wmin := 0;
  plotPanel.x_wmax := 60;
  plotPanel.data.XColumnIndex := Z_COLUMN;
  plotpanel.Redraw;
end;

procedure TfrmMain.trackBetaChange(Sender: TObject);
begin
  lblbeta.text := Format ('%2.2f', [trackBeta.Value/10]);
  beta := trackBeta.Value/10;
  generateData;
  plotPanel.Redraw;
end;

procedure TfrmMain.trackRhoChange(Sender: TObject);
begin
  lblRho.text := Format ('%2.2f', [trackRho.Value/10]);
  rho := trackRho.Value/10;
  generateData;
  plotPanel.Redraw;
end;

procedure TfrmMain.trackSigmaChange(Sender: TObject);
begin
  lblSigma.Text := Format ('%2.2f', [trackSigma.Value/10]);
  sigma := trackSigma.Value/10;
  generateData;
  plotPanel.Redraw;
end;

end.