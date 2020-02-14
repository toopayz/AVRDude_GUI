unit FormLog;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls;

type

  { TFLog }

  TFLog = class(TForm)
    MLog: TMemo;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private

  public

  end;

var
  FLog: TFLog;

implementation

Uses  FormDude; 
const
  csLogFile     = 'LogFile.txt';

{$R *.lfm}

{ TFLog }

procedure TFLog.FormCreate(Sender: TObject);
begin
  MLog.Clear;
  try
    MLog.Lines.SaveToFile(AVR_DudeDir+csLogFile);
  finally
  end;
end;

procedure TFLog.FormShow(Sender: TObject);
var StrX  : String;
begin
  StrX        :=  AVR_DudeDir+csLogFile;
  Caption     :=  StrX;
  DUDE_IsRun  :=  FALSE;
  if Fileexists(StrX) then  Mlog.Lines.LoadFromFile(StrX);
end;

end.

