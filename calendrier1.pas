unit calendrier1;

{$mode objfpc}{$H+}

interface

uses
  {$IFDEF WINDOWS}
    Win32Proc,
  {$ENDIF}
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, ComCtrls,
  Grids, StdCtrls, lazbbcontrols, csvdocument, Types, DateUtils, lazbbastro,
  LResources, Buttons, Menus, ExtDlgs, registry, lazbbutils, lazbbautostart,
  LazUTF8, lazbbosver, laz2_DOM, laz2_XMLRead, laz2_XMLWrite, calsettings;


type

  TDay = record
    index: integer;
    ddate: TDateTime;
    sday: string;
    sSaint: string;
    sFerie: String;
    sDesc: string;
    sHoliday: string;       //A, B, C, K
    sMoon: String;
    sMoonDesc: String;
    dMoon: TDateTime;
    bSunday: boolean;
    bFerie: boolean;
    bHoliday: boolean;
    bSeason: boolean;
    dSeason: TDateTime;
    sSeasonDesc: String;
    bMoon: boolean;
    iDay: integer;
    iMonth: integer;
    iQuarter: integer;
  end;


  { TFCalendrier }

  TFCalendrier = class(TForm)
    CBVA: TCheckBoxX;
    CBVB: TCheckBoxX;
    CBVC: TCheckBoxX;
    CBVK: TCheckBoxX;
    CBLune: TCheckBoxX;
    ETodayTime1: TEdit;
    ETodayTime2: TEdit;
    EYear: TEdit;
    Image1: TImage;
    Image2: TImage;
    Image3: TImage;
    ImgLMoon: TImageList;
    MemoSeasons11: TMemo;
    MemoCurDay2: TMemo;
    MemoSeasons12: TMemo;
    MemoSeasons21: TMemo;
    MemoSeasons22: TMemo;
    MemoToday1: TMemo;
    MemoToday2: TMemo;
    MemoCurDay1: TMemo;
    PMnuDelImg: TMenuItem;
    OPDHalf: TOpenPictureDialog;
    PMnuAddImg: TMenuItem;
    PMnuRestore: TMenuItem;
    PMnuQuit: TMenuItem;
    PMnuSettings: TMenuItem;
    PageControl1: TPageControl;
    PanInfos2: TPanel;
    PanImg1: TPanel;
    PanImg2: TPanel;
    PanInfos1: TPanel;
    PanSeasons2: TTitlePanel;
    PanSelDay2: TTitlePanel;
    PanStatus: TPanel;
    PanSelDay1: TTitlePanel;
    PanToday2: TTitlePanel;
    PMnuMain: TPopupMenu;
    PMnuTray: TPopupMenu;
    ScrollBox1: TScrollBox;
    ScrollBox2: TScrollBox;
    SG1: TStringGrid;
    SG2: TStringGrid;
    SG3: TStringGrid;
    SG4: TStringGrid;
    SBNextQ: TSpeedButton;
    SBPrevQ: TSpeedButton;
    Timer1: TTimer;
    PanToday1: TTitlePanel;
    PanSeasons1: TTitlePanel;
    TrayCal: TTrayIcon;
    TS2: TTabSheet;
    TS1: TTabSheet;

    procedure CBXClick(Sender: TObject);
    procedure ETodayTimeChange(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure MemoCurDayChange(Sender: TObject);
    procedure MemoSeasons1Change(Sender: TObject);
    procedure MemoSeasons2Change(Sender: TObject);
    procedure MemoTodayChange(Sender: TObject);
    procedure PMnuAddImgClick(Sender: TObject);
    procedure PMnuDelImgClick(Sender: TObject);
    procedure PMnuMainPopup(Sender: TObject);
    procedure PMnuQuitClick(Sender: TObject);
    procedure PMnuRestoreClick(Sender: TObject);
    procedure PMnuSettingsClick(Sender: TObject);
    procedure SBNextQClick(Sender: TObject);
    procedure SBPrevQClick(Sender: TObject);
    procedure SGMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure SGSelectCell(Sender: TObject; aCol, aRow: Integer;
      var CanSelect: Boolean);
    procedure SGDrawCell(Sender: TObject; aCol, aRow: integer;
      aRect: TRect; aState: TGridDrawState);
    procedure Timer1Timer(Sender: TObject);
  private
    Iconized: Boolean;
    Initialized: Boolean;
    OS: String;
    OSTarget: String;
    OSVersion: TOSVersion;
    ProgName: String;
    CompileDateTime: TDateTime;
    CalExecPath: String;
    CalAppDataPath: String;
    CalImagePath: String;
    cfgfilename: String;
    LangStr: String;
    UserAppsDataPath: String;
    version: String;
    WState: String;
    WinState: TWindowState;
    PrevLeft, PrevTop: Integer;
    MoonDescs: array [0..3] of string;
    csvsaints, csvferies,csvvacs: TCSVDocument;
    FeriesTxt: String;
    aSG: array[0..3] of TStringGrid;
    ColorDay, ColorSunday, ColorFerie: TColor;

    Days: array of TDay;
    aMonths: array [1..13] of integer;

    Today: Integer;
    curyear: integer;
    curRow, curCol : Integer;
    curHint: String;
    TimeSepar: String;
    Settings: TSettings;
    HalfImgsList: TFichierList;
    SettingsChanged: Boolean;
    procedure OnAppMinimize(Sender: TObject);
    procedure OnQueryendSession(var Cancel: Boolean);
    procedure UpdateCal(Annee: word);
    function DayInfos(dDate: TDateTime): String;
    function LoadSettings(Filename: string): Boolean;
    function SaveSettings(filename: string): Boolean;
    function HideOnTaskbar: boolean;
    procedure SettingsOnChange(sender: TObject);
    procedure loadimage;
  public
    csvtowns: TCSVDocument;
  end;

var
  FCalendrier: TFCalendrier;


implementation

{$R *.lfm}


{ TFCalendrier }

// Intercept minimize system system command to correct
// wrong window placement on restore from tray

procedure TFCalendrier.OnAppMinimize(Sender: TObject);
begin
  if Settings.HideInTaskbar and Settings.miniintray then
  begin
    PrevLeft:=self.left;
    PrevTop:= self.top;
    WindowState:= wsMinimized;
    Iconized:= HideOnTaskbar;
  end;
end;

procedure TFCalendrier.OnQueryendSession(var Cancel: Boolean);
var
  {$IFDEF WINDOWS}
    reg: TRegistry;
    RunRegKeyVal, RunRegKeySz: string;
  {$ENDIF}
begin
  if not Settings.startwin then
  begin
    //Settings.Restart:= true;
    {$IFDEF WINDOWS}
      reg := TRegistry.Create;
      reg.RootKey := HKEY_CURRENT_USER;
      reg.OpenKey('Software\Microsoft\Windows\CurrentVersion\RunOnce', True) ;
      RunRegKeyVal:= UTF8ToAnsi(ProgName);
      RunRegKeySz:= UTF8ToAnsi('"'+Application.ExeName+'"');
      reg.WriteString(RunRegKeyVal, RunRegKeySz) ;
      reg.CloseKey;
      reg.free;
    {$ENDIF}
    {$IFDEF Linux}
       SetAutostart(ProgName, Application.exename);
    {$ENDIF}
  end;
  //BeforeClose;
  Application.ProcessMessages;
end;

procedure TFCalendrier.FormCreate(Sender: TObject);
var
  r: TLResource;
  s: String;
  {$IFDEF Linux}
     x: Integer;
  {$ENDIF}
begin
  {$I fr_saints.lrs}
  {$I fr_feries.lrs}
  {$I fr_holidays.lrs}
  {$I fr_villes.lrs}
  // Intercept system commands
  Application.OnMinimize:=@OnAppMinimize;
  Application.OnQueryEndSession:= @OnQueryendSession;

  Initialized := False;
   CompileDateTime:= StringToTimeDate({$I %DATE%}+' '+{$I %TIME%}, 'yyyy/mm/dd hh:nn:ss');
 Iconized:= false;
  OS := 'Unk';
  ProgName := 'Calendrier';
  CalExecPath:=ExtractFilePath(Application.ExeName);
 {$IFDEF CPU32}
     OSTarget := '32 bits';
  {$ENDIF}
  {$IFDEF CPU64}
     OSTarget := '64 bits';
  {$ENDIF}
   {$IFDEF Linux}
    OS := 'Linux';
    LangStr := GetEnvironmentVariable('LANG');
    x := pos('.', LangStr);
    LangStr := Copy(LangStr, 0, 2);
    wxbitsrun := 0;
    UserAppsDataPath := GetUserDir;
  {$ENDIF}
  OSVersion:= TOSVersion.Create();
  {$IFDEF WINDOWS}
    OS := 'Windows ';
    // get user data folder
    s := ExtractFilePath(ExcludeTrailingPathDelimiter(GetAppConfigDir(False)));
    if OSVersion.VerMaj < 7 then UserAppsDataPath := s                     // NT to XP
    else UserAppsDataPath := ExtractFilePath(ExcludeTrailingPathDelimiter(s)) + 'Roaming'; // Vista to W10
    LazGetShortLanguageID(LangStr);
  {$ENDIF}
  version := GetVersionInfo.ProductVersion;
  CalAppDataPath:= UserAppsDataPath + PathDelim + ProgName + PathDelim;
  if not DirectoryExists(CalAppDataPath) then CreateDir(CalAppDataPath);
  CalImagePath:= CalAppDataPath+'images'+PathDelim;
  if not DirectoryExists(CalImagePath) then CreateDir(CalImagePath);
  cfgfilename:= CalAppDataPath+ProgName+'.xml';
  // place properly grids and panels
 SG1.Left := 0;
  PanImg1.left := SG1.Width;
  PanInfos1.left:= SG1.Width;
  PanInfos1.top:= PanImg1.Height+4;
  SG2.Left := SG1.Width + PanImg1.Width + 1;
  SG3.Left := 0;
  PanImg2.left := SG3.Width;
  PanInfos2.left:= SG2.Width;
  PanInfos2.top:= PanImg2.Height+4;
  SG4.Left := SG3.Width + PanImg2.Width + 1;
  // populate array of quarters
  aSG[0] := SG1;
  aSG[1] := SG2;
  aSG[2] := SG3;
  aSG[3] := SG4;
  ColorDay := clDefault;
  ColorSunday := RGBToColor(128, 255, 255);
  ColorFerie:= RGBToColor(128, 255, 255);
  // load saints list from resource
  csvsaints := TCSVDocument.Create;
  r:= LazarusResources.Find('fr_saints');
  csvsaints.CSVText:= r.value;
   //load feries from resource
  csvferies := TCSVDocument.Create;
  r:= LazarusResources.Find('fr_feries');
  FeriesTxt:= r.value;
  csvferies.CSVText:= FeriesTxt;
  // load Holidays from resource
  csvvacs:= TCSVDocument.Create;
  if FileExists(CalAppDataPath+'fr_holidays.csv')then csvvacs.LoadFromFile(CalAppDataPath+'fr_holidays.csv') else
  begin
    r:= LazarusResources.Find('fr_holidays');
    csvvacs.CSVText:= r.value;
  end;
  TimeSepar:= DefaultFormatSettings.TimeSeparator;
  MemoToday1.Lines.Text:='';
  MemoToday2.Lines.Text:='';
  MemoCurDay1.Lines.Text:='';
  MemoCurDay2.Lines.Text:='';
  MemoSeasons11.Lines.Text:='';
  MemoSeasons21.Lines.Text:='';
  MemoSeasons12.Lines.Text:='';
  MemoSeasons22.Lines.Text:='';
  MoonDescs[0]:= 'Nouvelle Lune';
  MoonDescs[1]:= 'Premier quartier';
  MoonDescs[2]:= 'Dernier quartier';
  MoonDescs[3]:= 'Pleine lune';
  TrayCal.Icon:= Application.Icon;
end;

procedure TFCalendrier.FormActivate(Sender: TObject);
var
  i: Integer;
  line: string;
    r: TLResource;
begin
  if not Initialized then
  begin
    Initialized:= true;
    CurYear := YearOf(now);
    if MonthOf(now) < 7 then PageControl1.Activepage:= TS1
    else PageControl1.Activepage:= TS2;
    Settings:= TSettings.create(self);
    HalfImgsList:= TFichierList.Create;
    // Set defaults settings;
    Settings.colweekday:= clDefault;
    Settings.colsunday:= StringToColour('$00FFFF80');
    Settings.colferie:= StringToColour('$00FFFF80');
    Settings.colvaca:= CBVA.CheckColor;
    Settings.colvacb:= CBVB.CheckColor;
    Settings.colvacc:= CBVC.CheckColor;
    Settings.colvack:= CBVK.CheckColor;
    Settings.Timezone:= 60; // Paris tz
    Settings.latitude:= 43.94284;
    Settings.longitude:= 4.8089;
    // load towns from resources
    Prefs.csvtowns:= TCSVDocument.Create;
    if FileExists(CalAppDataPath+'fr_villes.csv')then Prefs.csvtowns.LoadFromFile(CalAppDataPath+'fr_villes.csv') else
    begin
      r:= LazarusResources.Find('fr_villes');
      Prefs.csvtowns.CSVText:= r.value;
    end;
    for i:= 0 to Prefs.csvtowns.RowCount-1 do
      Prefs.CBTowns.Items.Add(Prefs.csvtowns.Cells[0,i]);
    Prefs.CBTowns.ItemIndex:= 0;
    Settings.OnChange:= @SettingsOnChange;
    HalfImgsList.OnChange:= @SettingsOnChange;
    LoadSettings(cfgfilename);
    UpdateCal(curyear);
  end;
end;



procedure TFCalendrier.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  self.WState:= IntToHex(ord(self.WindowState), 4)+IntToHex(self.Top, 4)+
                    IntToHex(self.Left, 4)+IntToHex(self.Height, 4)+IntToHex(self.width, 4); ;
  if (self.WState<>Settings.wstate) or SettingsChanged then SaveSettings(cfgfilename);
  CloseAction:= caFree;
end;

function TFCalendrier.LoadSettings(Filename: string): Boolean;
var
  FilNamWoExt: string;
  i: integer;
  CfgXML: TXMLDocument;
  RootNode, SettingsNode, FilesNode :TDOMNode;
  imghalf: TFichier;
begin
  If not FileExists(Filename) then
  begin
    FilNamWoExt:= TrimFileExt(FileName);
    If FileExists (FilNamWoExt+'.bk0') then
    begin
      RenameFile(FilNamWoExt+'.bk0', filename);
      For i:= 1 to 5 do
      begin
        // Renomme les précédentes si elles existent
        if FileExists (FilNamWoExt+'.bk'+IntToStr(i))
             then  RenameFile(FilNamWoExt+'.bk'+IntToStr(i), FilNamWoExt+'.bk'+IntToStr(i-1));
      end;
    end else
    begin
       SaveSettings(filename)
    end;
  end;
  self.Position:= poDesktopCenter;
  ReadXMLFile(CfgXml, filename);
  RootNode := CfgXML.DocumentElement;
  SettingsNode:= CfgXML.DocumentElement.FindNode('settings');
  if Settingsnode<>nil then
  begin
    Settings.ReadXMLNode(SettingsNode);
    if Settings.SavSizePos then
    try
      WinState := TWindowState(StrToInt('$' + Copy(Settings.WState, 1, 4)));
      self.Top := StrToInt('$' + Copy(Settings.WState, 5, 4));
      self.Left := StrToInt('$' + Copy(Settings.WState, 9, 4));
      self.Height := StrToInt('$' + Copy(Settings.WState, 13, 4));
      self.Width := StrToInt('$' + Copy(Settings.WState, 17, 4));
      self.WindowState := WinState;
      PrevLeft:= self.left;
      PrevTop:= self.top;
    except
    end;
    if Settings.startwin then SetAutostart(ProgName, Application.exename)  else UnsetAutostart(ProgName);
    if Settings.StartMini or (Settings.SavSizePos and (Winstate=wsMinimized)) then
    begin
      WindowState:=wsNormal;
      Application.Minimize;
    end;
    if Settings.miniintray then TrayCal.visible:= true;
    CBVA.CheckColor:= Settings.colvaca;
    CBVB.CheckColor:= Settings.colvacb;
    CBVC.CheckColor:= Settings.colvacc;
    CBVK.CheckColor:= Settings.colvack;
    if Settings.savemoon then CBLune.checked:= Settings.cbmoon;
    if Settings.savevacs then begin
      CBVA.Checked:= Settings.cbvaca;
      CBVB.Checked:= Settings.cbvacb;
      CBVC.Checked:= Settings.cbvacc;
      CBVK.Checked:= Settings.cbvack;
    end;
  end;
  // Now load half images
  FilesNode:= CfgXML.DocumentElement.FindNode('files');
  if Filesnode<>nil then
  begin
    HalfImgsList.ReadXMLNode(FilesNode);
    loadImage;



  end;
  // only now, when settings are loaded
  For i:= 0 to 3 do aSG[i].OnDrawCell:= @SGDrawCell ;
  INvalidate;
end;


procedure TFCalendrier.loadImage;
var
  ImgHalf: TFichier;
  i: Integer;
  imgname: string;
begin
  Image1.Picture:= nil;
  Image2.Picture:= nil;
  PMnuAddImg.Caption:= 'Ajouter une image';
  PMnuDelImg.Visible:= false;
  i:= HalfImgsList.FindYearAndHalf(Curyear, pagecontrol1.TabIndex+1);
  if i>=0 then
  begin
    PMnuAddImg.Caption:= 'Modifier l'' image';
     PMnuDelImg.Visible:= true;
    ImgHalf:= HalfImgsList.GetItem(i);
    if FileExists(ImgHalf.LocalCopy) then imgname:= ImgHalf.LocalCopy
    else imgname:= ImgHalf.name;
    if pagecontrol1.TabIndex=0 then Image1.Picture.LoadFromFile(imgname)
    else Image2.Picture.LoadFromFile(imgname);
  end;
end;

function TFCalendrier.SaveSettings(filename: string): Boolean;
var
  CfgXML: TXMLDocument;
  RootNode, SettingsNode, FilesNode :TDOMNode;
  i: Integer;
begin
  Settings.WState:= '';
  if self.Top < 0 then self.Top:= 0;
  if self.Left < 0 then self.Left:= 0;
  // Main form size and position
  Settings.WState:= IntToHex(ord(self.WindowState), 4)+IntToHex(self.Top, 4)+
                    IntToHex(self.Left, 4)+IntToHex(self.Height, 4)+IntToHex(self.width, 4);
  Settings.Version:= version;
  Settings.cbmoon:= CBLune.checked;
  Settings.cbvaca:= CBVA.checked;
  Settings.cbvacb:= CBVB.checked;
  Settings.cbvacc:= CBVC.checked;
  Settings.cbvack:= CBVK.checked;
  try
     if FileExists(filename) then
     begin
       ReadXMLFile(CfgXml, filename);
       RootNode := CfgXML.DocumentElement;
     end else
     begin
       CfgXML := TXMLDocument.Create;
       RootNode := CfgXML.CreateElement('config');
       CfgXML.Appendchild(RootNode);
     end;
     SettingsNode:= RootNode.FindNode('settings');
     if SettingsNode <> nil then RootNode.RemoveChild(SettingsNode);
     SettingsNode:= CfgXML.CreateElement('settings');
     Settings.SaveToXMLnode(SettingsNode);
     RootNode.Appendchild(SettingsNode);
     FilesNode:=  RootNode.FindNode('files');
     if FilesNode <> nil then RootNode.RemoveChild(FilesNode);
     FilesNode:= CfgXML.CreateElement('files');
     HalfImgsList.SaveToXMLnode(FilesNode);
     RootNode.Appendchild(FilesNode);
     writeXMLFile(CfgXML, filename);

   finally

   end;
end;

function TFCalendrier.HideOnTaskbar: boolean;
begin
  result:= false;
  if (WindowState=wsMinimized) and Settings.HideInTaskbar then
  begin
    result:= true;
    visible:= false;
  end;
end;

procedure TFCalendrier.FormDestroy(Sender: TObject);
begin
  if assigned(csvsaints) then FreeAndNil(csvsaints);
  if assigned(csvferies) then FreeAndNil(csvferies);
  if assigned(csvvacs) then FreeAndNil(csvvacs);
end;


procedure TFCalendrier.MemoCurDayChange(Sender: TObject);
begin
  MemoCurDay2.Lines:= MemoCurDay1.Lines;
end;

procedure TFCalendrier.MemoSeasons1Change(Sender: TObject);
begin
  MemoSeasons12.Lines:= MemoSeasons11.Lines;
end;

procedure TFCalendrier.MemoSeasons2Change(Sender: TObject);
begin
  MemoSeasons22.Lines:= MemoSeasons21.Lines;
end;

procedure TFCalendrier.MemoTodayChange(Sender: TObject);
begin
  MemoToday2.Lines.Text:= MemoToday1.Lines.Text;
end;

procedure TFCalendrier.PMnuAddImgClick(Sender: TObject);
var
  CurImg: TFichier;
  i: Integer;
  jpg: TJPEGImage;
  rec: TRect;
begin
  jpg:= TJpegImage.Create;
  jpg.SetSize(Image1.width, Image1.Height);
  rec:= Rect(0,0,Image1.width, Image1.Height);
  CurImg.Year:= curyear;
  CurImg.Half:= PageControl1.TabIndex+1;
  i:= HalfImgsList.FindYearAndHalf(curyear, PageControl1.TabIndex+1);
  if i> 0 then
  begin
    CurImg:= HalfImgsList.GetItem(i);
    OPDHalf.InitialDir:= ExtractFileDir(CurImg.Name);
    OPDHalf.FileName:= ExtractFileName(CurImg.Name) ;
    PMnuAddImg.Caption:= 'Modifier l''image';
  end;
  if OPDHalf.execute then
  begin
    CurImg.Year:= CurYear;
    CurImg.Half:= PageControl1.TabIndex+1;
    CurImg.Name:= OPDHalf.FileName;
    CurImg.LocalCopy:= CalImagePath+InttoStr(CurImg.year)+'-'+InttoStr(CurImg.Half)+'.jpg';
    Image1.Picture.Clear;
    if i>=0 then
    begin
      HalfImgsList.ModifyFile(i, CurImg);
    end else
    begin
      HalfImgsList.AddFile(CurImg);
    end;
    if CurImg.Half=1 then
    begin
      Image1.Picture.LoadFromFile(CurImg.Name);
      Application.ProcessMessages;
      jpg.Canvas.CopyRect(rec, image1.Canvas, rec);
    end else
    begin
      Image2.Picture.LoadFromFile(CurImg.Name) ;
      Application.ProcessMessages;
      jpg.Canvas.CopyRect(rec, image2.Canvas, rec);
      jpg.SaveToFile(CurImg.LocalCopy);
    end;
    jpg.SaveToFile(CurImg.LocalCopy);
    if assigned(jpg) then FreeAndNil(jpg);
    if SettingsChanged then SaveSettings(cfgfilename);
  end;
{procedure TForm1.RescaleImage(newScale: Double);
var
  OrgWidth, OrgHeight: integer;
  Rect: TRect;
begin
  OrgWidth := Image1.Picture.Bitmap.Width;
  OrgHeight := Image1.Picture.Bitmap.Height;
  FImageScale := FImageScale * NewScale; //FImageScale-> private 1.0 on start(original)
  Rect := Image1.BoundsRect;
  Rect.Right := Rect.Left + Round(OrgWidth * FImageScale);
  Rect.Bottom := Rect.Top + Round(OrgHeight * FImageScale);
  Image1.Align := AlNone;
  Image1.BoundsRect := Rect;
  Image1.Stretch:= true;   //strech
end}
end;

procedure TFCalendrier.PMnuDelImgClick(Sender: TObject);
var
  i: integer;
  half: Integer;
begin
  half:= PageControl1.TabIndex+1;
  i:= HalfImgsList.FindYearAndHalf(CurYear, half);
  if i>=0 then
  begin
    DeleteFile(HalfImgsList.GetItem(i).LocalCopy);
    HalfImgsList.Delete(i);
    if Half=1 then Image1.Picture:=nil
    else Image2.Picture:= nil;
    if SettingsChanged then SaveSettings(cfgfilename);
  end;
end;

procedure TFCalendrier.PMnuMainPopup(Sender: TObject);
begin



end;

procedure TFCalendrier.PMnuQuitClick(Sender: TObject);
begin
  close();
end;

procedure TFCalendrier.PMnuRestoreClick(Sender: TObject);
begin
  iconized:= false;
  visible:= true;
  WindowState:=wsNormal;
 //Need to reload position as it can change during hide in taskbar process
  left:= PrevLeft;
  top:= PrevTop;

  Application.BringToFront;
end;

procedure TFCalendrier.SettingsOnChange(sender: TObject);
begin
  SettingsChanged:= true;
end;

procedure TFCalendrier.PMnuSettingsClick(Sender: TObject);
begin
  Prefs.PanStatus.Caption:= OSVersion.VerDetail ;
  Prefs.CBStartwin.Checked:= Settings.startwin;
  Prefs.CBSaveSizPos.Checked:= Settings.savsizepos;
  Prefs.CBStartmini.Checked:= Settings.startmini;
  Prefs.CBMiniintray.Checked:= Settings.miniintray;
  Prefs.CBHideinTaskBar.Checked:= Settings.hideintaskbar;
  prefs.CBMoonPhases.checked:= Settings.savemoon;
  prefs.CBSaveVacs.checked:= Settings.savevacs;
  Prefs.CPcolweek.Color:= Settings.colweekday;
  Prefs.CPcolsunday.Color:= Settings.colsunday;
  Prefs.CPColferie.Color:= Settings.colferie;
  Prefs.CPcolvaca.Color:= Settings.colvaca;
  Prefs.CPcolvacb.Color:= Settings.colvacb;
  Prefs.CPcolvacc.Color:= Settings.colvacc;
  Prefs.CPcolvack.Color:= Settings.colvack;
  Prefs.CBTowns.Text:= Settings.town;
  Prefs.CBTowns.ItemIndex:= Settings.townIndex;
  Prefs.ELatitude.Text:= FloatToString(Settings.latitude, '.');
  Prefs.ELongitude.Text:= FloatToString(Settings.longitude, '.');
  if Prefs.ShowModal<>mrOK then exit;              // Pas OK ? on ne change rien
  Settings.startwin:= Prefs.CBStartwin.Checked;
  Settings.savsizepos:= Prefs.CBSaveSizPos.Checked;
  Settings.startmini:= Prefs.CBStartmini.Checked;
  Settings.miniintray:= Prefs.CBMiniintray.Checked;
  Settings.hideintaskbar:= Prefs.CBHideinTaskBar.Checked;
  Settings.savemoon:= prefs.CBMoonPhases.checked;
  Settings.savevacs:= prefs.CBSaveVacs.checked;
  Settings.colweekday:= Prefs.CPcolweek.Color;
  Settings.colsunday:= Prefs.CPcolsunday.Color;
  Settings.colferie:= Prefs.CPColferie.Color;
  Settings.colvaca:= Prefs.CPcolvaca.Color;
  Settings.colvacb:= Prefs.CPcolvacb.Color;
  Settings.colvacc:= Prefs.CPcolvacc.Color;
  Settings.colvack:= Prefs.CPcolvack.Color;
  Settings.townIndex:= Prefs.CBTowns.ItemIndex;
  Settings.town:= Prefs.CBTowns.Text;
  Settings.latitude:= StringToFloat(Prefs.ELatitude.text, '.');
  Settings.longitude:= StringToFloat(Prefs.ELongitude.text, '.');
  CBVA.CheckColor:= Settings.colvaca;
  CBVB.CheckColor:= Settings.colvacb;
  CBVC.CheckColor:= Settings.colvacc;
  CBVK.CheckColor:= Settings.colvack;
  if SettingsChanged then SaveSettings(cfgfilename);
  INvalidate;
end;








procedure TFCalendrier.SBNextQClick(Sender: TObject);
var
  i: Integer;
begin
  if PageControl1.ActivePage=TS1 then
  begin
    PageControl1.ActivePage:=TS2;
  end else
  begin
    CurYear:= CurYear+1;
    UpdateCal(CurYear);
    Invalidate;
    PageControl1.ActivePage:=TS1;
  end;
  loadimage;
end;


procedure TFCalendrier.SBPrevQClick(Sender: TObject);
var
  i: Integer;
begin
  if PageControl1.ActivePage=TS1 then
  begin
    CurYear:= CurYear-1;
    UpdateCal(CurYear);
    Invalidate;
    PageControl1.ActivePage:=TS2;
  end else
  begin
    PageControl1.ActivePage:=TS1;
  end;
  loadimage;
end;

procedure TFCalendrier.SGMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
var
  aRow: integer;
  aCol: integer;
  MyDate: TDateTime;
  SGCur: TStringGrid;
  GridNum: Integer;
  MOnth: Word;
begin
  SGCur:= TStringGrid(Sender);
  GridNum := StrToInt(Copy(SgCur.Name, 3, 1));
  SGCur.MouseToCell(X, Y, aCol, aRow);
  Month:= aCol+1+ 3*(GridNum-1);
  if (aRow<>curRow) or (aCol<>curCol) then
  begin
    curRow:= aRow;
    curCol:= aCol;
    try
      MyDate:= EncodeDate (CurYear, Month, aRow);
      SGCur.Hint := DayInfos(MyDate);
      CurHint:= SGCur.Hint;
    except
      // Do nothing, wrong cell;
    end;
  end;
end;

function TFCalendrier.DayInfos(dDate: TDateTime): String;
var
  s, s1: string;
  doy: Integer;
  dtr, dts, dtsz : TDateTime;

begin
  doy:= DayOfTheYear(dDate);
  s:= Days[doy-1].sDesc;
  if s='' then s:= Days[doy-1].sSaint;
  Result:= s;
  if Days[doy-1].bFerie then
  begin
    s1:= Days[doy-1].sFerie;
    if (s1<>s) then Result:= Result+LineEnding+s1;
  end;
  Result:= Result+LineEnding+Format('%de jour, %de semaine', [doy, WeekOf(dDate)]);
  if Days[doy-1].bMoon then
  begin
    Result:= Result+LineEnding+Days[doy-1].sMoonDesc+' à '+FormatDateTime ('hh'+TimeSepar+'mm', Days[doy-1].dMoon);
  end;
  dtr:= Sunrise(dDate, Settings.latitude, Settings.longitude);
  dtr:= IncMinute(dtr, Settings.TimeZone+60*Integer(IsDST(dDate)));
  dts:= Sunset(dDate, Settings.latitude, Settings.longitude);
  dts:= IncMinute(dts, Settings.TimeZone+60*Integer(IsDST(dDate)));
  s:= 'Lever et coucher du soleil : '+FormatDateTime ('hh'+TimeSepar+'mm', dtr)+' - '+
                                      FormatDateTime ('hh'+TimeSepar+'mm', dts);
  Result:= Result+LineEnding+s;
  if Days[doy-1].bSeason then
  begin
    dtsz:= Days[doy-1].dSeason;
    dtsz:= IncMinute(dtsz, Settings.TimeZone+60*Integer(IsDST(dDate)));
    s:= Days[DOY-1].sSeasonDesc+' à '+FormatDateTime ('hh'+TimeSepar+'mm', dtsz);
    Result:= Result+LineEnding+s
  end;
end;

procedure TFCalendrier.SGSelectCell(Sender: TObject; aCol, aRow: Integer;
  var CanSelect: Boolean);
var
   SelDate: TDateTime;
   SGCur: TStringGrid;
   GridNum: Integer;
   Month: Word;
   s: String;
   doy: Integer;
begin
  SGCur := TStringGrid(Sender);
  GridNum := StrToInt(Copy(SgCur.Name, 3, 1));
  Month := ACol + 1 + 3 * (GridNum - 1);
  try
    SelDate:= EncodeDate(CurYear, Month, ARow);
    s:= FormatDateTime (DefaultFormatSettings.LongDateFormat, SelDate);
    s[1]:= UpCase(s[1]);
    s:=s+LineEnding+DayInfos(SelDate);
    MemoCurDay1.Lines.text:=  s;
  except
    // We are in a wrong place, do nothing
  end;
end;



procedure TFCalendrier.CBXClick(Sender: TObject);
var
  i: integer;
begin
  SettingsChanged:= true;
  Invalidate;
end;



procedure TFCalendrier.ETodayTimeChange(Sender: TObject);
begin
  ETodayTime2.text:= ETodayTime1.text;
end;





procedure TFCalendrier.SGDrawCell(Sender: TObject; aCol, aRow: integer;
  aRect: TRect; aState: TGridDrawState);
var
  X, Y: integer;
  S, s1: string;
  w: integer;
//  Bmp: TBitmap;
  SGCur: TStringGrid;
  GridNum: word;
  Month: word;
  MyDate: TDateTime;
  DefBrushColor: TColor;
  quarter: integer;
  Count: integer;
  max: integer;
  imgNum: integer;
begin
  SGCur := TStringGrid(Sender);
  GridNum := StrToInt(Copy(SgCur.Name, 3, 1));
  Month := ACol + 1 + 3 * (GridNum - 1);
  try
  MyDate:= EncodeDate(CurYear, Month, ARow);
  except
  end;
  s := SGCur.Cells[ACol, ARow];
  // On centre les mois
  if ARow = 0 then
  begin
    SGCur.Canvas.Font := PanStatus.Font;
    SGCur.Canvas.Font.Style:= [fsBold];
    w := SGCur.Canvas.TextWidth(s);
    x := aRect.Left + (aRect.Right - aRect.Left - w) div 2;
    y := 1 + aRect.Top;
    SGCur.Canvas.Brush.Color := clBtnface;
    SGCur.Canvas.Rectangle(aRect.Left, aRect.Top, aRect.Right, aRect.Bottom);
    SGCur.Canvas.TextOut(x, y, s);
    SGCur.Canvas.Font := SGCur.Font;
  end;

  // Get current day
  x := 2 + aRect.Left;
  y := 1 + aRect.Top;
  Quarter := StrToInt(SGCur.Name[3]);
  if aRow > 0 then
  begin
    Count := aMonths[(acol + 1) + (quarter - 1) * 3];
    max := aMonths[(acol + 2) + (quarter - 1) * 3];
    s := IntToStr(Days[Count + arow - 1].iDay) + ' ' + UpCase(Days[Count + arow - 1].sday[1]);
    s1 := Days[Count + arow - 1].sSaint;
    if (Count + arow - 1) < max then
    begin
      if (Days[Count+arow-1].bSunday) then
      begin
        SGCur.Canvas.Brush.Color := Settings.colsunday;
        SGCur.Canvas.FillRect(Rect(aRect.Left,aRect.Top,aRect.Right,aRect.Bottom));
      end;
      if (Days[Count+arow-1].bferie) then
      begin
        SGCur.Canvas.Brush.Color := Settings.colferie;
        SGCur.Canvas.FillRect(Rect(aRect.Left,aRect.Top,aRect.Right,aRect.Bottom));
        s1 := Days[Count + arow - 1].sferie;
      end;
      SGCur.Canvas.TextOut(x, y, s + ' ' + s1);
      if (Days[Count+arow-1].bHoliday) then
      begin
        s1:= Days[Count+arow-1].sHoliday;
        DefBrushColor:= Brush.Color;  // pour remettre à la couleur d'origine
        SGCur.Canvas.Pen.Style:=psClear;
        SGCur.Canvas.Brush.Style:=bsSolid;
        if (CBVA.Checked) and (Pos('A', s1) > 0) then
        begin
          SGCur.Canvas.Brush.Color:= Settings.colvaca;
          SGCur.Canvas.Rectangle(aRect.Right-9,aRect.Top,aRect.Right-6,aRect.Bottom);
          //SGCur.Canvas.Brush.Color:= DefBrushColor;
        end;
        if (CBVB.Checked) and (Pos('B', s1) > 0) then
        begin
          SGCur.Canvas.Brush.Color:= Settings.colvacb;
          SGCur.Canvas.Rectangle(aRect.Right-6,aRect.Top,aRect.Right-3,aRect.Bottom);
          // SGCur.Canvas.Brush.Color:= DefBrushColor;
        end;
        if (CBVC.Checked) and (Pos('C', s1) > 0) then
        begin
          SGCur.Canvas.Brush.Color:= Settings.colvacc;
          SGCur.Canvas.Rectangle(aRect.Right-3,aRect.Top,aRect.Right,aRect.Bottom);
          SGCur.Canvas.Brush.Color:= DefBrushColor;
        end;
        if (CBVK.Checked) and (Pos('K', s1) > 0) then
        begin
          SGCur.Canvas.Brush.Color:= Settings.colvack;
          SGCur.Canvas.Rectangle(aRect.Right-12,aRect.Top,aRect.Right-9,aRect.Bottom);
          SGCur.Canvas.Brush.Color:= DefBrushColor;
        end;
        SGCur.Canvas.Pen.Style:=psSolid;
      end;
      // Affiche les phases de la lune
      if (CBLune.Checked) and (Days[Count+arow-1].bMoon) then
      begin
        aRect.Top:= aRect.Top+(aRect.Bottom-aRect.Top-10) div 2;    // L'image doit faire 10 px
        aRect.Bottom:= aRect.Top+ 10;
        aRect.Right:= aRect.Right-2;                                 // Espace de 2 px à droite
        aRect.Left:= aRect.Right-10;
        s:='NLPQDQPL';
        ImgNum:= Pos(Days[Count+arow-1].sMoon, s) div 2;
        ImgLMoon.StretchDraw(SGCur.Canvas, ImgNum, aRect);
      end;
    end ;
  end;
  // Outline current day
  if MyDate=trunc(now) then
  begin
    SGCur.Canvas.brush.style:= bsClear;
    SGCur.Canvas.Pen.Color:= clRed;
    SGCur.Canvas.Rectangle(aRect.Left, aRect.Top, aRect.Right-1, aRect.Bottom-1);
    //SGCur.Canvas.brush.style:= bsSolid;
  end;
end;



procedure TFCalendrier.Timer1Timer(Sender: TObject);
var
 s: String;
 CurDay: Integer;
begin
  s:= FormatDateTime (DefaultFormatSettings.LongDateFormat+' - hh'+TimeSepar+'mm'+TimeSepar+'ss', now);
  s[1]:= UpCase(s[1]);
  ETodayTime1.Caption:= s;
  Curday:= DayofTheYear(now);
  if Curday>Today then
  begin
    s:= DayInfos(now);
    MemoToday1.Lines.Text:= s;
    Today:=Curday;
  end;
end;

procedure TFCalendrier.UpdateCal(Annee: word);
var
  s : string;
  BegYear: TDateTime;
  CYear, CMonth, CDay: word;
  DaysCnt: word;
  i, j: integer;
  Currentday: TDateTime;
  PaqDay, DepDay, MerDay: TDateTime;
  DOY: Integer;
  vacbeg, vacend: TDateTime;
  LuneYr: TMoonDays;
  dt: TDateTime;
  dSpr, dSum, DAut, dWin: TDateTime;
begin
  // Sans objet avant l'année 1583 (calendrier julien)
  if Annee < 1583 then Annee := 1583;
  // Ni après l'année 9998
  if Annee > 9998 then Annee := 9998;
  // Bissextile ?
  if Isleapyear(Annee) then
  begin
    aMonths := leapyear;
    DaysCnt := 366;
  end else
  begin
    aMonths := noleapyear;
    DaysCnt := 365;
  end;
  Caption := 'Calendrier ' + IntToStr(Annee);
  EYear.Text := IntToStr(Annee);
  Application.Title := Caption;
  for i := 0 to 11 do
  begin
    s := DefaultFormatSettings.LongMonthNames[i + 1];
    s[1] := upcase(s[1]);
    aSG[i div 3].Cells[i - 3 * (i div 3), 0] := s;
  end;
  // Ecrit les jours
  BegYear := EncodeDate(Annee, 1, 1);

  setlength(Days, DaysCnt);
  j := 0;
  for i := 1 to DaysCnt do
  begin
    CurrentDay:= BegYear + i - 1;
    DecodeDate(CurrentDay, CYear, CMonth, CDay);
    //s1 := csvsaints.Cells[1, j];
    if (DaysCnt = 365) and (j = 58) then
      Inc(j); // on saute le 29 février !
    Days[i - 1].index := i;
    Days[i - 1].ddate := CurrentDay;
    Days[i - 1].sday := DefaultFormatSettings.ShortDayNames[DayOfWeek(CurrentDay)];
    Days[i - 1].iDay := CDay;
    Days[i - 1].iMonth := CMonth;
    Days[i - 1].iQuarter := ((cMonth - 1) div 3) + 1;
    Days[i - 1].sSaint := csvsaints.Cells[1, j];
    Days[i - 1].sDesc:= csvsaints.Cells[2, j];;
    //sDisplay : String;
    if (DayOfWeek(CurrentDay)= 1) then Days[i-1].bSunday := True
    else Days[i - 1].bSunday := False;
    Inc(j);
  end;
  PaqDay:= GetPaques(Annee);
  DepDay:= GetDeportes(Annee);
  MerDay:= GetFetMeres(Annee);
  // reLoad and Update csvFerie
  csvferies.CSVText:= FeriesTxt;
  csvferies.CSVText:= StringReplace(csvferies.CSVText, 'YYYY', InttoStr(Annee), [rfReplaceAll]);
  csvferies.CSVText:= StringReplace(csvferies.CSVText, 'DIPAQ', DateToStr(PaqDay), []);
  csvferies.CSVText:= StringReplace(csvferies.CSVText, 'LUPAQ', DateToStr(PaqDay+1), [rfIgnoreCase]);
  csvferies.CSVText:= StringReplace(csvferies.CSVText, 'JEASC', DateToStr(PaqDay+39), [rfIgnoreCase]);
  csvferies.CSVText:= StringReplace(csvferies.CSVText, 'DIPEN', DateToStr(PaqDay+49), [rfIgnoreCase]);
  csvferies.CSVText:= StringReplace(csvferies.CSVText, 'SOUDEP', DateToStr(DepDay), [rfIgnoreCase]);
  csvferies.CSVText:= StringReplace(csvferies.CSVText, 'FETMER', DateToStr(MerDay), [rfIgnoreCase]);
 for i:= 0 to csvferies.RowCount-1 do
  begin
    DOY:= Trunc(StrToDate(csvferies.Cells[0,i])-BegYear);
    if annee >= StrToInt(csvferies.Cells[3,i]) then
    begin
      Days[DOY].sFerie := csvferies.Cells[1,i];
      if length(csvferies.Cells[2,i])>0 then Days[DOY].sDesc:= csvferies.Cells[2,i];
      Days[DOY].bFerie:= true;  ;
    end;
  end;
  // Update holidays
  for i:= 0 to csvvacs.RowCount-1 do
  begin
    vacbeg:= StrToDate(csvvacs.cells[0,i]);
    vacend:= StrToDate(csvvacs.cells[1,i]);
    s:= csvvacs.cells[3,i];
    if (vacend>= BegYear) then
    begin
      for j:= 0 to 100 do
      begin
        DOY:= trunc(vacbeg-BegYear);
        if (DOY>=0) and (DOY<length(days)-1) then
        begin
          Days[DOY].bHoliday:= true;
          Days[DOY].sHoliday:= Days[DOY].sHoliday+s;
        end;
        if (vacbeg=vacend) or (vacbeg>begyear+length(days)-1) then break;
        vacbeg:= vacbeg+1;
      end;
    end;
  end;
  // Update moon phases
  s:='NLPQDQPL';
  LuneYr:= Get_MoonDays(BegYear-10);
  for i:= 1 to length(LuneYr) do
  begin
    DOY:= trunc(LuneYr[i].MDays-BegYear);
    if (DOY >=0) and (DOY<length(days)-1) then
    begin
      Days[DOY].bMoon:= true;
      Days[DOY].sMoon:= LuneYr[i].MType;
      dt:= LuneYr[i].MDays;
      dt:= IncMinute(dt, Settings.TimeZone+60*Integer(IsDST(dt)));
      Days[DOY].dMoon:= dt;
      Days[DOY].sMoonDesc:= MoonDescs[Pos(Days[DOY].sMoon, s) div 2];
    end;
  end;
  // Saisons
  dSpr:= GetSeasonDate(Annee, 0);
  dSum:= GetSeasonDate(Annee, 1);
  dAut:= GetSeasonDate(Annee, 2);
  dWin:= GetSeasonDate(Annee, 3);
  DOY:= trunc(dSpr-BegYear);
  Days[DOY].bSeason:= true;
  Days[DOY].dSeason:= dSpr;
  Days[DOY].sSeasonDesc:= 'Printemps';
  dSpr:= IncMinute(dSpr, Settings.TimeZone+60*Integer(IsDST(dSpr)));
  s:= Days[DOY].sSeasonDesc+' ; '+FormatDateTime (DefaultFormatSettings.LongDateFormat+' - hh'+TimeSepar+'mm', Days[DOY].dSeason)+LineEnding;
  DOY:= trunc(dSum-BegYear);
  Days[DOY].bSeason:= true;
  Days[DOY].dSeason:= dSum;
  Days[DOY].sSeasonDesc:= 'Eté';
  dSum:= IncMinute(dSum, Settings.TimeZone+60*Integer(IsDST(dSum)));
  MemoSeasons11.Lines.text:=s+Days[DOY].sSeasonDesc+' : '+FormatDateTime (DefaultFormatSettings.LongDateFormat+' - hh'+TimeSepar+'mm', dSum);
  DOY:= trunc(dAut-BegYear);
  Days[DOY].bSeason:= true;
  Days[DOY].dSeason:= dAut;
  Days[DOY].sSeasonDesc:='Automne';;
  dAut:= IncMinute(dAut, Settings.TimeZone+60*Integer(IsDST(dAut)));
  s:= Days[DOY].sSeasonDesc+' ; '+FormatDateTime (DefaultFormatSettings.LongDateFormat+' - hh'+TimeSepar+'mm', dAut)+LineEnding;
  DOY:= trunc(dWin-BegYear);
  Days[DOY].bSeason:= true;
  Days[DOY].dSeason:= dWin;
  Days[DOY].sSeasonDesc:='Hiver';
  dWin:= IncMinute(dWin, Settings.TimeZone+60*Integer(IsDST(dWin)));
  MemoSeasons21.Lines.text:=s+Days[DOY].sSeasonDesc+' : '+FormatDateTime (DefaultFormatSettings.LongDateFormat+' - hh'+TimeSepar+'mm', dWin); ;
end;




end.
