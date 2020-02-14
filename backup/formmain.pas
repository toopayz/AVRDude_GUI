unit FormMain;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ComCtrls, StdCtrls,
  ExtCtrls, ActnList, Windows, LazSerial, ECTabCtrl, BCLabel, IniFiles,
  ECGroupCtrls, BCMDButton, BGRAShape, BCListBox, BCButton, ueled,
  PyzControlWinDevice, process;

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

  { TFDude }

  TFDude = class(TForm)
    CekLog: TCheckBox;
    LabCom: TBCLabel;
    LabCom1: TBCLabel;
    LabInfo: TBCLabel;
    BtHelp: TBCButton;
    BtMinim: TBCButton;
    Image1: TImage;
    BtScan: TBCButton;
    BtSettings: TBCButton;
    BtRecv: TBCButton;
    BtClose: TBCButton;
    BCLabel1: TBCLabel;
    BGRAShape2: TBGRAShape;
    Process1: TProcess;
    ShBack01: TBGRAShape;
    ShBack00: TBGRAShape;
    ComList: TListBox;
    PageControl1: TPageControl;
    ShBack02: TBGRAShape;
    TabSheet1: TTabSheet;
    TabSheet4: TTabSheet;
    TimRUn: TTimer;
    TimLed: TTimer;
    procedure BtSendClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure GeneralButtonEvent(Sender: TObject);  
    procedure ComConfigEvent(Sender: TObject); 
    procedure BtConnectClick(Sender: TObject);
    procedure LazComRxData(Sender: TObject);
    procedure LedRTSClick(Sender: TObject);
    procedure ShBack00MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure ShBack00MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure TimRUnTimer(Sender: TObject);  
    procedure ProcessData(StDt:String);
  private      
    COM_OldXX, COM_OldYY  : integer;
  public

  end;

var
  FDude: TFDude;
  AVR_AppDir    : String='';

implementation

{$R *.lfm}

const
  csLoad        = FALSE;
  csSave        = TRUE;     
  csConfigFile  = 'PayZConfig.ini';  
  LogFile       = 'LogFile.txt';
  csInfo        = 'AVRDude GUI v1.0 [201908]'+#13#10+
                  'by : TooPayZ'+#13#10+
                  'GUI (Graphical User Interface) yang memanfaatkan aplikasi AVRDude.exe'+#13#10+
                  'Tujuannya untuk mempermudah penggunaan AVRDude.exe'+#13#10+
                  'Please Enjoy it...^^...'+#13#10+#13#10+
                  'AVRDude by Brian S. Dean'+#13#10+
                  'https://www.nongnu.org/avrdude/';

{ TFDude }
//==========================================================================================  PageControl Initial
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

//--------------------------------------------------------------------------------------------- Scan Port
procedure ReScanPortCOM(ComList : TListBox);
var	SList	:	Tstringlist;
  	//i			:	integer;
    //StrX,Sok	: string;
begin
  ComList.Clear;
  SList		          :=	Loaddevices(GUID_DEVCLASS_PORT);
  ComList.Items	    := 	SList;
  ComList.ItemIndex :=  -1; 
  SList.Free;
end;

//==================================================================================================================
//--------------------------------------------------------------------------------------------- Form event
procedure TFDude.FormCreate(Sender: TObject);
begin
  SetWindowLong(Handle, GWL_EXSTYLE, GetWindowLong(Handle, GWL_EXSTYLE) or WS_EX_LAYERED);
  SetLayeredWindowAttributes(Handle,clAqua,255,LWA_COLORKEY);
  Pagecontrol1.ShowTabs :=  FALSE; 
  ShBack00.Align        :=  AlCLient;
  ShBack01.Align        :=  AlCLient;
  ShBack02.Align        :=  AlCLient;
  Pagecontrol1.Height   :=  445;
  AVR_AppDir            :=  GetCurrentDir+'\'; 
  LabInfo.Caption       :=  csInfo;
  PageControl1.ActivePageIndex  :=  0;
  ReScanPortCOM(ComList);
  //-----------------------------------
end;

//--------------------------------------------------------------------------------------------- Form Mouse Move
procedure TFDude.ShBack00MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  COM_OldXX :=  mouse.CursorPos.x - Left;
  COM_OldYY :=  mouse.CursorPos.Y - Top;
end;

procedure TFDude.ShBack00MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  if Shift=[ssLeft] then
  begin
    Left  :=  mouse.CursorPos.x - COM_OldXX;
    Top   :=  mouse.CursorPos.Y - COM_OldYY;
  end;
end;
        
//--------------------------------------------------------------------------------------------- All Button Event
procedure TFDude.GeneralButtonEvent(Sender: TObject);
begin
  if sender=BtCLose     then  Application.Terminate;
  if sender=BtMinim     then  Application.Minimize;
  if sender=BtSettings  then  PageControl1.ActivePageIndex  :=  0;
  if sender=BtRecv      then  PageControl1.ActivePageIndex  :=  1;
  if sender=BtHelp      then  PageControl1.ActivePageIndex  :=  2;
  if sender=BtScan      then  ReScanPortCOM(ComList);
end;
                                                                                                                  
//==================================================================================================================
//--------------------------------------------------------------------------------------------- AVRDude Run Command 
procedure RunAvrDude(StCom, StFile : String);
var AProcess  : TProcess;
    StDude    : String;
begin
  StDude  :=  AVR_AppDir+'avrdude-6.3\avrdude.exe';
  if NOT FileExists(StDude) then
  begin
    Showmessage('Aplikasi AVRDude.exe tidak ditemukan.'+#13#10+
                'Lokasi File "'+StDude+'".');
    exit;
  end;
  //--------------------------------------------------------
  if NOT FileExists(StFile) then
  begin
    Showmessage('File yang akan di upload tidak ditemukan.'+#13#10+
                'Lokasi File "'+StFile+'".');
    Exit;
  end;
  //-------------------------------------------------------- 
  //avrdude-6.3\avrdude -C M128_Payz.conf -v -patmega128 -carduino -PCOM4 -b115200 -D
  //-Uflash:w:"E:\Lazarus\Lazarus My Lib\Description App\Board Description\ATmega128 v1.0 Trainer\Test ALCD.hex":i
  //HexFile :=  '-CM128_Payz.conf -v -patmega128 -carduino -P'+FView.LabCOM.Hint+' -b115200 -D -Uflash:w:"'+StFile+'":i';
  AProcess  :=  TPRocess.Create(nil);
  AProcess.CurrentDirectory :=  AVR_AppDir+'avrdude-6.3\';
  AProcess.Executable       :=  'cmd';
  AProcess.Options          :=  [poUsePipes,poNoConsole];
//AProcess.ShowWindow       :=  swoHIDE;
  AProcess.Parameters.Add('/c');
  AProcess.Parameters.Add('Avrdude.exe');
  AProcess.Parameters.Add('-CM128_Payz.conf');
  AProcess.Parameters.Add('-v');
  AProcess.Parameters.Add('-patmega128');
  AProcess.Parameters.Add('-carduino');
  AProcess.Parameters.Add('-P'+StCom);
  AProcess.Parameters.Add('-b115200');
  AProcess.Parameters.Add('-D');
  AProcess.Parameters.Add('-Uflash:w:"'+StFile+'":i');
  if FDude.CekLog.Checked then  AProcess.Parameters.Add('-l"'+LogFile+'"');
  AProcess.Execute;
  AProcess.Free;
end;

procedure TFDude.TimRUnTimer(Sender: TObject);
var StrX    : String;
    TmLine, X  : Integer;
begin
  LedCTS.Active   :=  LazCom.GetCTS;
  LedDSR.Active   :=  LazCom.GetDSR;
  LedRI.Active    :=  LazCom.GetRing;
  LedCD.Active    :=  LazCom.GetCarrier;
  //-----------------------------------------------
  TmLine  :=  MemRecv.Lines.count-1;
  if (COM_LineNow <> TmLine) then
  begin
    if (COM_LineNow > TmLine) then COM_LineNow := -1;
    if TmLine<>COM_LineNow then
      for  X:=COM_LineNow to TmLine do
      begin          
        LabRecv.Caption  := '';
        StrX := MemRecv.Lines[X];
        if (length(StrX)>4) then
          if ((StrX[1]=COM_Start) AND (StrX[length(StrX)]=COM_End)) then
          begin
            LabRecv.Caption  :=  LabRecv.Caption+StrX;
            ProcessData(StrX);
          end;
      end;
      COM_LineNow  := TmLine;
  end;                   
  //-----------------------------------------------
  LabLine.Caption :=  'Now : '+inttostr(COM_LineNow)+
                      '    |    Line : '+inttostr(COM_LineNow);
  if (COM_LineNow>1000) then
  begin
    COM_Data  := COM_Data + MemRecv.Text;
    GeneralButtonEvent(BtClear);
  end;
end;


end.




