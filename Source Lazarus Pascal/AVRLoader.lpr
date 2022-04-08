program AVRLoader;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, FormDude, uecontrols, LazSerialPort, FormLog, FormSmall
  { you can add units after this };

{$R *.res}

begin
  RequireDerivedFormResource:=True;
  Application.Title:='AVRDude GUI by TooPayZ';
  Application.Scaled:=True;
  Application.Initialize;
  Application.CreateForm(TFDude, FDude);
  Application.CreateForm(TFLog, FLog);
  Application.CreateForm(TFSmall, FSmall);
  Application.Run;
end.

