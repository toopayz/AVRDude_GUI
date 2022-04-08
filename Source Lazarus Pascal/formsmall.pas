unit FormSmall;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, BCButton,
  BGRAShape, BCLabel, Windows;

type

  { TFSmall }

  TFSmall = class(TForm)
    BtClose: TBCButton;
    BtDude: TBCButton;
    BtBack: TBCButton;
    BtMove: TBCButton;
    Image1: TImage;
    LabFlash: TBCLabel;
    ShBack00: TBGRAShape;
    ShBack1: TBGRAShape;
    procedure BtCloseClick(Sender: TObject);
    procedure BtMoveMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure BtMoveMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    SMALL_OldXX, SMALL_OldYY  : integer;
  public

  end;

var
  FSmall: TFSmall;

implementation

{$R *.lfm}

uses FormDude;

{ TFSmall }

procedure TFSmall.FormCreate(Sender: TObject);
begin
  Color       :=  $000D0D0D;
  SetWindowLong(Handle, GWL_EXSTYLE, GetWindowLong(Handle, GWL_EXSTYLE) or WS_EX_LAYERED);
  SetLayeredWindowAttributes(Handle, $000D0D0D,255,LWA_COLORKEY);
  top   :=  (Screen.Height - Height) div 2;
  Left  :=  (Screen.Width - width) div 2;
end;

procedure TFSmall.FormShow(Sender: TObject);
begin
  LabFlash.Caption  := FDude.LabFlash.Caption;
end;

procedure TFSmall.BtMoveMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  SMALL_OldXX :=  mouse.CursorPos.x - Left;
  SMALL_OldYY :=  mouse.CursorPos.Y - Top;
end;

procedure TFSmall.BtMoveMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin     
  if Shift=[ssLeft] then
  begin
    Left  :=  mouse.CursorPos.x - SMALL_OldXX;
    Top   :=  mouse.CursorPos.Y - SMALL_OldYY;
  end;
end;
   
procedure TFSmall.BtCloseClick(Sender: TObject);
begin
  if sender=BtClose   then  Application.Terminate;
  if sender=BtBack    then  begin FDUde.Show; Close;  end;
  if sender=LabFlash  then  FDude.OpenFileClick(Sender);
  if sender=BtDude    then  FDude.BtDudeClick(FDude.BtDude);
end;

end.

