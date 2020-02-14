unit FormDude;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ComCtrls, StdCtrls,
  ExtCtrls, ActnList, EditBtn, Windows, LazSerial, ECTabCtrl, ECEditBtns,
  BCLabel, IniFiles, BCMDButton, BGRAShape, BCListBox, BCButton, BCPanel,
  BCButtonFocus, BCMaterialDesignButton, FXMaterialButton, FXButton,
  PyzControlWinDevice, process, LCLType, uEButton;

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
    BcLabel11: TBCLabel;
    BcLabel12: TBCLabel;
    BcLabel13: TBCLabel;
    BcLabel14: TBCLabel;
    BcLabel15: TBCLabel;
    BcLabel16: TBCLabel;
    BcLabel18: TBCLabel;
    BtRom: TBCButton;
    BtSmall: TBCButton;
    BtNext: TBCButton;
    BtLog: TBCButton;
    CekPause: TCheckBox;
    CekROM: TCheckBox;
    ImTupZ1: TImage;
    ImTupZ2: TImage;
    ImTupZ3: TImage;
    ImTupZ4: TImage;
    ImTupZ5: TImage;
    LabDate: TBCLabel;
    BcLabel2: TBCLabel;
    BcLabel3: TBCLabel;
    BcLabel4: TBCLabel;
    BcLabel5: TBCLabel;
    BcLabel6: TBCLabel;
    BcLabel7: TBCLabel;
    LabApps: TBCLabel;
    BtConfig: TBCButton;
    BtDude: TBCButton;
    BtFlash: TBCButton;
    CbListSec: TListBox;
    CekLog: TCheckBox;
    LabBaud: TBCLabel;
    LabCom: TBCLabel;
    LabConfig: TBCLabel;
    BcLabel8: TBCLabel;
    LabEsc: TBCLabel;
    LabFlash: TBCLabel;
    LabFlashXx: TBCLabel;
    LabInfo: TBCLabel;
    LabInfo1: TBCLabel;
    LabInfo2: TBCLabel;
    LabInfo3: TBCLabel;
    LabInfo4: TBCLabel;
    LabRom: TBCLabel;
    LcPause: TBCLabel;
    LcRom: TBCLabel;
    MRelease: TMemo;
    Panel1: TPanel;
    ShBack03: TBCLabel;
    LabMikro: TBCLabel;
    LabBoard: TBCLabel;
    LabProg: TBCLabel;
    BtInfo: TBCButton;
    BtMinim: TBCButton;
    BtClose: TBCButton;
    CbListVal: TListBox;
    LcFlash: TBCLabel;
    LcLog: TBCLabel;
    OpenFile: TOpenDialog;
    ShBack00: TBGRAShape;
    PageControl1: TPageControl;
    ShBack04: TBCLabel;
    ShBack05: TBCLabel;
    ShBack06: TBCLabel;
    ShBack01: TBCLabel;
    TabDude: TTabSheet;
    TabInfo: TTabSheet;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    TabSheet3: TTabSheet;
    TabSheet4: TTabSheet;
    TimLog: TTimer;

    procedure BtDudeClick(Sender: TObject);
    procedure LabelIniClick(Sender: TObject);
    procedure OpenFileClick(Sender: TObject);
    procedure CbListValClick(Sender: TObject);
    procedure CbListValKeyPress(Sender: TObject; var Key: char);
    procedure CekFlashClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure GeneralButtonEvent(Sender: TObject);
    procedure ShBack00MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure ShBack00MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure TimLogTimer(Sender: TObject);
  private      
    DUDE_OldXX, DUDE_OldYY  : integer;    
    DUDE_OldDate  : LongInt;
    DUDE_FlashOld : string;   //
  public

  end;

var
  FDude: TFDude;
  AVR_AppDir    : String='';
  AVR_DudeDir   : String='';
  DUDE_IsRun    : Boolean = FALSE;

implementation

{$R *.lfm}

Uses FormLog, FormSmall;

const
  csConfigFile  = 'AVRdude.ini';
  csLogFile     = 'LogFile.txt'; 
  csAppInfo     = 'AVRDude GUI v1.1 [201908]';
  csInfo        = 'by : TooPayZ'+#13#10+
                  'From maker to maker...^^...'+#13#10+#13#10+
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
begin
  ComList.Clear;
  SList		          :=	Loaddevices(GUID_DEVCLASS_PORT);
  ComList.Items	    := 	SList;
  ComList.ItemIndex :=  -1; 
  SList.Free;
end;
                       
//--------------------------------------------------------------------------------------------- PArsing Board to Config
Procedure ParsingBoardString(StData  : String);
var StrX  : String;
begin
  FDude.CbListSec.Items.Clear;    //  manfaatkan ini
  StrX  :=  StringReplace(StData,';',#13#10,[rfReplaceAll, rfIgnoreCase]);
  FDude.CbListSec.Items.Text  :=  StrX;
  //------------------------------------------  Board Name (M128 Learning Board)
  if FDude.CbListSec.Items.Count>=5  then
  begin                                                                      
    FDude.LabBoard.Caption  :=  FDude.CbListSec.Items[0]; //  Board Microcontroller
    FDude.LabMikro.Caption  :=  FDude.CbListSec.Items[1]; //  Microcontroller (m128)
    FDude.LabProg.Caption   :=  FDude.CbListSec.Items[2]; //  Protocol (stk500)
    FDude.LabBaud.Caption   :=  FDude.CbListSec.Items[3]; //  BaudRate (115200)
    FDude.LabConfig.Caption :=  FDude.CbListSec.Items[4]; //  Config File (avrdude.conf)
    //-----------------------------------------------------   
    FDude.LabBoard.FontEx.Color   :=  clAqua;
    FDude.LabMikro.FontEx.Color   :=  clAqua;
    FDude.LabProg.FontEx.Color    :=  clAqua;
    FDude.LabBaud.FontEx.Color    :=  clAqua;
    FDude.LabConfig.FontEx.Color  :=  clAqua;
  end;
end;

//--------------------------------------------------------------------------------------------- Load Save Configuration
Procedure ComSaveListFile(StSec : String; TmpLab :TBCLabel);
var MyIni   : TiniFile;
    CntX, X : integer;
begin
  CntX  :=  FDude.CbListSec.Items.Count;
  MyIni :=  TIniFile.Create(AVR_AppDir + csConfigFile);
  MyIni.WriteString(StSec, 'Now', TmpLab.Hint);   // Long name in Hint
  if CntX<>0  then
    for x:=0 to CntX-1 do
      MyIni.WriteString(StSec, inttostr(X+1), FDude.CbListSec.Items[x]);
  MyIni.Free;
end;

Procedure ComLoadListFile(StSec : String; TmpLab :TBCLabel);
var MyIni   : TiniFile;
    StFile  : String;
begin
  FDude.CbListVal.Items.Clear;
  MyIni   :=  TIniFile.Create(AVR_AppDir + csConfigFile);
  StFile  :=  MyIni.ReadString (StSec, 'Now', 'No File Selected');
  TmpLab.Hint     :=  StFile;
  if StFile<>'' then  TmpLab.Caption  :=  ExtractFileName(StFile)
                else  TmpLab.Caption  :=  'Click Here.';
  if fileexists(StFile) then  TmpLab.FontEx.Color :=  clAqua
                        else  TmpLab.FontEx.Color :=  clYellow;
  MyIni.Free;
end;

//==================================================================================================================
//--------------------------------------------------------------------------------------------- Form event
procedure TFDude.FormCreate(Sender: TObject);
begin
  SetWindowLong(Handle, GWL_EXSTYLE, GetWindowLong(Handle, GWL_EXSTYLE) or WS_EX_LAYERED);
  SetLayeredWindowAttributes(Handle, $000D0D0D,255,LWA_COLORKEY);
  Pagecontrol1.ShowTabs :=  FALSE; 
  ShBack00.Align        :=  AlCLient;
  AVR_AppDir            :=  GetCurrentDir+'\';
  AVR_DudeDir           :=  GetCurrentDir+'\avrdude\';
  LabApps.Caption       :=  csAppInfo;
  LabInfo.Caption   	  :=  csAppInfo+#13#10+csInfo;
  CbListVal.Width       :=  380;
  CbListVal.height      :=  250;
  Height                :=  360;
  PageControl1.ActivePage :=  TabInfo;
  CekFlashClick(CekLog);
  //---------------------------------------
  DUDE_IsRun            :=  FALSE;
  DUDE_OldDate          :=  FileAge(AVR_DudeDir+csLogFile);
  DUDE_FlashOld         :=  '';
  BtConfig.Hint         :=  AVR_DudeDir;
  ComLoadListFile('AVRDude Config', LabConfig);     //  Load NOW for Config
  ComLoadListFile('AVRDude Flash',  LabFlash);      //  Load NOW for Flash
  ComLoadListFile('AVRDude EEPROM', LabRom);        //  Load NOW for EEPROM
  ComLoadListFile('AVRDude Board',  LabBoard);      //  Load NOW for Board
  ParsingBoardString(LabBoard.Caption);             //  Parsing board yg NOW
  //---------------------------------------
  top   :=  (Screen.Height - Height) div 2;
  Left  :=  (Screen.Width - width) div 2;
  if Fileexists(AVR_AppDir+'Release Note AVRDude GUI.txt') then
    MRelease.Lines.LoadFromFile(AVR_AppDir+'Release Note AVRDude GUI.txt');
end;

//--------------------------------------------------------------------------------------------- Form Mouse Move
procedure TFDude.ShBack00MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  DUDE_OldXX :=  mouse.CursorPos.x - Left;
  DUDE_OldYY :=  mouse.CursorPos.Y - Top;
end;

procedure TFDude.ShBack00MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  if Shift=[ssLeft] then
  begin
    Left  :=  mouse.CursorPos.x - DUDE_OldXX;
    Top   :=  mouse.CursorPos.Y - DUDE_OldYY;
  end;
end;

//--------------------------------------------------------------------------------------------- All Button Event
procedure TFDude.GeneralButtonEvent(Sender: TObject);
var IdX : integer;
begin
  if sender=BtCLose     then  Application.Terminate;
  if sender=BtMinim     then  Application.Minimize;
  if sender=BtLog       then  Flog.ShowModal;
  if sender=CbListVal   then  CbListVal.Visible       :=  FALSE;  //  On Exit
  if sender=ShBack01    then  CbListVal.Visible       :=  FALSE;
  if sender=LabInfo     then  PageControl1.ActivePage :=  TabDude;
  if sender=BtSmall     then  begin hide; FSmall.show; end;
  if sender=BtInfo      then
    if  PageControl1.ActivePage<>TabDude  then PageControl1.ActivePage :=  TabDude
    else begin  BtNext.Parent := TabInfo;  PageControl1.ActivePage :=  TabInfo;  end;
  if sender=BtNext      then
  begin
    IdX :=  0;
    case  PageControl1.ActivePageIndex of
      1:  IdX:=2;
      2:  IdX:=3;
      3:  IdX:=4;
      4:  IdX:=5;
      5:  IdX:=0;
    end;
    PageControl1.ActivePageIndex  :=  IdX;
    if IdX>0 then BtNext.Parent   := PageControl1.Pages[IdX];
    BtNext.Left :=  PageControl1.Width - 38;
  end;
end;

//==================================================================================================================
//--------------------------------------------------------------------------------------------- Cek On Click
procedure TFDude.CekFlashClick(Sender: TObject);
begin
  CbListVal.Visible :=  FALSE;
  if sender is TBCLAbel then
  begin
    //if sender=LcFlash  then CekFlash.Checked := NOT CekFlash.Checked;
    if sender=LcRom    then CekRom.Checked   := NOT CekRom.Checked;
    if sender=LcLog    then CekLog.Checked   := NOT CekLog.Checked;
    if sender=LcPause  then CekPause.Checked := NOT CekPause.Checked;
  end;                
  //----------------------------------------
  //LabFlash.Visible  :=  CekFlash.Checked;
  LabRom.Visible    :=  CekRom.Checked;
  //----------------------------------------
  //BtFlash.Enabled   :=  CekFlash.Checked;
  BtRom.Enabled     :=  CekRom.Checked;
end;
                                                                                                         
//==================================================================================================================
//--------------------------------------------------------------------------------------------- Label OnClick Load Ini
procedure Delete00_Parsing;
var x, Y    : integer;
    StVal, StBrd : String;
begin
  FDude.CbListSec.Items :=  FDude.CbListVal.Items;  //  Swap Data
  FDude.CbListVal.Items.Clear;                      //  Board Name Only
  if FDude.CbListSec.Items.Count > 1 then
  begin
    FDude.CbListSec.Items.Delete(0);
    for x:=0 to FDude.CbListSec.Items.Count-1 do
    begin
      StVal :=  FDude.CbListSec.Items[x];
      Y     :=	AnsiPos(';',StVal);
      StBrd :=  Copy(StVal,1,Y-1);
      FDude.CbListVal.Items.Add(StBrd);
    end;
  end;
end;

procedure Delete00_ShortFile;
var x:integer;
begin
  FDude.CbListSec.Items.Clear;      //  Long File Name will here
  if FDude.CbListVal.Items.Count>1 then
  begin
    FDude.CbListVal.Items.Delete(0);
    for x:=0 to FDude.CbListVal.Items.Count-1 do
    begin
      FDude.CbListSec.Items.Add(FDude.CbListVal.Items[x]);
      FDude.CbListVal.Items[x]  :=  ExtractFileName(FDude.CbListVal.Items[x]);
    end;
  end;
end;

Procedure LoadIniConfig(StrHint, StrSec:string);
var MyIni : TiniFile;
    StrX  : String;
    X  		: Integer;
begin
  FDude.CbListVal.Hint  :=  StrHint;
  MyIni                 :=  TIniFile.Create(AVR_AppDir + csConfigFile);
  MyIni.ReadSection(StrSec, FDude.CbListSec.Items);
  if FDude.CbListSec.Items.Count<>0 then
    for x:=0 to FDude.CbListSec.Items.Count-1 do
    begin
      StrX  := FDude.CbListSec.Items[x];
      FDude.CbListVal.Items.Add(MyIni.ReadString(StrSec,StrX,'---'));
    end;
  MyIni.Free;
end;

procedure TFDude.LabelIniClick(Sender: TObject);
begin
  CbListSec.Items.Clear;
  CbListVal.Items.Clear;
  CbListVal.Hint :=  '';    //  menyimpan label yang akan di ganti captionnya
  if (sender=LabBaud)   then  LoadIniConfig('LabBaud',   'AVRDude Baudrate');
  if (sender=LabMikro)  then  LoadIniConfig('LabMikro',  'AVRDude Mikrokontroller');
  if (sender=LabProg)   then  LoadIniConfig('LabProg',   'AVRDude Programmer');                             
  if (sender=LabBoard)  then  begin LoadIniConfig('LabBoard',  'AVRDude Board');   Delete00_Parsing;    end;
  if (sender=LabConfig) then  begin LoadIniConfig('LabConfig', 'AVRDude Config');  Delete00_ShortFile;  end;
  if (sender=LabRom)    then  begin LoadIniConfig('LabRom',    'AVRDude EEPROM');  Delete00_ShortFile;  end;   
  if (sender=LabFlash)  then  begin LoadIniConfig('LabFlash',  'AVRDude Flash');   Delete00_ShortFile;  end;
  if (sender=LabCom)    then
  begin                           
    ReScanPortCOM(CbListSec);
    CbListVal.Hint := 'LabCom';
    CbListVal.Items.Add('USB');
    CbListVal.Items.AddText(CbListSec.Items.Text);
  end;
  //------------------------------------------         
  CbListVal.Top       :=  LabBoard.Top + 3; // TBCLabel(Sender).Top;
  CbListVal.Left      :=  LabBoard.Left; //200  or  154;
  CbListVal.Width     :=  width - CbListVal.Left - 20;  
  CbListVal.Height    :=  LabEsc.Top - CbListVal.Top - 10;
  CbListVal.Visible   :=  TRUE;
  CbListVal.SetFocus;
end;

//--------------------------------------------------------------------------------------------- List on Click Change Label
procedure TFDude.CbListValClick(Sender: TObject);
var   TmObjp      : TBCLabel;
      StrX, StSec : String;
      S,E		      : Integer;
      MyIni       : TIniFile;
begin
  if CbListVal.ItemIndex=-1 then exit;
  //----------------------------------------------- Find Component
  TmObjp  :=  nil;
  StrX    :=  CbListVal.Hint;
  if length(StrX)>4 then  TmObjp  :=  (FindComponent(StrX) As TBCLabel);   
  if TmObjp=nil   then Exit;
  TmObjp.FontEx.Color :=  clAqua;
  //----------------------------------------------- Port COM
  if TmObjp = LabCom then
  begin
    StrX	:= 	CbListVal.Items[CbListVal.ItemIndex];
    if length(StrX)>2 then
    begin
      S     :=	AnsiPos('COM',StrX);
      E	    :=	AnsiPos(')',StrX);
      if S<>0 then	TmObjp.Caption  :=  Copy(StrX,S,E-S)
              else  TmObjp.Caption	:=  StrX;
      TmObjp.Hint :=  StrX;
    end;
  end
  //----------------------------------------------- Config, Flash, ROM
  else if (TmObjp = LabConfig) OR (TmObjp = LabFlash) OR (TmObjp = LabRom) then
  begin
    StSec :=  '';
    if  StrX='LabConfig'  then  StSec :=  'AVRDude Config';
    if  StrX='LabFlash'   then  StSec :=  'AVRDude Flash';
    if  StrX='LabRom'     then  StSec :=  'AVRDude EEPROM';   
    TmObjp.Hint     :=  CbListSec.Items[CbListVal.ItemIndex];
    TmObjp.Caption  :=  ExtractFileName(TmObjp.Hint);
    MyIni :=  TIniFile.Create(AVR_AppDir + csConfigFile);
    MyIni.WriteString(StSec, 'Now', TmObjp.Hint);
    MyIni.Free;              
    if  StrX='LabFlash'   then  FSmall.LabFlash.Caption :=  LabFlash.Caption;
  end                                
  //----------------------------------------------- Board MCU
  else if TmObjp = LabBoard then
  begin
    TmObjp.Caption  :=  CbListVal.Items[CbListVal.ItemIndex];
    TmObjp.Hint     :=  CbListSec.Items[CbListVal.ItemIndex];
    ParsingBoardString(TmObjp.Hint); 
    MyIni :=  TIniFile.Create(AVR_AppDir + csConfigFile);
    MyIni.WriteString('AVRDude Board', 'Now', TmObjp.Hint);
    MyIni.Free;
  end
  //-----------------------------------------------
  else if TmObjp = LabBaud  then
  begin
    TmObjp.Caption  :=  CbListVal.Items[CbListVal.ItemIndex];
    TmObjp.Hint     :=  TmObjp.Caption;
  end
  else begin    //  Micro & Programmer
    TmObjp.Caption  :=  CbListSec.Items[CbListVal.ItemIndex];
    TmObjp.Hint     :=  CbListVal.Items[CbListVal.ItemIndex];
  end;
  //-----------------------------------------------
  CbListVal.Visible   :=  FALSE;
  CbListVal.Hint      :=  '';
end;

procedure TFDude.CbListValKeyPress(Sender: TObject; var Key: char);
begin
  if key=char(VK_ESCAPE) then CbListVal.Visible  :=  FALSE;
end;

//--------------------------------------------------------------------------------------------- Open File Save Ini
procedure TFDude.OpenFileClick(Sender: TObject);
var TmLab : TBCLAbel;
    StSec : String;
begin                                                                                                         
  TmLab               :=  Nil;
  StSec               :=  '';
  OpenFile.InitialDir :=  TBCButton(Sender).Hint;                                 //  Initial Dir ->  Active on load ini
  OpenFile.Filter     :=  TBCButton(Sender).Caption;                              //  filter disimpan disini (always Acive)
  if sender=BtConfig  then  begin TmLab := LabConfig;   StSec := 'AVRDude Config';  LabelIniClick(LabConfig); end;
  if sender=BtRom     then  begin TmLab := LabRom;      StSec := 'AVRDude EEPROM';  LabelIniClick(LabRom);    end;
  if sender=BtFlash   then  begin TmLab := LabFlash;    StSec := 'AVRDude Flash';   LabelIniClick(LabFlash);  end; 
  if sender=Fsmall.LabFlash then  begin TmLab := LabFlash;    StSec := 'AVRDude Flash'; end;
  if TmLab=Nil then exit;
  CbListVal.Visible   :=  FALSE;
  Application.ProcessMessages;
  //----------------------------------------------------------------
  if OpenFile.Execute then
  begin
    TmLab.Hint    :=  OpenFile.FileName;                                          //  File Location Long Name
    TmLab.Caption :=  ExtractFileName(OpenFile.FileName);                         //  File Location Short Name
    if CbListSec.Items.IndexOf(TmLab.Hint)=-1     then  CbListSec.Items.Add(TmLab.Hint);
    if TBCButton(Sender).Hint<>OpenFile.FileName  then
    begin
      ComSaveListFile(StSec, TmLab);
      TBCButton(Sender).Hint  :=  OpenFile.FileName;                              //  File Location save or Not
    end;
  end;                     
  //----------------------------------------------------------------
  if sender=Fsmall.LabFlash then  Fsmall.LabFlash.Caption := LabFlash.Caption;
end;

//==================================================================================================================
//--------------------------------------------------------------------------------------------- AVRDude Run Command  
procedure TFDude.BtDudeClick(Sender: TObject);
var StDude    : String;
    Aprocess  : TProcess;
begin        
  Flog.MLog.Clear;
  StDude  :=  AVR_DudeDir+'avrdude.exe';
  if NOT FileExists(StDude) then
  begin Showmessage('Aplikasi AVRDude.exe tidak ditemukan.'+#13#10+
        'Lokasi File "'+StDude+'".');
        exit;
  end;
  //--------------------------------------------------------
  if NOT FileExists(LabFlash.Hint) then
  begin Showmessage('File yang akan di upload tidak ditemukan.'+#13#10+
        'Lokasi File "'+LabFlash.Hint+'".');
        Exit;
  end;
  //--------------------------------------------------------
  TimLog.Tag            :=  0;             
  DUDE_FlashOld         :=  LabDate.Caption;
  DUDE_IsRun            :=  TRUE;
  BtDude.Enabled        :=  FALSE;
  Fsmall.BtDude.Enabled :=  FALSE;
  //--------------------------------------------------------
  {if CekRom.Checked  then
    if NOT FileExists(LabRom.Hint) then
      begin Showmessage('File yang akan di upload tidak ditemukan.'+#13#10+
            'Lokasi File "'+LabRom.Hint+'".');
            Exit;  
  //if CekRom.Checked   then  Aprocessx.Parameters.Add('-Ueeprom:w:"'+LabRom.Hint  +'":i');
      end;    }
  //--------------------------------------------------------
  //avrdude-6.3\avrdude -C M128_Payz.conf -v -patmega128 -carduino -PCOM4 -b115200 -D
  //-Uflash:w:"E:\Lazarus\Lazarus My Lib\Description App\Board Description\ATmega128 v1.0 Trainer\Test ALCD.hex":i
  //HexFile :=  '-CM128_Payz.conf -v -patmega128 -carduino -P'+FView.LabCOM.Hint+' -b115200 -D -Uflash:w:"'+StFile+'":i';
  if CekLog.Checked then
  begin
    AProcess  :=  TPRocess.Create(nil);
    AProcess.CurrentDirectory :=  AVR_DudeDir;
    AProcess.Executable       :=  'cmd';     
    AProcess.Options          :=  AProcess.Options+[poUsePipes,poNoConsole];  //poUsePipes
  //AProcess.ShowWindow       :=  swoHIDE;
    AProcess.Parameters.Add('/c');
    AProcess.Parameters.Add('Avrdude.exe');
    AProcess.Parameters.Add('-C'+LabConfig.Caption);    //('-CM128_Payz.conf');
    AProcess.Parameters.Add('-v');
    AProcess.Parameters.Add('-p'+LabMikro.Caption);     //('-patmega128');
    AProcess.Parameters.Add('-c'+LabProg.Caption);      //('-carduino');
    AProcess.Parameters.Add('-P'+LabCom.Caption);
    AProcess.Parameters.Add('-b'+LabBaud.Caption);      //('-b115200');
    AProcess.Parameters.Add('-D');
    AProcess.Parameters.Add('-Uflash:w:"' +LabFlash.Hint+'":i');
    AProcess.Parameters.Add('-l"'+csLogFile+'"');
    AProcess.Execute;
    AProcess.Free;
  end else
  begin 
    //TimLog.Tag  :=  0;
    CbListVal.Clear;                 
    CbListVal.Items.Add('@ECHO OFF');
    CbListVal.Items.Add('"'+AVR_DudeDir+'avrdude.exe" '+
                   '-C'+LabConfig.Caption +' -v '+
                   '-p'+LabMikro.Caption  +' '+
                   '-c'+LabProg.Caption   +' '+
                   '-P'+LabCom.Caption    +' '+
                   '-b'+LabBaud.Caption   +' '+
                   '-D '+
                   '-Uflash:w:"' +LabFlash.Hint+'":i');
    if CekPause.Checked then  CbListVal.Items.Add('PAUSE');
    CbListVal.Items.SaveToFile(AVR_DudeDir+'RunDude.bat');
    SetCurrentDir(AVR_DudeDir);
  end;
end;

procedure TFDude.TimLogTimer(Sender: TObject);
Var S         : TDateTime;
    fa, faNew : Longint;
    IsOK      : Boolean;
begin                
  //----------------------------------  Check Flash File Update to Program
  if DUDE_FlashOld=LabDate.Caption then  ShBack00.BorderStyle := psClear;
  if fileexists(LabFlash.Hint)     then
  begin                       
    ShBack00.BorderStyle  :=  psSolid;
    fa:=FileAge(LabFlash.Hint);
    If fa<>-1 then
    begin
      S :=  FileDateTodateTime(fa);
      LabDate.Caption  :=  DateTimeToStr(S);
    end;
  end;
  //----------------------------------  On Click / RUN AVR Dude
  if (TimLog.Tag>4) AND NOT (BtDude.Enabled) then
  begin
    BtDude.Enabled        :=  TRUE;
    Fsmall.BtDude.Enabled :=  TRUE;
  end;
  //----------------------------------  Trying open New Log File
  if DUDE_IsRun then
  begin
    if CekLog.Checked then
    begin
      IsOK  := FALSE;
      faNew :=  FileAge(AVR_DudeDir+csLogFile);
      if (faNew<>-1) AND (faNew<>DUDE_OldDate)  then
      try
        FLog.MLog.Lines.LoadFromFile(AVR_DudeDir+csLogFile);
        IsOK  := TRUE;
      except
        IsOK  := FALSE;
      end;
      if IsOK then FLog.ShowModal;
    end else
    //----------------------------------
    begin
      TimLog.Tag  :=  TimLog.Tag+1;
      if  TimLog.Tag=4  then  ShellExecute(0,nil, PChar('cmd'), PChar('/c RunDude.bat'),nil,1);
      if  TimLog.Tag>=6 then  DUDE_IsRun  := FALSE;
    end;
  end;
end;

end.




