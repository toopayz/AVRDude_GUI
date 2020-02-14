unit FormComAdv;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ComCtrls, StdCtrls,
  ExtCtrls, ActnList, Windows, LazSerial, ECTabCtrl, BCLabel, IniFiles,
  ECGroupCtrls, BCMDButton, BGRAShape, BCListBox, BCButton, ueled,
  PyzControlWinDevice;

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

  { TFPortCOM }

  TFPortCOM = class(TForm)
    BCLabel11: TBCLabel;
    BCLabel12: TBCLabel;
    BCLabel13: TBCLabel;
    BCLabel14: TBCLabel;
    BCLabel15: TBCLabel;
    BCLabel16: TBCLabel;
    BCLabel17: TBCLabel;
    BCLabel18: TBCLabel;
    BCLabel19: TBCLabel;
    LabInfo: TBCLabel;
    BtHelp: TBCButton;
    BtMiMax: TBCButton;
    BtMinim: TBCButton;
    CbStart: TComboBox;
    CbEnd: TComboBox;
    Image1: TImage;
    LabRecv: TBCLabel;
    BtScan: TBCButton;
    BtSettings: TBCButton;
    BtRecv: TBCButton;
    BtConnect: TBCButton;
    BCLabel10: TBCLabel;
    BCLabel8: TBCLabel;
    BCLabel9: TBCLabel;
    BtClear: TBCButton;
    BtClose: TBCButton;
    BCLabel1: TBCLabel;
    BtSend: TBCButton;
    CekCR: TCheckBox;
    CekLF: TCheckBox;
    BtPause: TCheckBox;
    CbTimer: TComboBox;
    EdSend: TComboBox;
    LazSerial1: TLazSerial;
    LedCTS: TuELED;
    LedCD: TuELED;
    LedDSR: TuELED;
    LedRI: TuELED;
    LedDTR: TuELED;
    LedRTS: TuELED;
    BCLabel3: TBCLabel;
    BCLabel4: TBCLabel;
    BCLabel5: TBCLabel;
    BCLabel6: TBCLabel;
    BCLabel7: TBCLabel;
    BGRAShape1: TBGRAShape;
    BGRAShape2: TBGRAShape;
    BGRAShape3: TBGRAShape;
    BGRAShape4: TBGRAShape;
    BGRAShape5: TBGRAShape;
    BGRAShape6: TBGRAShape;
    LabCom: TBCLabel;
    LabLine: TBCLabel;
    LsSend: TListBox;
    MemRecv: TMemo;
    ShBack01: TBGRAShape;
    ShBack00: TBGRAShape;
    LazCom: TLazSerial;
    ComList: TListBox;
    RgBaud: TECRadioGroup;
    PageControl1: TPageControl;
    RgBits: TECRadioGroup;
    RgParity: TECRadioGroup;
    RgStop: TECRadioGroup;
    RgFlow: TECRadioGroup;
    ShBack1: TBGRAShape;
    ShBack02: TBGRAShape;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    TabSheet4: TTabSheet;
    TimRUn: TTimer;
    TimLed: TTimer;
    DotLed: TuELED;
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
  FPortCOM: TFPortCOM;
  COM_LineNow   : Integer=-1;
  COM_Data      : String='';
  COM_AppDir    : String='';
  COM_Start, COM_End    : Char;

implementation

{$R *.lfm}

const
  csConfigFile  = 'PayZConfig.ini';
  csLoad        = FALSE;
  csSave        = TRUE;

{ TFPortCOM }
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
  {//MLog.Lines.Add('/*********************** Enable Disable Device ***********************/');
  for i:=0 to SList.count-1 do
	begin
    StrX	:= '';
    Sok		:= '*';
	  			if DisableDevice(i)=DCROK	then	begin	StrX := 'OK.';	Sok   := ' '; end
    else	if DisableDevice(i)=DCRErrEnumDeviceInfo 				then	StrX  := 'Error Enum.'
    else	if DisableDevice(i)=DCRErrSetClassInstallParams	then	StrX  := 'Error Set Class.'
    else	if DisableDevice(i)=DCRErrDIF_PROPERTYCHANGE 		then	StrX  := 'Error Diff.'
    else	StrX	:= 'No respon';
	  //MLog.Lines.Add('['+Sok+'] '+CbPort.Items[i]+' = '+StrX);
  end;
  for i:=0 to SList.count-1 do
	begin
    StrX	:= '';
    Sok		:= '*';
	  			if EnableDevice(i)=DCROK	then begin	StrX := 'OK.';	Sok := ' '; end
    else	if EnableDevice(i)=DCRErrEnumDeviceInfo 				then	StrX := 'Error Enum.'
    else	if EnableDevice(i)=DCRErrSetClassInstallParams 	then	StrX := 'Error Set Class.'
    else	if EnableDevice(i)=DCRErrDIF_PROPERTYCHANGE 		then	StrX := 'Error Diff.'
    else	StrX	:= 'No respon';
	  //MLog.Lines.Add('['+Sok+'] '+CbPort.Items[i]+' = '+StrX);
  end;
  SList.Free;}
end;
                                      
//--------------------------------------------------------------------------------------------- HandShake Char
Procedure InitCbHandShakeChar(CbTMp : TComboBox);
var x     : integer;
begin
  CbTMp.Items.Clear;
  CbTMp.Items.Add('CR');
  CbTMp.Items.Add('LF');
  CbTMp.Items.Add('SPACE');
  for x:=33 to 126 do CbTMp.Items.Add(Chr(X));
end;     

Function  GetCbHandShakeChar(IdX : Integer):Char;
var StrX  : string;
    ChRet : Char;
begin
  StrX  :=  FPortCOM.CbStart.Items[IdX];
       if StrX='CR'    then  ChRet :=  #13
  else if StrX='LF'    then  ChRet :=  #10
  else if StrX='SPACE' then  ChRet :=  ' '
  else                       ChRet :=  StrX[1];
  result := ChRet;
end;
                                                                            
//--------------------------------------------------------------------------------------------- Load Save Configuration 
Procedure ComSaveLoadConfig(IsSave : Boolean);
var MyIni : TiniFile;
    StrX  : String;
begin
  MyIni :=  TIniFile.Create(COM_AppDir + csConfigFile);
  if IsSave then
  begin                                                                          
    MyIni.WriteString ('COM Interface', 'Port',        FPortCOM.ComList.Items[FPortCOM.ComList.ItemIndex]);
    MyIni.WriteInteger('COM Interface', 'BaudRate',    FPortCOM.RgBaud.ItemIndex);
    MyIni.WriteInteger('COM Interface', 'DataBits',    FPortCOM.RgBits.ItemIndex);
    MyIni.WriteInteger('COM Interface', 'Parity',      FPortCOM.RgParity.ItemIndex);
    MyIni.WriteInteger('COM Interface', 'StopBits',    FPortCOM.RgStop.ItemIndex);
    MyIni.WriteInteger('COM Interface', 'FlowControl', FPortCOM.RgFlow.ItemIndex);
  end else
  begin                        
    FPortCOM.LazCom.Device :=  'No Port';
    ReScanPortCOM(FPortCOM.ComList);
    StrX                        :=  MyIni.ReadString ('COM Interface', 'Port', 'No Port');
    FPortCOM.RgBaud.ItemIndex   :=  MyIni.ReadInteger('COM Interface', 'BaudRate',    3);
    FPortCOM.RgBits.ItemIndex   :=  MyIni.ReadInteger('COM Interface', 'DataBits',    0);
    FPortCOM.RgParity.ItemIndex :=  MyIni.ReadInteger('COM Interface', 'Parity',      0);
    FPortCOM.RgStop.ItemIndex   :=  MyIni.ReadInteger('COM Interface', 'StopBits',    0);
    FPortCOM.RgFlow.ItemIndex   :=  MyIni.ReadInteger('COM Interface', 'FlowControl', 0);
    FPortCOM.ComList.ItemIndex  :=  FPortCOM.ComList.Items.IndexOf(StrX);
  end;
  MyIni.Free;
  FPortCOM.ComConfigEvent(FPortCOM.BtScan);
end;

//--------------------------------------------------------------------------------------------- Load Save SendLog
Procedure ComSaveLoadSendLog(IsSave : Boolean);
var MyIni : TiniFile;
    StrX  : String;
begin
  MyIni :=  TIniFile.Create(COM_AppDir + csConfigFile);
  {if IsSave then
  begin
    MyIni.WriteString('COM Interface', 'Port',         FPortCOM.ComList.Items[FPortCOM.ComList.ItemIndex]);
    MyIni.WriteInteger('COM Interface', 'BaudRate',    FPortCOM.RgBaud.ItemIndex);
    MyIni.WriteInteger('COM Interface', 'DataBits',    FPortCOM.RgBits.ItemIndex);
    MyIni.WriteInteger('COM Interface', 'Parity',      FPortCOM.RgParity.ItemIndex);
    MyIni.WriteInteger('COM Interface', 'StopBits',    FPortCOM.RgStop.ItemIndex);
    MyIni.WriteInteger('COM Interface', 'FlowControl', FPortCOM.RgFlow.ItemIndex);
  end else
  begin
    StrX                      :=  MyIni.ReadString ('COM Interface', 'Port', 'No Port');
    FPortCOM.RgBaud.ItemIndex :=  MyIni.ReadInteger('COM Interface', 'BaudRate',    3);
    FPortCOM.RgBaud.ItemIndex :=  MyIni.ReadInteger('COM Interface', 'DataBits',    0);
    FPortCOM.RgBaud.ItemIndex :=  MyIni.ReadInteger('COM Interface', 'Parity',      0);
    FPortCOM.RgBaud.ItemIndex :=  MyIni.ReadInteger('COM Interface', 'StopBits',    0);
    FPortCOM.RgBaud.ItemIndex :=  MyIni.ReadInteger('COM Interface', 'FlowControl', 0);
    FPortCOM.ComList.ItemIndex:=  FPortCOM.ComList.Items.IndexOf(StrX);
  end;     }
  MyIni.Free;
end;


//==================================================================================================================
//--------------------------------------------------------------------------------------------- Form event
procedure TFPortCOM.FormCreate(Sender: TObject);
begin
  SetWindowLong(Handle, GWL_EXSTYLE, GetWindowLong(Handle, GWL_EXSTYLE) or WS_EX_LAYERED);
  SetLayeredWindowAttributes(Handle,clAqua,255,LWA_COLORKEY);
  LsSend.Clear;
  Pagecontrol1.ShowTabs :=  FALSE; 
  ShBack00.Align        :=  AlCLient;
  ShBack01.Align        :=  AlCLient;
  ShBack02.Align        :=  AlCLient;
  MemRecv.Align         :=  AlClient;
  Pagecontrol1.Height   :=  445;
  LsSend.Width          :=  0;
  LsSend.Height         :=  0;     
  COM_AppDir            :=  GetCurrentDir+'\';
  PageControl1.ActivePageIndex  :=  0;
  if FileExists(COM_AppDir+'SendLog.txt') then
  begin
    LsSend.Items.LoadFromFile(COM_AppDir+'SendLog.txt');
    EdSend.Items.Clear;
    EdSend.Items := LsSend.Items;
  end;                              
  //-----------------------------------
  InitCbHandShakeChar(CbStart);
  InitCbHandShakeChar(CbEnd);
  CbStart.ItemIndex :=  CbStart.Items.IndexOf('[');
  CbEnd.ItemIndex   :=  CbEnd.Items.IndexOf(']');
  COM_Start         :=  '[';
  COM_End           :=  ']';
  //-----------------------------------
  GeneralButtonEvent(BtClear);
  //GeneralButtonEvent(BtScan);   tidak perlu -> sudah dipanggil di fungsi Load
  ComSaveLoadConfig(csLoad);      
  //-----------------------------------
  LabInfo.Caption :=  'COM Interface v1.0 [201907]'+#13#10+
                      'by : TooPayZ'+#13#10+
                      'Just Like another COM Interface application.'+#13#10+
                      'Made with Lazarus Free Pascal.'+#13#10+
                      'Please Enjoy it...^^...';
end;

//--------------------------------------------------------------------------------------------- Form Mouse Move
procedure TFPortCOM.ShBack00MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  COM_OldXX :=  mouse.CursorPos.x - Left;
  COM_OldYY :=  mouse.CursorPos.Y - Top;
end;

procedure TFPortCOM.ShBack00MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  if Shift=[ssLeft] then
  begin
    Left  :=  mouse.CursorPos.x - COM_OldXX;
    Top   :=  mouse.CursorPos.Y - COM_OldYY;
  end;
end;
        
//--------------------------------------------------------------------------------------------- All Button Event
procedure TFPortCOM.GeneralButtonEvent(Sender: TObject);
begin
  if sender=BtCLose     then  Application.Terminate;
  if sender=BtMinim     then  Application.Minimize;
  if sender=BtSettings  then  PageControl1.ActivePageIndex  :=  0;
  if sender=BtRecv      then  PageControl1.ActivePageIndex  :=  1;
  if sender=BtHelp      then  PageControl1.ActivePageIndex  :=  2;
  if sender=CbTimer     then  TimRun.Interval :=  strtoint(CbTimer.Text);
  if sender=TimLed      then  DotLed.Active   :=  NOT DotLed.Active;
  if sender=CbStart     then  COM_Start :=  GetCbHandShakeChar(CbStart.ItemIndex);
  if sender=CbEnd       then  COM_End   :=  GetCbHandShakeChar(CbEnd.ItemIndex);
  if sender=BtClear     then  begin   COM_LineNow := -1;    MemRecv.Clear;  end;
  //-------------------------------------------------------------
  if sender=BtScan then
  begin
    LazCom.Device :=  'No Port';
    ReScanPortCOM(ComList);
    ComConfigEvent(Sender);
  end;
  //-----------------------
  if sender=BtMiMax     then
  begin
    if Width> 720 then
    begin
      top     :=  ((Screen.Height - 571) div 2) - 20;
      Left    :=  ((Screen.Width  - 720) div 2);
      Width   :=  720;
      Height  :=  571;
    end else
    begin
      top     :=  0;
      Left    :=  0;
      Width   :=  Screen.Width;
      Height  :=  Screen.Height;
    end;
  end;
end;
                                                                                         
//==================================================================================================================
//--------------------------------------------------------------------------------------------- COM Configuration
procedure TFPortCOM.ComConfigEvent(Sender: TObject);
var StrX	: String;
    S,E		: Integer;
begin
  if ComList.ItemIndex<>-1 then
  begin
    StrX	:= 	ComList.Items[ComList.ItemIndex];
    S     :=	AnsiPos('COM',StrX);
    E	    :=	AnsiPos(')',StrX);
    if S<>0 then	LazCom.Device	:=  Copy(StrX,S,E-S);
  end else 	      LazCom.Device	:=  'No Port';
  //StBar.Panels[0].Text  :=  'Port : ' + LazCom.Device;
  //-----------------------------------------------------
  LazCom.BaudRate       :=  LazSerial.TBaudRate(RgBaud.ItemIndex + 3);
  LazCom.DataBits       :=  LazSerial.TDataBits(RgBits.ItemIndex);
  LazCom.Parity         :=  LazSerial.TParity(RgParity.ItemIndex);
  LazCom.StopBits       :=  LazSerial.TStopBits(RgStop.ItemIndex);
  LazCom.FlowControl    :=  LazSerial.TFlowControl(RgFlow.ItemIndex);
  //-----------------------------------------------------
  StrX  :=  '[' + inttostr(LazSerial.ConstsBaud[LazCom.BaudRate]) +',';
  StrX  :=  StrX + inttostr(LazSerial.ConstsBits[LazCom.DataBits]);
  StrX  :=  StrX + LazSerial.ConstsParity[LazCom.Parity];
  //-----------------------------------------------------
  case LazCom.StopBits of
    sbOne         : StrX  :=  StrX + '1,';
    sbOneAndHalf  : StrX  :=  StrX + '1.5,';
    sbTwo         : StrX  :=  StrX + '2,';
	else
		StrX := StrX + '1,';
  end;
  //-----------------------------------------------------
  case LazCom.FlowControl of
    fcNone    : StrX  :=  StrX + 'None]';
    fcXonXoff : StrX  :=  StrX + 'XonOff]';
    fcHardware: StrX  :=  StrX + 'Hardware]';
	else
		StrX := StrX + 'None]';
  end;
  //-----------------------------------------------------
  LabCOM.Caption        :=  LazCom.Device +' '+ StrX;
  //StBar.Panels[1].Text  :=  'Format : ' + StrX;
end;

//--------------------------------------------------------------------------------------------- Connect
procedure TFPortCOM.BtConnectClick(Sender: TObject);
  Procedure DefaultOff;
  begin
    LazCom.Close;
    BtConnect.Caption     :=  'Connect';
    BtScan.Enabled        :=  TRUE;
    DotLed.Active         :=  FALSE;
    TimLed.Enabled        :=  FALSE;
    TimRun.Enabled        :=  FALSE;
    ComList.Enabled       :=  TRUE;
    ComList.Color         :=  clDefault;
    //StBar.Panels[2].Text  :=  'Status : DisConnected';
  end;
begin
  if LazCom.Device='No Port' then
  begin
    DefaultOff;
    Showmessage('Pilih Port COM terlebih dahulu.'+#13#10+
                '"Scan Port" lalu pilih Port.');
    Exit;
  end;
  //-----------------------------------
  if (LazCom.Active) then   DefaultOff
  else begin
    ComSaveLoadConfig(csSave);
    LazCom.Open;
    LazCom.SetDTR(TRUE);
    BtConnect.Caption     :=  'DisConnect';
    BtScan.Enabled        :=  FALSE;
    ComList.Enabled       :=  FALSE;
    TimLed.Enabled        :=  TRUE;  
    TimRun.Enabled        :=  TRUE;
    ComList.Color         :=  clBtnFace;
    LazCom.ReadData;
    //StBar.Panels[2].Text  :=  'Status : Connected';
  end;
end;
                      
//--------------------------------------------------------------------------------------------- Data Recieve & Process
procedure TFPortCOM.LazComRxData(Sender: TObject);
begin
  if BtPause.Checked then
    begin LazCom.ReadData;  eXit; end;
  if LazCom.DataAvailable then
  begin
    MemRecv.Text  :=  MemRecv.Text + LazCom.ReadData;
    SendMessage(MemRecv.Handle, WM_VSCROLL, SB_BOTTOM, 0);
  end;
end;

procedure TFPortCOM.TimRUnTimer(Sender: TObject);
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

//--------------------------------------------------------------------------------------------- Send Data
procedure TFPortCOM.BtSendClick(Sender: TObject);
var StrX  : String;
begin                           
  StrX := EdSend.Text;
  if StrX=''        then  exit;
  if CekCR.Checked  then  StrX  :=  StrX+#13;
  if CekLF.Checked  then  StrX  :=  StrX+#10;
  LazCOM.WriteData(StrX);
  //-------------------------------------------------
  if LsSend.Items.IndexOf(EdSend.Text) = -1 then
  begin
    LsSend.Items.Add(EdSend.Text);
    LsSend.Items.SaveToFile(COM_AppDir+'SendLog.txt');
    EdSend.Items.Clear;
    EdSend.Items := LsSend.Items;
  end;
end;

procedure TFPortCOM.LedRTSClick(Sender: TObject);
begin
  if NOT LazCom.Active then exit;
  if sender=LedDTR  then
    begin LedDTR.Active := NOT LedDTR.Active;   LazCom.SetDTR(LedDTR.Active); end;
  if sender=LedRTS  then
    begin LedRTS.Active := NOT LedRTS.Active;   LAzCom.SetRTS(LedRTS.Active); end;
end;

//--------------------------------------------------------------------------------------------- Process Or Parsing data on Recieve
procedure TFPortCOM.ProcessData(StDt:String);
{var tmI   : integer;
    MyIni : TiniFile;
    StrX  : String;  }
begin
  {if (StDt[2]='A') then
  begin
    LDR00.Caption   :=  Copy(StDt, 4,  3);
    LDR01.Caption   :=  Copy(StDt, 8,  3);
    LDR02.Caption   :=  Copy(StDt, 12, 3);
    LDR03.Caption   :=  Copy(StDt, 16, 3);
  end;
  if (StDt[2]='B') then
  begin
    LDR04.Caption   :=  Copy(StDt, 4,  3);
    LDR05.Caption   :=  Copy(StDt, 8,  3);
    LDR06.Caption   :=  Copy(StDt, 12, 3);
    LDR07.Caption   :=  Copy(StDt, 16, 3);
  end;
  if (StDt[2]='C') then
  begin
    LDR08.Caption   :=  Copy(StDt, 4,  3);
    LDR09.Caption   :=  Copy(StDt, 8,  3);
    LDR10.Caption   :=  Copy(StDt, 12, 3);
    LDR11.Caption   :=  Copy(StDt, 16, 3);
  end;
  if (StDt[2]='D') then
  begin
    LDR12.Caption   :=  Copy(StDt, 4,  3);
    LDRRecv.Caption :=  Copy(StDt, 8,  3);
    tmI             :=  strtointdef(LDRRecv.Caption,0);
    if tmI>BarRecv.Max  then  tmI :=  BarRecv.Max;
    if tmI<0    then  tmI :=  0;
    Barrecv.Position:=  tmI;
  end;
  if (StDt[2]='P') then
  begin
    LabPos.Caption  :=  Copy(StDt, 4,  length(StDt)-4);
    StrX            :=  LabPos.Caption;
    //------------------------------
    MyIni	          :=  TIniFile.Create(Config_AppDir+'AppConfig.ini');
    LBaseAA.Caption :=	MyIni.ReadString(StrX,'Base A','000');
    LBaseBB.Caption :=	MyIni.ReadString(StrX,'Base B','000');
    LBaseCC.Caption :=	MyIni.ReadString(StrX,'Base C','000');
    LBaseDD.Caption :=	MyIni.ReadString(StrX,'Base D','000');
    LBaseEE.Caption :=	MyIni.ReadString(StrX,'Base E','000');
    LBaseFF.Caption :=	MyIni.ReadString(StrX,'Base F','000');

    LMirAA.Caption  :=	MyIni.ReadString(StrX,'Mirr A','000');
    LMirBB.Caption  :=	MyIni.ReadString(StrX,'Mirr B','000');
    LMirCC.Caption  :=	MyIni.ReadString(StrX,'Mirr C','000');
    LMirDD.Caption  :=	MyIni.ReadString(StrX,'Mirr D','000');
    LMirEE.Caption  :=	MyIni.ReadString(StrX,'Mirr E','000');
    LMirFF.Caption  :=	MyIni.ReadString(StrX,'Mirr F','000');
    MyIni.Free;
  end;      }
end;


end.




