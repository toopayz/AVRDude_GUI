unit FormAvrDude;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ComCtrls, StdCtrls,
  ExtCtrls, ActnList, Windows, ATButtons, BCLabel, BCMDButton, BGRAShape,
  BCListBox, BCButton, ueled;

type    

  TPageControl = class(ComCtrls.TPageControl)
  private
    FCanvas: TCanvas;
    procedure TCMAdjustRect(var Msg: TMessage); message TCM_ADJUSTRECT;
  protected
    procedure PaintWindow(DC: HDC); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy(); override;
  end;

  { TFrTemplate }

  TFrTemplate = class(TForm)
    BCLabel18: TBCLabel;
    BtHelp: TBCButton;
    BtMinim: TBCButton;
    BtConfig: TBCButton;
    BtRadar: TBCButton;
    BtConnect: TBCButton;
    BtReset: TBCButton;
    BtClose: TBCButton;
    BtSend: TBCButton;
    PnRadar: TPaintBox;
    ShBack00: TBGRAShape;
    PageControl1: TPageControl;
    ShBack01: TBGRAShape;
    ShBack02: TBGRAShape;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    DotLed: TuELED;
    procedure FormCreate(Sender: TObject); 
    procedure GeneralButtonEvent(Sender: TObject);
    procedure ShBack00MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure ShBack00MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
  private

  public

  end;

var
  FrTemplate: TFrTemplate; 
  vrOldXX, vrOldYY  : integer;

implementation

{$R *.lfm}

{ TFrTemplate }


//-------------------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------- PageControl Initial
procedure TPageControl.TCMAdjustRect(var Msg: TMessage);
begin
  inherited;
  if Msg.WParam = 0 then
    InflateRect(PRect(Msg.LParam)^, 4, 4)
  else
    InflateRect(PRect(Msg.LParam)^, -4, -4);
end;

procedure TPageControl.PaintWindow(DC: HDC);
begin
  inherited PaintWindow(DC);
  FCanvas.Handle := DC;
  FCanvas.Brush.Color := clBlack;//change the color acording to your needs
  FCanvas.FillRect(Self.ClientRect);
end;

constructor TPageControl.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FCanvas := TCanvas.Create();
end;

destructor TPageControl.Destroy();
begin
  FCanvas.Free;
  inherited Destroy();
end;
                                                                                                
//-------------------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------- Form Create
procedure TForm2.FormCreate(Sender: TObject);
begin
  SetWindowLong(Handle, GWL_EXSTYLE, GetWindowLong(Handle, GWL_EXSTYLE) or WS_EX_LAYERED);
  SetLayeredWindowAttributes(Handle,clAqua,255,LWA_COLORKEY);
  Pagecontrol1.ShowTabs :=  FALSE;
  ShBack00.Align        :=  AlCLient;
  ShBack01.Align        :=  AlCLient;
  ShBack02.Align        :=  AlCLient;
  PageControl1.ActivePageIndex  :=  0;
end;
                     
//-------------------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------- Form Mouse Event
procedure TForm2.ShBack00MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  vrOldXX :=  mouse.CursorPos.x - Left;
  vrOldYY :=  mouse.CursorPos.Y - Top;
end;

procedure TForm2.ShBack00MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  if Shift=[ssLeft] then
  begin
    Left  :=  mouse.CursorPos.x - vrOldXX;
    Top   :=  mouse.CursorPos.Y - vrOldYY;
  end;
end;
                                 
//-------------------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------- Form Mouse Event
procedure TForm2.GeneralButtonEvent(Sender: TObject);
begin
  if sender=BtCLose     then  Application.Terminate;
  if sender=BtMinim     then  Application.Minimize;
//if sender=BtHelp      then  showmessage('');
  if sender=BtRadar     then  PageControl1.ActivePageIndex :=  0;
  if sender=BtConfig    then  PageControl1.ActivePageIndex :=  1;
//if sender=BtClear     then  begin   COM_LineNow :=  -1;   MemRecv.Clear;  end;
end;                



end.




