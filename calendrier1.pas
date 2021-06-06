//******************************************************************************
// Calendrier main form
// bb - sdtp - May 2021
//******************************************************************************

unit calendrier1;

{$mode objfpc}{$H+}

interface

uses
  {$IFDEF WINDOWS}
    Win32Proc,
  {$ENDIF}
  {$IFDEF linux}
    clocale, // Needed to get proper localized dates
  {$ENDIF}
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, ComCtrls,
  Grids, StdCtrls, lazbbcontrols, Suntime, Moonphases, Seasons, Easter,
  csvdocument, Types, DateUtils, lazbbastro, LResources, Buttons, Menus,
  UniqueInstance, registry, lazbbutils, lazbbautostart, LazUTF8, lazbbosver,
  laz2_DOM, laz2_XMLRead, laz2_XMLWrite, PrintersDlgs, calsettings, ImgResiz,
  lazbbaboutupdate, lazbbinifiles, Towns1, Clipbrd, LCLIntf, Printcal;


type
   { int64 or longint type for Application.QueueAsyncCall }
  {$IFDEF CPU32}
    iDays= LongInt;
  {$ENDIF}
  {$IFDEF CPU64}
    iDays= Int64;
  {$ENDIF}


  TDay = record
    index: integer;
    ddate: TDateTime;
    sday: string;
    sSaint: string;
    sStDesc: String;
    sFerie: String;
    sFeDesc: string;
    sHoliday: string;       //A, B, C, K
    sMoon: String;
    iMoonIndex: Integer;
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
    Easter1: TEaster;
    EYear: TEdit;
    ILMenus: TImageList;
    ImageHalf: TImage;
    LSeasons1: TLabel;
    LSelDay: TLabel;
    LSeasons2: TLabel;
    LTodayDesc: TLabel;
    LTodayTime: TLabel;
    LImageInsert: TLabel;
    Moonphases1: TMoonphases;
    PrintDialog1: TPrintDialog;
    PTMnuPrint: TMenuItem;
    PMnuPrint: TMenuItem;
    PMnuCopy: TMenuItem;
    MnuSep3: TMenuItem;
    MnuSep4: TMenuItem;
    MnuSep1: TMenuItem;
    MnuSep2: TMenuItem;
    SBPrint: TSpeedButton;
    Seasons1: TSeasons;
    Suntime1: TSuntime;
    TabHalf1: TPanel;
    TabHalf2: TPanel;
    PanHalf: TPanel;
    PanImg: TPanel;
    PanInfos: TPanel;
    PanSeasons: TTitlePanel;
    PanSelDay: TTitlePanel;
    PanToday: TTitlePanel;
    PMnuQuit: TMenuItem;
    PMnuAbout: TMenuItem;
    PTMnuAbout: TMenuItem;
    PTMnuSettings: TMenuItem;
    PTMnuIconize: TMenuItem;
    PTMnuMaximize: TMenuItem;
    PMnuDelImg: TMenuItem;
    PMnuAddImg: TMenuItem;
    PTMnuRestore: TMenuItem;
    PTMnuQuit: TMenuItem;
    PMnuSettings: TMenuItem;
    PanStatus: TPanel;
    PMnuMain: TPopupMenu;
    PMnuTray: TPopupMenu;
    SBNextQ: TSpeedButton;
    SBPrevQ: TSpeedButton;
    SBSettings: TSpeedButton;
    SBAbout: TSpeedButton;
    SBQuit: TSpeedButton;
    ScrollBox2: TScrollBox;
    SG1: TStringGrid;
    SG2: TStringGrid;
    Timer1: TTimer;
    Timer2: TTimer;
    TrayCal: TTrayIcon;
    UniqueInstance1: TUniqueInstance;
    procedure CBXClick(Sender: TObject);
    procedure EYearChange(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure PMnuAddImgClick(Sender: TObject);
    procedure PMnuCopyClick(Sender: TObject);
    procedure PMnuDelImgClick(Sender: TObject);
    procedure PMnuMainPopup(Sender: TObject);
    procedure PMnuTrayPopup(Sender: TObject);
    procedure PTMnuIconizeClick(Sender: TObject);
    procedure PTMnuMaximizeClick(Sender: TObject);
    procedure PTMnuRestoreClick(Sender: TObject);
    procedure SBAboutClick(Sender: TObject);
    procedure SBNextQClick(Sender: TObject);
    procedure SBPrevQClick(Sender: TObject);
    procedure SBPrintClick(Sender: TObject);
    procedure SBQuitClick(Sender: TObject);
    procedure SBSettingsClick(Sender: TObject);
    procedure SGMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure SGSelectCell(Sender: TObject; aCol, aRow: Integer;
      var CanSelect: Boolean);
    procedure SGDrawCell(Sender: TObject; aCol, aRow: integer;
      aRect: TRect; aState: TGridDrawState);
    procedure TabHalfMouseLeave(Sender: TObject);
    procedure TabHalfMouseEnter(Sender: TObject);
    procedure TabHalfClick(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure Timer2Timer(Sender: TObject);
    procedure TrayCalClick(Sender: TObject);
  private
    Half: Integer;
    prevHalfColor: TColor;
    CanClose: Boolean;
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
    MoonDescs: TStringArray;
    sMoonphase: String;
    sSeason: String;
    csvsaints, csvferies,csvvacs: TCSVDocument;
    FeriesTxt: String;
    ColorDay, ColorSunday, ColorFerie: TColor;
    Today: Integer;
    curRow, curCol : Integer;
    curHint: String;
    TimeSepar: String;
    SettingsChanged: Boolean;
    sUse64bitcaption: string;
    ChkVerInterval: Integer;
    LangFile: TBbInifile;
    CancelBtn, YesBtn, NoBtn : String;
    sNoLongerChkUpdates: String;
    sCannotGetNewVerList: String;
    sPMnuAddImgCaption: String;
    sPMnuModImgCaption: String;
    sDayWeekInfo: String;
    sSunRiseAndSet: String;
    sSeasonSpring, sSeasonSummer, sSeasonAutumn, sSeasonWinter: String;
    sUrlProgSite: String;
    sConfirmDelImg: String;
    sHolidayZone: String;
    ImageLoaded: Boolean;
    procedure OnAppMinimize(Sender: TObject);
    procedure OnQueryendSession(var Cancel: Boolean);
    procedure UpdateCal(Annee: word);
    function DayInfos(dDate: TDateTime): String;
    function LoadSettings(Filename: string): Boolean;
    function SaveSettings(filename: string): Boolean;
    function HideOnTaskbar: boolean;
    procedure SettingsOnChange(sender: TObject);
    procedure loadimage;
    procedure showHalf(n: integer);
    procedure InitAboutBox;
    procedure CheckUpdate(ndays: iDays);
    procedure ModLangue;
  public
    aMonths: array [1..13] of integer;
    Days: array of TDay;
    HalfImgsList: TFichierList;
    curyear: integer;
    Settings: TSettings;
    SPrintHalf: String;
    sMainCaption: String;
    sFirst, sSecond: String;
  end;

const
   // Images index of popup menu items
   ixAddImgE = 0;
   ixAddImgD = 1;
   ixDelImgE = 2;
   ixDelImgD = 3;
   ixSettngE = 4;
   ixSettngD = 5;
   ixAboutE  = 6;
   ixAboutD  = 7;
   ixQuitE   = 8;
   ixQuitD   = 9;
   // Images index of Tray Menu items
   ixRestorE = 10;
   ixRestorD = 11;
   ixMaximizE  = 12;
   ixMaximizD  = 13;
   ixIconizE = 14;
   ixIconizD = 15;

var
  FCalendrier: TFCalendrier;

const
  leapyear: array [1..13] of integer = (0, 31, 60, 91, 121, 152, 182, 213, 244, 274, 305, 335, 366);
  noleapyear: array [1..13] of integer =     (0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334, 365);
  Moonphs='Nouvelle Lune,Premier croissant,Premier quartier,Gibbeuse croissante,Pleine lune,'+
          'Gibbeuse décroissante,Dernier quartier,Dernier croissant';

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
{$IFDEF WINDOWS}
var
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
  {$I calendrier.lrs}
  // Intercept system commands
  Application.OnMinimize:=@OnAppMinimize;
  Application.OnQueryEndSession:= @OnQueryendSession;
  CanClose:= false;
  Initialized := False;
  CompileDateTime:= StringToTimeDate({$I %DATE%}+' '+{$I %TIME%}, 'yyyy/mm/dd hh:nn:ss');
  Iconized:= false;
  OS := 'Unk';
  ProgName := 'calendrier';
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
    //wxbitsrun := 0;
    UserAppsDataPath := GetUserDir;
  {$ENDIF}
  {$IFDEF WINDOWS}
    OS := 'Windows ';
    // get user data folder
    s := ExtractFilePath(ExcludeTrailingPathDelimiter(GetAppConfigDir(False)));
    if Ord(WindowsVersion) < 7 then UserAppsDataPath := s                     // NT to XP
    else UserAppsDataPath := ExtractFilePath(ExcludeTrailingPathDelimiter(s)) + 'Roaming'; // Vista to W10
    LazGetShortLanguageID(LangStr);
  {$ENDIF}
  version := GetVersionInfo.ProductVersion;
  CalAppDataPath:= UserAppsDataPath + PathDelim + ProgName + PathDelim;
  if not DirectoryExists(CalAppDataPath) then CreateDir(CalAppDataPath);
  CalImagePath:= CalAppDataPath+'images'+PathDelim;
  if not DirectoryExists(CalImagePath) then CreateDir(CalImagePath);
  cfgfilename:= CalAppDataPath+ProgName+'.xml';
  // Chargement des chaînes de langue...
  LangFile:= TBbIniFile.create(CalExecPath+ProgName+'.lng');
  if Langstr<>'fr' then LangStr:='en';
  OSVersion:= TOSVersion.Create(LangStr, LangFile);
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
  LTodayDesc.Caption:='';
  LSelDay.Caption:='';
  LSeasons1.Caption:='';
  LSeasons2.Caption:='';
  // initialize MoonDescs;
  MoonDescs:= Moonphs.Split(',');
end;

procedure TFCalendrier.FormActivate(Sender: TObject);
var
  i: Integer;
  r: TLResource;
  s: String;
begin
  if not Initialized then
  begin
    Initialized:= true;
    TrayCal.Icon:= Application.Icon;
    // place properly grids and panels
    SG1.Left := 0;
    PanImg.left := SG1.Width+1;
    PanInfos.left:= SG1.Width+1;
    PanInfos.top:= PanImg.Height+4;
    SG2.Left := PanImg.left+PanImg.Width + 1;
    CurYear := YearOf(now);
    Today:= DayofTheYear(now);
    if MonthOf(now) < 7 then half:= 1 else half:=2;
    Showhalf(half);
    Settings:= TSettings.create(self);
    HalfImgsList:= TFichierList.Create;
    // Set defaults settings;
    Settings.coluser:= clDefault;
    Settings.colsunday:= StringToColour('$00FFFF80');
    Settings.colferie:= StringToColour('$00FFFF80');
    Settings.colback:= clDefault; ;
    Settings.colvaca:= CBVA.CheckColor;
    Settings.colvacb:= CBVB.CheckColor;
    Settings.colvacc:= CBVC.CheckColor;
    Settings.colvack:= CBVK.CheckColor;
    Settings.Timezone:= 1; // Paris tz
    Settings.latitude:= 43.94284;
    Settings.longitude:= 4.8089;
    Prefs.CalAppDataPath:= CalAppDataPath;
    InitAboutBox;
    LoadSettings(cfgfilename);
    // load towns from resources in prefs form
    // Todo Localize towns list
    if FileExists(CalAppDataPath+'fr_villes.csv')then Prefs.csvtowns.LoadFromFile(CalAppDataPath+'fr_villes.csv') else
    begin
      r:= LazarusResources.Find('fr_villes');
      Prefs.csvtowns.CSVText:= r.value;
    end;
    for i:= 0 to Prefs.csvtowns.RowCount-1 do
      Prefs.CBTowns.Items.Add(Prefs.csvtowns.Cells[0,i]);
    Prefs.CBTowns.ItemIndex:= 0;
    ModLangue;
    Settings.OnChange:= @SettingsOnChange;
    HalfImgsList.OnChange:= @SettingsOnChange;
    UpdateCal(curyear);
    loadimage;
    s:= FormatDateTime (DefaultFormatSettings.LongDateFormat+' - hh'+TimeSepar+'mm'+TimeSepar+'ss', now);
    s[1]:= UpCase(s[1]);
    LTodayTime.Caption:= s;
    LTodayDesc.Caption:= DayInfos(now);
    if (Pos('64', OSVersion.Architecture)>0) and (OsTarget='32 bits') then
    begin
      ShowMessage(sUse64bitcaption);
    end;
    Application.QueueAsyncCall(@CheckUpdate, ChkVerInterval);       // async call to let icons loading
    SG1.OnDrawCell:= @SGDrawCell;
    SG1.Invalidate;
    SG2.OnDrawCell:= @SGDrawCell;
    SG2.Invalidate;
  end;
  DefaultFormatSettings.LongDateFormat:='dddd dd mmmm yyyy';
end;

// About Box initialization

procedure TFCalendrier.InitAboutBox;
var
  IniFile: TBbInifile;
begin
   // Check inifile with URLs, if not present, then use default
  IniFile:= TBbInifile.Create(ProgName+'.ini');
  AboutBox.ChkVerURL := IniFile.ReadString('urls', 'ChkVerURL','https://github.com/bb84000/calendrier/releases/latest');
  AboutBox.UrlWebsite:= IniFile.ReadString('urls', 'UrlWebSite','https://www.sdtp.com');
  AboutBox.UrlSourceCode:=IniFile.ReadString('urls', 'UrlSourceCode','https://github.com/bb84000/calendrier');
  sUrlProgSite:= IniFile.ReadString('urls','UrlProgSite','https://github.com/bb84000/calendrier');   // Link Localized in modlangue
  ChkVerInterval:= IniFile.ReadInt64('urls', 'ChkVerInterval', 3);
  if Assigned(IniFile) then FreeAndNil(IniFile);
  AboutBox.Image1.Picture.LoadFromLazarusResource('calendrier32');
  AboutBox.LProductName.Caption := GetVersionInfo.FileDescription;
  AboutBox.LCopyright.Caption := GetVersionInfo.CompanyName + ' - ' + DateTimeToStr(CompileDateTime);
  AboutBox.LVersion.Caption := 'Version: ' + Version + ' (' + OS + OSTarget + ')';
  AboutBox.LVersion.Hint:= OSVersion.VerDetail;
  AboutBox.LUpdate.Hint := AboutBox.sLastUpdateSearch + ': ' + DateToStr(Settings.LastUpdChk);
  AboutBox.Version:= Version;
  AboutBox.ProgName:= ProgName;
end;

procedure TFCalendrier.CheckUpdate(ndays: iDays);
var
  errmsg: string;
  sNewVer: string;
  CurVer, NewVer: int64;
  alertpos: TPosition;
  alertmsg: string;
begin
  //Dernière recherche il y a "days" jours ou plus ?
  errmsg := '';
  alertmsg:= '';
  if not visible then alertpos:= poDesktopCenter
  else alertpos:= poMainFormCenter;
  if (Trunc(Now)>= Trunc(Settings.LastUpdChk)+ndays) and (not Settings.NoChkNewVer) then
  begin
     Settings.LastUpdChk := Trunc(Now);
     AboutBox.Checked:= true;
     AboutBox.ErrorMessage:='';
     //AboutBox.version:= '0.1.0.0' ;   // This is to check the procedure works properly
     sNewVer:= AboutBox.ChkNewVersion;
     errmsg:= AboutBox.ErrorMessage;
    if length(sNewVer)=0 then
     begin
       if length(errmsg)=0 then alertmsg:= sCannotGetNewVerList
       else alertmsg:= errmsg;
       if AlertDlg(Caption,  alertmsg, ['OK', CancelBtn, sNoLongerChkUpdates],
                    true, mtError, alertpos)= mrYesToAll then Settings.NoChkNewVer:= true;
     end;
     NewVer := VersionToInt(sNewVer);
     // Cannot get new version
     if NewVer < 0 then exit;
     CurVer := VersionToInt(AboutBox.version);
     if NewVer > CurVer then
     begin
       Settings.LastVersion:= sNewVer;
       AboutBox.LUpdate.Caption := Format(AboutBox.sUpdateAvailable, [sNewVer]);
       AboutBox.NewVersion:= true;
       AboutBox.ShowModal;
     end else
     begin
       AboutBox.LUpdate.Caption:= AboutBox.sNoUpdateAvailable;
     end;
     Settings.LastUpdChk:= now;
   end else
   begin
    if VersionToInt(Settings.LastVersion)>VersionToInt(version) then
       AboutBox.LUpdate.Caption := Format(AboutBox.sUpdateAvailable, [Settings.LastVersion]) else
       AboutBox.LUpdate.Caption:= AboutBox.sNoUpdateAvailable;
   end;
   AboutBox.LUpdate.Hint:= AboutBox.sLastUpdateSearch + ': ' + DateToStr(Settings.LastUpdChk);

end;

procedure TFCalendrier.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  // If the application can be minimized in tray, then don't close but iconize
  if CanClose then
  begin
    self.WState:= IntToHex(ord(self.WindowState), 4)+IntToHex(self.Top, 4)+
                    IntToHex(self.Left, 4)+IntToHex(self.Height, 4)+IntToHex(self.width, 4); ;
    if (self.WState<>Settings.wstate) or SettingsChanged then SaveSettings(cfgfilename);
    CloseAction:= caFree;
  end else
  begin
    PTMnuIconizeClick(sender);
    CloseAction := caNone;
  end;
end;

function TFCalendrier.LoadSettings(Filename: string): Boolean;
var
  FilNamWoExt: string;
  i: integer;
  CfgXML: TXMLDocument;
  RootNode, SettingsNode, FilesNode :TDOMNode;
begin
  result:= true;
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
  SettingsNode:= RootNode.FindNode('settings');
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
      result:= false;
    end;
    if Settings.timezone > 12 then Settings.timezone:= Settings.timezone/60;  // Old timezone
    if Settings.startwin then SetAutostart(ProgName, Application.exename)  else UnsetAutostart(ProgName);
    TrayCal.visible:= Settings.miniintray;
    CanClose:= not Settings.miniintray;
    if Settings.StartMini or (Settings.SavSizePos and (Winstate=wsMinimized)) then
    begin
      WindowState:=wsNormal;
      Application.Minimize;
    end;
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
  end;
end;


procedure TFCalendrier.loadImage;
var
  ImgHalf: TFichier;
  i: Integer;
  imgname: string;
begin
  ImageLoaded:= false;
  ImageHalf.Picture:= nil;
  LImageInsert.Visible:= true;
  PMnuAddImg.Caption:= sPMnuAddImgCaption;
  PMnuDelImg.Visible:= false;
  i:= HalfImgsList.FindYearAndHalf(Curyear, Half);
  if i>=0 then
  begin
    LImageInsert.Visible:= false;
    PMnuAddImg.Caption:= sPMnuModImgCaption;
    PMnuDelImg.Visible:= true;
    ImgHalf:= HalfImgsList.GetItem(i);
    if FileExists(ImgHalf.LocalCopy) then imgname:= ImgHalf.LocalCopy
    else imgname:= ImgHalf.name;
    ImageHalf.Picture.LoadFromFile(imgname);
    ImageLoaded:= true;
  end;
end;

function TFCalendrier.SaveSettings(filename: string): Boolean;
var
  CfgXML: TXMLDocument;
  RootNode, SettingsNode, FilesNode :TDOMNode;
  FilNamWoExt: String;
  i: Integer;
begin
  Result:= true;
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
     // On sauvegarde les versions précédentes
     FilNamWoExt:= TrimFileExt(filename);
     if FileExists (FilNamWoExt+'.bk5')                   // Efface la plus ancienne
     then  DeleteFile(FilNamWoExt+'.bk5');                // si elle existe
     For i:= 4 downto 0
      do if FileExists (FilNamWoExt+'.bk'+IntToStr(i))     // Renomme les précédentes si elles existent
        then  RenameFile(FilNamWoExt+'.bk'+IntToStr(i), FilNamWoExt+'.bk'+IntToStr(i+1));
     if FileExists (filename) then  RenameFile(filename, FilNamWoExt+'.bk0');
     // Et on sauvegarde la nouvelle config
     writeXMLFile(CfgXML, filename);
   except
     Result:= False;
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
  if assigned(LangFile) then FreeAndNil(LangFile);
  if assigned(csvsaints) then FreeAndNil(csvsaints);
  if assigned(csvferies) then FreeAndNil(csvferies);
  if assigned(csvvacs) then FreeAndNil(csvvacs);
end;

// The three following procedures mimics tabs
// We use "tag" property to define the number of the tab (coresponding to ActiveTab)
// Tabs are done with panels

procedure TFCalendrier.showHalf(n: integer);
begin
  if half=1 then
  begin
    TabHalf1.font.style:= [fsBold];
    TabHalf1.color:= clNone;
    TabHalf2.font.style:= [];
    TabHalf2.color:= clDefault;
    Invalidate;
  end else
  begin
    TabHalf1.font.style:= [];
    TabHalf1.color:= clDefault;
    TabHalf2.font.style:= [fsBold];
    TabHalf2.color:= clNone;
    Invalidate;
  end;
end;

// Show mouse hover on non active tab

procedure TFCalendrier.TabHalfMouseEnter(Sender: TObject);
begin
  prevHalfColor:=TPanel(Sender).Color;
  if TPanel(Sender).tag<>half then TPanel(Sender).color:= clGradientInactiveCaption;
end;

procedure TFCalendrier.TabHalfMouseLeave(Sender: TObject);
begin
  if TPanel(Sender).tag<>half then TPanel(Sender).color:= prevHalfColor;
end;

// Click on non active tab changes

procedure TFCalendrier.TabHalfClick(Sender: TObject);
begin
  if (TPanel(Sender).Tag<>Half) then
  begin
    half:= TPanel(Sender).Tag;
    showHalf (tag);
    loadimage;
  end;
end;

procedure TFCalendrier.PMnuAddImgClick(Sender: TObject);
var
  CurImg: TFichier;
  i: Integer;
begin
  CurImg.Year:= curyear;
  CurImg.Half:= Half;
  i:= HalfImgsList.FindYearAndHalf(curyear, Half);
  if i> 0 then
  begin
    CurImg:= HalfImgsList.GetItem(i);
    FImgResiz.InitialDir:= ExtractFileDir(CurImg.Name);
    FImgResiz.FileName:= ExtractFileName(CurImg.Name) ;
    PMnuAddImg.Caption:= sPMnuModImgCaption;
  end;
  FImgResiz.ImgWidth:= ImageHalf.Width;
  FImgResiz.ImgHeight:= ImageHalf.Height;
  if FImgResiz.showModal=mrOK then
  begin
    CurImg.Year:= CurYear;
    CurImg.Half:= Half;
    CurImg.Name:= FImgResiz.filename;
    CurImg.LocalCopy:= CalImagePath+InttoStr(CurImg.year)+'-'+InttoStr(CurImg.Half)+'.jpg';
    ImageHalf.Picture.Clear;
    if i>=0 then
    begin
      HalfImgsList.ModifyFile(i, CurImg);
    end else
    begin
      HalfImgsList.AddFile(CurImg);
    end;
    ImageHalf.Picture.assign(FImgResiz.jpeg);
    Application.ProcessMessages;
    FImgResiz.jpeg.SaveToFile(CurImg.LocalCopy);
    LImageInsert.Visible:= False;
    if SettingsChanged then SaveSettings(cfgfilename);
  end;
end;

procedure TFCalendrier.PMnuCopyClick(Sender: TObject);
var
  FromCmp: TComponent;
  s: String;
begin
  s:= '';
  FromCmp:= PMnuMain.PopupComponent;
  if FromCmp=PanToday then s:= LTodayTime.Caption+LineEnding+LTodayDesc.Caption;
  if FromCmp=PanSelDay then s:= LSelDay.Caption;
  if FromCmp=PanSeasons then s:= LSeasons1.Caption+LineEnding+LSeasons2.Caption;
  Clipboard.AsText:= s;;
end;

procedure TFCalendrier.PMnuDelImgClick(Sender: TObject);
var
  i: integer;
begin
  i:= HalfImgsList.FindYearAndHalf(CurYear, half);
  if i>=0 then
  begin
    if  MsgDlg('Calendrier', sConfirmDelImg, mtWarning,
            [mbYes, mbNo], [YesBtn, NoBtn])=mrYes then
    begin
      DeleteFile(HalfImgsList.GetItem(i).LocalCopy);
      HalfImgsList.Delete(i);
      ImageHalf.Picture:=nil;
      PMnuAddImg.Caption:= sPMnuAddImgCaption;
      if SettingsChanged then SaveSettings(cfgfilename);
    end;
  end;
end;

procedure TFCalendrier.PMnuMainPopup(Sender: TObject);
begin
  PMnuAddImg.visible:= false;
  PMnuDelImg.Visible:= false;
  PMnuCopy.Visible:= true;
  if PMnuMain.PopupComponent=PanImg then
  begin
    PMnuAddImg.visible:= true;
    PMnuDelImg.Visible:= ImageLoaded;
    PmnuCopy.visible:= False;
  end;

end;

procedure TFCalendrier.PMnuTrayPopup(Sender: TObject);
begin
  PTMnuRestore.Enabled:= (WindowState=wsMaximized) or (WindowState=wsMinimized);
  if PTMnuRestore.Enabled then PTMnuRestore.ImageIndex:=ixRestorE else PTMnuRestore.ImageIndex:=ixRestorD ;
  PTMnuMaximize.Enabled:= not (WindowState=wsMaximized);
  if PTMnuMaximize.Enabled then PTMnuMaximize.ImageIndex:=ixMaximizE else PTMnuMaximize.ImageIndex:=ixMaximizD;
  PTMnuIconize.Enabled:= not (WindowState=wsMinimized);
  if PTMnuIconize.Enabled then PTMnuIconize.ImageIndex:= ixIconizE else PTMnuIconize.ImageIndex:=ixIconizD;
end;

procedure TFCalendrier.PTMnuIconizeClick(Sender: TObject);
begin
  Application.Minimize;
end;

procedure TFCalendrier.PTMnuMaximizeClick(Sender: TObject);
begin
  WindowState:=wsMaximized;
  Visible:= true;
end;



procedure TFCalendrier.PTMnuRestoreClick(Sender: TObject);
begin
  iconized:= false;
  visible:= true;
  WindowState:=wsNormal;
 //Need to reload position as it can change during hide in taskbar process
  left:= PrevLeft;
  top:= PrevTop;
  Application.BringToFront;
end;

procedure TFCalendrier.SBAboutClick(Sender: TObject);
begin
  AboutBox.ShowModal;
end;

procedure TFCalendrier.SettingsOnChange(sender: TObject);
begin
  SettingsChanged:= true;
end;

procedure TFCalendrier.SBNextQClick(Sender: TObject);

begin
  if Half=1 then Half:= 2 else
  begin
    half:= 1;
    CurYear:= CurYear+1;
    UpdateCal(CurYear);
    Invalidate;
  end;
  showHalf(half);
  loadimage;
end;


procedure TFCalendrier.SBPrevQClick(Sender: TObject);
begin
  if Half=1 then
  begin
     Half:=2;
    CurYear:= CurYear-1;
    UpdateCal(CurYear);
    Invalidate;
  end else Half:= 1;
  showHalf(half);
  loadimage;
end;

procedure TFCalendrier.SBPrintClick(Sender: TObject);
begin
  // printing routine I prefer use a bitmap instead draw directly to the printer
  FPrintCal.Half:= half;
  FPrintCal.ShowModal;
end;


procedure TFCalendrier.SBQuitClick(Sender: TObject);
begin
  CanClose:= true;
  close();
end;

procedure TFCalendrier.SBSettingsClick(Sender: TObject);
begin
  Prefs.PanStatus.Caption:= OSVersion.VerDetail ;
  Prefs.CBStartwin.Checked:= Settings.startwin;
  Prefs.CBSaveSizPos.Checked:= Settings.savsizepos;
  Prefs.CBStartmini.Checked:= Settings.startmini;
  Prefs.CBMiniintray.Checked:= Settings.miniintray;
  Prefs.CBHideinTaskBar.Enabled:=(Settings.miniintray=true);
  Prefs.CBHideinTaskBar.Checked:= Settings.hideintaskbar;
  prefs.CBMoonPhases.checked:= Settings.savemoon;
  prefs.CBSaveVacs.checked:= Settings.savevacs;
  Prefs.CPcolback.Color:= Settings.colback;
  Prefs.CPcolsunday.Color:= Settings.colsunday;
  Prefs.CPColferie.Color:= Settings.colferie;
  Prefs.CPcolUser.Color:= Settings.coluser;
  Prefs.CPcolText.Color:= Settings.coltext;
  Prefs.CPcolvaca.Color:= Settings.colvaca;
  Prefs.CPcolvacb.Color:= Settings.colvacb;
  Prefs.CPcolvacc.Color:= Settings.colvacc;
  Prefs.CPcolvack.Color:= Settings.colvack;
  Prefs.CBTowns.Text:= Settings.town;
  // Search town in list instead use itemindex too prone to exception
  Prefs.CBTowns.ItemIndex:= Prefs.CBFind(Settings.town);
  Prefs.ELatitude.Text:= FloatToString(Settings.latitude, '.');
  Prefs.ELongitude.Text:= FloatToString(Settings.longitude, '.');
  Prefs.ETimeZone.Text:= FloattoString(Settings.timezone);
  if Prefs.ShowModal<>mrOK then exit;              // Pas OK ? on ne change rien
  Settings.startwin:= Prefs.CBStartwin.Checked;
  Settings.savsizepos:= Prefs.CBSaveSizPos.Checked;
  Settings.startmini:= Prefs.CBStartmini.Checked;
  Settings.miniintray:= Prefs.CBMiniintray.Checked;
  Settings.hideintaskbar:= Prefs.CBHideinTaskBar.Checked;
  Settings.savemoon:= prefs.CBMoonPhases.checked;
  Settings.savevacs:= prefs.CBSaveVacs.checked;
  Settings.colback:= Prefs.CPcolback.Color;
  Settings.colsunday:= Prefs.CPcolsunday.Color;
  Settings.colferie:= Prefs.CPColferie.Color;
  Settings.coluser:= Prefs.CPcolUser.Color;
  Settings.coltext:= Prefs.CPcolText.Color;
  Settings.colvaca:= Prefs.CPcolvaca.Color;
  Settings.colvacb:= Prefs.CPcolvacb.Color;
  Settings.colvacc:= Prefs.CPcolvacc.Color;
  Settings.colvack:= Prefs.CPcolvack.Color;
  Settings.townIndex:= Prefs.CBTowns.ItemIndex;
  Settings.town:= Prefs.CBTowns.Text;
  Settings.latitude:= StringToFloat(Prefs.ELatitude.text, '.');
  Settings.longitude:= StringToFloat(Prefs.ELongitude.text, '.');
  Settings.timezone:= StringToInt(Prefs.ETimeZone.Text);
  CBVA.CheckColor:= Settings.colvaca;
  CBVB.CheckColor:= Settings.colvacb;
  CBVC.CheckColor:= Settings.colvacc;
  CBVK.CheckColor:= Settings.colvack;
  // Towns list has changed
  if Prefs.TownsListChanged then
  begin
    Prefs.csvtowns.SaveToFile(CalAppDataPath+'fr_villes.csv');
  end;
  if SettingsChanged then
  begin
    SaveSettings(cfgfilename);
    Invalidate;
    LTodayDesc.Caption:= DayInfos(now) ;
    TrayCal.visible:= Settings.miniintray ;
    Canclose:= not Settings.miniintray ;
  end;
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
  s: String;
begin
  aCol:= 0;
  aRow:= 0;
  SGCur:= TStringGrid(Sender);
  GridNum := StrToInt(Copy(SgCur.Name, 3, 1));
  SGCur.MouseToCell(X, Y, aCol, aRow);
  if half= 1 then Month := ACol + 1 + 3 * (GridNum - 1)
  else Month:= ACol + 7 + 3 * (GridNum - 1) ;
  if (aRow<>curRow) or (aCol<>curCol) then
  begin
    curRow:= aRow;
    curCol:= aCol;
    try
      MyDate:= EncodeDate (CurYear, Month, aRow);
      //s:= FormatDateTime (DefaultFormatSettings.LongDateFormat, MyDate);
      s:= FormatDateTime ('dddd dd mmmm yyyy', myDate);
      s[1]:= UpCase(s[1]);
      SGCur.Hint:= s+LineEnding+DayInfos(MyDate);
      CurHint:= SGCur.Hint;
    except
      // Do nothing, wrong cell;
    end;
  end;
end;

function TFCalendrier.DayInfos(dDate: TDateTime): String;
var
  s, s1: string;
  i, doy: Integer;
  dtr, dts, dtsz : TDateTime;
  curDay: TDay;
begin
  doy:= DayOfTheYear(dDate);
  try
    curDay:= Days[doy-1];
  except
    exit;
  end;
  s:= curDay.sStDesc;
  if s='' then s:= curDay.sSaint;
  Result:= s;
  if curDay.bFerie then
  begin
    s1:= curDay.sFerie;
    if (s1<>s) then
    begin
      s:= curDay.sFeDesc;
      if s='' then s:= s1;
      Result:= Result+LineEnding+s;
    end;
  end;
  Result:= Result+LineEnding+Format(sDayWeekInfo, [doy, WeekOf(dDate)]);
  if curDay.bMoon then
  begin
    s:= Format(sMoonphase, [curDay.sMoonDesc, FormatDateTime ('hh'+TimeSepar+'mm', curDay.dMoon)]);
    Result:= Result+LineEnding+s;
  end;
  Suntime1.Sundate:= dDate;
  Suntime1.Latitude:= Settings.latitude;
  Suntime1.Longitude:= Settings.longitude;
  Suntime1.TimeZone:= Settings.TimeZone;
  dtr:= Suntime1.Sunrise;
  dtr:= IncMinute(dtr, 60*Int64(IsDST(dDate)));
  dts:= Suntime1.Sunset;
  dts:= IncMinute(dts, 60*Int64(IsDST(dDate)));
  s:= Format(sSunRiseAndSet,
               [Settings.town, FormatDateTime ('hh'+TimeSepar+'mm', dtr),
                               FormatDateTime ('hh'+TimeSepar+'mm', dts)]);
  Result:= Result+LineEnding+s;
  if curDay.bSeason then
  begin
    dtsz:= curDay.dSeason;
    dtsz:= IncMinute(dtsz, 60*Int64(IsDST(dDate)));
    s:= Format(sSeason, [curDay.sSeasonDesc, FormatDateTime ('hh'+TimeSepar+'mm', dtsz)]);
    Result:= Result+LineEnding+s
  end;
  if Curday.bHoliday then
  begin
    s:= curDay.sHoliday;
    s1:= '';
    for i:= 1 to length (s) do
    s1:= s1+s[i]+', ';
    s1:= StringReplace(s1, 'K,', 'Corse,', []);
    SetLength(s1, length(s1)-2); //remove trailing comma
    s:= sHolidayZone;
    if length(curDay.sHoliday)>1 then s:= s+'s';
    Result:= Result+LineEnding+s+' '+s1;
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
begin
  SGCur := TStringGrid(Sender);
  try
    GridNum := StrToInt(Copy(SgCur.Name, 3, 1));
    if half= 1 then Month := ACol + 1 + 3 * (GridNum - 1)
    else Month:= ACol + 7 + 3 * (GridNum - 1) ;
    SelDate:= EncodeDate(CurYear, Month, ARow);
    //s:= FormatDateTime (DefaultFormatSettings.LongDateFormat, SelDate);
    s:= FormatDateTime ('dddd dd mmmm yyyy', SelDate);
    s[1]:= UpCase(s[1]);
    s:=s+LineEnding+DayInfos(SelDate);
    LSelDay.Caption:=  s;
    CanSelect:= true;
  except
    // We are in a blank cell, cannot be selected and avoid focus rectangle
    CanSelect:= false;
  end;

end;



procedure TFCalendrier.CBXClick(Sender: TObject);
begin
  SettingsChanged:= true;
  Invalidate;
end;

procedure TFCalendrier.EYearChange(Sender: TObject);
var
  cyr: Integer;
begin
  if length(EYear.Text)<>4 then
  begin
    Timer2.Enabled:=true;       // On remettra la bonne année un peu plus tard
    exit;
  end;
  try
    Timer2.Enabled:=false;
    cyr:= StrToInt(EYear.Text);
    UpdateCal(cyr);
    CurYear:= cyr;
    loadimage;
    Invalidate;
  except

  end;
end;


procedure TFCalendrier.SGDrawCell(Sender: TObject; aCol, aRow: integer;
  aRect: TRect; aState: TGridDrawState);
var
  X, Y: integer;
  S, s1: string;
  w: integer;
  SGCur: TStringGrid;
  GridNum: word;
  Month: word;
  MyDate: TDateTime;
  DefBrushColor: TColor;
  quarter: integer;
  Count: integer;
  max: integer;
  imgNum: integer;
  curDay: TDay;
  numDay: Integer;
begin;
  try       // During compilation+execution in IDE, avoid exception errors (to be confirmed)
    SGCur := TStringGrid(Sender);
    GridNum := StrToInt(Copy(SgCur.Name, 3, 1));
    if half= 1 then Month := ACol + 1 + 3 * (GridNum - 1)
    else Month:= ACol + 7 + 3 * (GridNum - 1) ;
    try
      s:= DefaultFormatSettings.LongMonthNames[Month];
      s[1]:= Upcase(s[1]);
    except
    end;
    // On centre les mois
    if ARow = 0 then
    begin
      SGCur.Canvas.Font := PanStatus.Font;
      SGCur.Canvas.Font.Style:= [fsBold];
      w := SGCur.Canvas.TextWidth(s);
      x := aRect.Left + (aRect.Right - aRect.Left - w) div 2;
      y := 1 + aRect.Top;
      SGCur.Canvas.Brush.Color := clBtnFace;
      SGCur.Canvas.Rectangle(aRect.Left, aRect.Top, aRect.Right, aRect.Bottom);
      SGCur.Canvas.TextOut(x, y, s);
      SGCur.Canvas.Font := SGCur.Font;
      exit;
    end;
    // Get current day
    x := 2 + aRect.Left;
    y := 1 + aRect.Top;
    if half= 1 then  Quarter := StrToInt(SGCur.Name[3])
    else Quarter := StrToInt(SGCur.Name[3])+2;
    if aRow > 0 then
    begin
      Count:= aMonths[(acol + 1) + (quarter - 1) * 3];
      max:= aMonths[(acol + 2) + (quarter - 1) * 3];
      numDay:= Count+arow-1;
      try
        curDay:= Days[numDay];
      except
        exit;
      end;
      s := IntToStr(curDay.iDay)+ ' ' + UpCase(curDay.sday[1]);
      s1 := curDay.sSaint;
      // default color
      SGCur.Canvas.Brush.Color := Settings.colback;
      if numDay<max then
      begin
        if (curDay.bSunday) then
        begin
          SGCur.Canvas.Brush.Color := Settings.colsunday;
         end;
        if (curDay.bferie) then
        begin
          SGCur.Canvas.Brush.Color := Settings.colferie;
          s1 := curDay.sferie;
        end;
        SGCur.Canvas.FillRect(Rect(aRect.Left,aRect.Top,aRect.Right,aRect.Bottom));
        SGCur.Canvas.Font.Color:= Settings.coltext ;
        SGCur.Canvas.TextOut(x, y, s + ' ' + s1);
        if curDay.bHoliday then
        begin
          s1:= curDay.sHoliday;
          DefBrushColor:= Brush.Color;  // pour remettre à la couleur d'origine
          SGCur.Canvas.Pen.Style:=psClear;
          SGCur.Canvas.Brush.Style:=bsSolid;
          if (CBVA.Checked) and (Pos('A', s1) > 0) then
          begin
            SGCur.Canvas.Brush.Color:= Settings.colvaca;
            SGCur.Canvas.Rectangle(aRect.Right-9,aRect.Top,aRect.Right-6,aRect.Bottom);
          end;
          if (CBVB.Checked) and (Pos('B', s1) > 0) then
          begin
            SGCur.Canvas.Brush.Color:= Settings.colvacb;
            SGCur.Canvas.Rectangle(aRect.Right-6,aRect.Top,aRect.Right-3,aRect.Bottom);
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
        // Outline current day
        try
          MyDate:= EncodeDate(CurYear, Month, ARow);
          if MyDate=trunc(now) then
          begin
            SGCur.Canvas.brush.style:= bsClear;
            SGCur.Canvas.Pen.Color:= clRed;
            SGCur.Canvas.Rectangle(aRect.Left, aRect.Top, aRect.Right-1, aRect.Bottom-1);
            SGCur.Canvas.brush.style:= bsSolid;
          end;
        except
         // Wrong cell pass
        end;
        // Affiche les phases de la lune
        if (CBLune.Checked) and (curDay.bMoon) then
        begin
          aRect.Top:= aRect.Top+(aRect.Bottom-aRect.Top-12) div 2;    // L'image va faire 12 px
          aRect.Bottom:= aRect.Top+ 12;
          aRect.Right:= aRect.Right-2;                                 // Espace de 2 px à droite
          aRect.Left:= aRect.Right-12;
          ImgNum:= curDay.iMoonIndex;
          Moonphases1.MoonImages.StretchDraw(SGCur.Canvas, ImgNum, aRect);
        end;
      end else
      begin

      end;
    end;
  except

  end;
end;

procedure TFCalendrier.Timer1Timer(Sender: TObject);
var
 s: String;
 CurDay: Integer;
begin
  //s:= FormatDateTime (DefaultFormatSettings.LongDateFormat+' - hh'+TimeSepar+'mm'+TimeSepar+'ss', now);
  s:= FormatDateTime ('dddd dd mmmm yyyy - hh'+TimeSepar+'mm'+TimeSepar+'ss', now);
  s[1]:= UpCase(s[1]);
  LTodayTime.Caption:= s;
  Curday:= DayofTheYear(now);
  if Curday>Today then
  begin
    s:= DayInfos(now);
    LTodayDesc.Caption:= s;;
    Today:=Curday;
  end;
end;

procedure TFCalendrier.Timer2Timer(Sender: TObject);
begin
  Eyear.text:= InttoStr(curyear);
  Timer2.Enabled:= false;
end;

procedure TFCalendrier.TrayCalClick(Sender: TObject);
begin
  if Iconized or (WindowState=wsMinimized) then PTMnuRestoreClick(Sender) else PTMnuIconizeClick(Sender);

end;

procedure TFCalendrier.UpdateCal(Annee: word);
var
  s : string;
  BegYear: TDateTime;
  CYear, CMonth, CDay: word;
  DaysCnt: word;
  i, j: integer;
  Currentday: TDateTime;
  DepDay, MerDay: TDateTime;
  DOY: Integer;
  vacbeg, vacend: TDateTime;
  dt: TDateTime;
  dSpr, dSum, DAut, dWin: TDateTime;
begin
  // During compilation+execution in IDE, avoid exception errors (to be confirmed)
  try
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
    EYear.OnChange:= nil;
    Caption := sMainCaption +' '+ IntToStr(Annee);
    EYear.Text := IntToStr(Annee);
    Application.Title := Caption;
    CBLune.SetFocus;
    EYear.OnChange:= @EYearChange;
    // Ecrit les jours
    BegYear := EncodeDate(Annee, 1, 1);
    // reset array
    setlength(Days, 0);
    setlength(Days, DaysCnt);
    j := 0;
    for i := 1 to DaysCnt do
    begin
      CurrentDay:= BegYear + i - 1;
      DecodeDate(CurrentDay, CYear, CMonth, CDay);
      if (DaysCnt = 365) and (j = 58) then  Inc(j); // on saute le 29 février !
      Days[i - 1].index := i;
      Days[i - 1].ddate := CurrentDay;
      Days[i - 1].sday := DefaultFormatSettings.ShortDayNames[DayOfWeek(CurrentDay)];
      Days[i - 1].iDay := CDay;
      Days[i - 1].iMonth := CMonth;
      Days[i - 1].iQuarter := ((cMonth - 1) div 3) + 1;
      Days[i - 1].sSaint := csvsaints.Cells[1, j];
      Days[i - 1].sStDesc:= csvsaints.Cells[2, j];;
      //sDisplay : String;
      if (DayOfWeek(CurrentDay)= 1) then Days[i-1].bSunday := True
      else Days[i - 1].bSunday := False;
      Inc(j);
    end;
    Easter1.EasterYear:= Annee;;
    DepDay:= GetDeportes(Annee);
    MerDay:= GetFetMeres(Annee);
    // reLoad and Update csvFerie
    csvferies.CSVText:= Copy(FeriesTxt, 1, length(FeriesTxt));
    csvferies.CSVText:= StringReplace(csvferies.CSVText, 'YYYY', InttoStr(Annee), [rfReplaceAll]);
    csvferies.CSVText:= StringReplace(csvferies.CSVText, 'DIPAQ', TimeDateToString(Easter1.Easterdate, 'dd/mm/yyyy'), []);
    csvferies.CSVText:= StringReplace(csvferies.CSVText, 'LUPAQ', TimeDateToString(Easter1.EasterMondaydate, 'dd/mm/yyyy'), []);
    csvferies.CSVText:= StringReplace(csvferies.CSVText, 'JEASC', TimeDateToString(Easter1.Ascensdate, 'dd/mm/yyyy'), [rfIgnoreCase]);
    csvferies.CSVText:= StringReplace(csvferies.CSVText, 'DIPEN', TimeDateToString(Easter1.Pentecdate, 'dd/mm/yyyy'), [rfIgnoreCase]);
    csvferies.CSVText:= StringReplace(csvferies.CSVText, 'SOUDEP', TimeDateToString(DepDay, 'dd/mm/yyyy'), [rfIgnoreCase]);
    csvferies.CSVText:= StringReplace(csvferies.CSVText, 'FETMER', TimeDateToString(MerDay, 'dd/mm/yyyy'), [rfIgnoreCase]);
    for i:= 0 to csvferies.RowCount-1 do
    begin
      DOY:= Trunc(StringToTimeDate(csvferies.Cells[0,i], 'dd/mm/yyyy')-BegYear);
      if annee >= StrToInt(csvferies.Cells[3,i]) then
      begin
        Days[DOY].sFerie := csvferies.Cells[1,i];
        if length(csvferies.Cells[2,i])>0 then Days[DOY].sFeDesc:= csvferies.Cells[2,i];
        Days[DOY].bFerie:= true;  ;
      end;
    end;
    // Update holidays
    for i:= 0 to csvvacs.RowCount-1 do
    begin
      vacbeg:= StringToTimeDate(csvvacs.Cells[0,i], 'dd/mm/yyyy'); //StrToDate(csvvacs.cells[0,i]);
      vacend:= StringToTimeDate(csvvacs.Cells[1,i], 'dd/mm/yyyy');  //StrToDate(csvvacs.cells[1,i]);
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
    Moonphases1.Moonyear:= Annee;
    Moonphases1.Timezone:=  Settings.TimeZone; // Here timezone is in minutes
    for i:= 0 to length(Moonphases1.Moondays)-1 do
    begin
      try
        DOY:= trunc( Moonphases1.Moondays[i].MDays-BegYear);
        if (DOY >=0) and (DOY<length(days)-1) then
        begin
          Days[DOY].bMoon:= true;
          dt:= Moonphases1.Moondays[i].MDays;
          dt:= IncMinute(dt, 60*Integer(IsDST(dt)));
          Days[DOY].dMoon:= dt;
          Days[DOY].iMoonIndex:= Moonphases1.Moondays[i].MIndex;
          Days[DOY].sMoonDesc:= MoonDescs[Days[DOY].iMoonIndex];
        end;
      except

      end;
    end;
    // Saisons
    Seasons1.Seasyear:= Annee;
    Seasons1.Timezone:= Settings.TimeZone;
    dSpr:= Seasons1.SpringDate; //GetSeasonDate(Annee, 0);
    dSpr:= IncMinute(dSpr, 60*Int64(IsDST(dSpr)));
    DOY:= trunc(dSpr-BegYear);
    Days[DOY].bSeason:= true;
    Days[DOY].dSeason:= dSpr;
    Days[DOY].sSeasonDesc:= sSeasonSpring;
    //s:= Days[DOY].sSeasonDesc+' : '+FormatDateTime (DefaultFormatSettings.LongDateFormat+' - hh'+TimeSepar+'mm', Days[DOY].dSeason)+LineEnding;
    s:= Days[DOY].sSeasonDesc+' : '+FormatDateTime ('dddd dd mmmm yyyy - hh'+TimeSepar+'mm', Days[DOY].dSeason)+LineEnding;
    dSum:= Seasons1.SummerDate; //GetSeasonDate(Annee, 1);
    dSum:= IncMinute(dSum, 60*Int64(IsDST(dSum)));
    DOY:= trunc(dSum-BegYear);
    Days[DOY].bSeason:= true;
    Days[DOY].dSeason:= dSum;
    Days[DOY].sSeasonDesc:= sSeasonSummer;
    //LSeasons1.Caption:=s+Days[DOY].sSeasonDesc+' : '+FormatDateTime (DefaultFormatSettings.LongDateFormat+'
    LSeasons1.Caption:=s+Days[DOY].sSeasonDesc+' : '+FormatDateTime ('dddd dd mmmm yyyy - hh'+TimeSepar+'mm', dSum);
    dAut:= Seasons1.AutumnDate; //GetSeasonDate(Annee, 2);
    dAut:= IncMinute(dAut, 60*Int64(IsDST(dAut)));
    DOY:= trunc(dAut-BegYear);
    Days[DOY].bSeason:= true;
    Days[DOY].dSeason:= dAut;
    Days[DOY].sSeasonDesc:= sSeasonAutumn;
    //s:= Days[DOY].sSeasonDesc+' : '+FormatDateTime (DefaultFormatSettings.LongDateFormat+' - hh'+TimeSepar+'mm', dAut)+LineEnding;
    s:= Days[DOY].sSeasonDesc+' : '+FormatDateTime ('dddd dd mmmm yyyy - hh'+TimeSepar+'mm', dAut)+LineEnding;
    dWin:= Seasons1.WinterDate;
    dWin:= IncMinute(dWin, 60*Int64(IsDST(dWin)));
    DOY:= trunc(dWin-BegYear);
    Days[DOY].bSeason:= true;
    Days[DOY].dSeason:= dWin;
    Days[DOY].sSeasonDesc:= sSeasonWinter;
    //LSeasons2.Caption:=s+Days[DOY].sSeasonDesc+' : '+FormatDateTime (DefaultFormatSettings.LongDateFormat+' - hh'+TimeSepar+'mm', dWin);
    LSeasons2.Caption:=s+Days[DOY].sSeasonDesc+' : '+FormatDateTime ('dddd dd mmmm yyyy - hh'+TimeSepar+'mm', dWin);
    Application.ProcessMessages;
    SG1.OnDrawCell:= @SGDrawCell ;
    SG2.OnDrawCell:= @SGDrawCell ;
    Application.ProcessMessages;
    Timer1.enabled:= true;
  except

  end;
end;

procedure TFCalendrier.ModLangue;
var
  i, j: integer;
  cmp: TControl;
  s: String;
begin
  With LangFile do
  begin
    s:= ReadString(LangStr, 'MoonDescs', Moonphs);
    MoonDescs:= s.Split(',');
    sMoonphase:= ReadString(LangStr, 'sMoonphase', '%s à %s');
    sSeason:= sMoonphase;
    sHolidayZone:= ReadString(LangStr, 'sHolidayZone', 'Vacances zone');
    CancelBtn:= ReadString(LangStr, 'CancelBtn', 'Annuler');
    YesBtn:= ReadString(LangStr, 'YesBtn', 'Oui');
    NoBtn:= ReadString(LangStr, 'NoBtn', 'Non');
    CBVA.Caption:= ReadString(LangStr, 'CBVA.Caption', CBVA.Caption);
    CBVB.Caption:= ReadString(LangStr, 'CBVB.Caption', CBVB.Caption);
    CBVC.Caption:= ReadString(LangStr, 'CBVC.Caption', CBVC.Caption);
    CBVK.Caption:= ReadString(LangStr, 'CBVK.Caption', CBVK.Caption);
    CBLune.Caption:= ReadString(LangStr, 'CBLune.Caption', CBLune.Caption);
    SBSettings.Hint:= ReadString(LangStr, 'SBSettings.Hint', SBSettings.Hint);
    SBAbout.Hint:= ReadString(LangStr, 'SBAbout.Hint', SBAbout.Hint);
    SBQuit.Hint:= ReadString(LangStr, 'SBQuit.Hint', SBQuit.Hint);
    SBPrevQ.Hint:= ReadString(LangStr, 'SBPrevQ.Hint', SBPrevQ.Hint);
    SBNextQ.Hint:= ReadString(LangStr, 'SBNextQ.Hint', SBNextQ.Hint);
    CBLune.Hint:= ReadString(LangStr, 'CBLune.Hint', CBLune.Hint);
    CBVA.Hint:= ReadString(LangStr, 'CBVA.Hint', CBVA.Hint);
    CBVB.Hint:= ReadString(LangStr, 'CBVB.Hint', CBVB.Hint);
    CBVC.Hint:= ReadString(LangStr, 'CBVC.Hint', CBVC.Hint);
    CBVK.Hint:= ReadString(LangStr, 'CBVK.Hint', CBVK.Hint);
    sPMnuAddImgCaption:= ReadString(LangStr, 'sPMnuAddImgCaption', 'Ajouter une image');
    sPMnuModImgCaption:= ReadString(LangStr, 'sPMnuModImgCaption', 'Modifier l''image');
    PMnuDelImg.Caption:= ReadString(LangStr, 'PMnuDelImg.Caption', PMnuDelImg.Caption);
    PMnuSettings.Caption:= ReadString(LangStr, 'PMnuSettings.Caption', PMnuSettings.Caption);
    PMnuAbout.Caption:= ReadString(LangStr, 'PMnuAbout.Caption', PMnuAbout.Caption);
    PMnuQuit.Caption:= ReadString(LangStr, 'PMnuQuit.Caption', PMnuQuit.Caption);
    PTMnuRestore.Caption:= ReadString(LangStr, 'PTMnuRestore.Caption', PTMnuRestore.Caption);
    PTMnuMaximize.Caption:= ReadString(LangStr, 'PTMnuMaximize.Caption', PTMnuMaximize.Caption);
    PTMnuIconize.Caption:= ReadString(LangStr, 'PTMnuIconize.Caption', PTMnuIconize.Caption);;
    PTMnuSettings.Caption:= PMnuSettings.Caption;
    PTMnuAbout.Caption:=PMnuAbout.Caption;
    PTMnuQuit.Caption:= PMnuQuit.Caption;
    sDayWeekInfo:= ReadString(LangStr, 'sDayWeekInfo', '%de jour, %de semaine');
    sMoonphase:= ReadString(LangStr, 'sMoonphase','%s à %s');
    sSunRiseAndSet:= ReadString(LangStr, 'sSunRiseAndSet','Lever et coucher du soleil à %s : %s - %s');
    sSeasonSpring:= ReadString(LangStr, 'sSeasonSpring', 'Printemps');
    sSeasonSummer:= ReadString(LangStr, 'sSeasonSummer', 'Eté');
    sSeasonAutumn:= ReadString(LangStr, 'sSeasonAutumn', 'Automne');
    sSeasonWinter:= ReadString(LangStr, 'sSeasonWinter', 'Hiver');
    TabHalf1.Caption:= ReadString(LangStr, 'TabHalf1.Caption', TabHalf1.Caption);
    TabHalf2.Caption:= ReadString(LangStr, 'TabHalf2.Caption', TabHalf2.Caption);
    PanToday.Caption:= ReadString(LangStr, 'PanToday.Caption', PanToday.Caption);
    PanSelDay.Caption:= ReadString(LangStr, 'PanSelDay.Caption', PanSelDay.Caption);
    PanSeasons.Caption:= ReadString(LangStr, 'PanSeasons.Caption', PanSeasons.Caption);
    sNoLongerChkUpdates:= ReadString(LangStr, 'NoLongerChkUpdates', 'Ne plus rechercher les mises à jour');
    sUse64bitcaption:=ReadString(LangStr, 'use64bitcaption', 'Utilisez la version 64 bits de ce programme');
    sConfirmDelImg:=ReadString(LangStr, 'sConfirmDelImg', 'Voulez-vous supprimer cette image ?');
    sMainCaption:= ReadString(LangStr, 'sMainCaption', 'Calendrier');
    LImageInsert.Caption:= ReadString(LangStr, 'LImageInsert.Caption', LImageInsert.Caption);
    sFirst:= ReadString(LangStr, 'sFirst', '1er');
    sSecond:= ReadString(LangStr, 'sSecond', '2ème');
    sPrintHalf:= ReadString(LangStr, 'sPrintHalf', '%s semestre %d');

    // About
    AboutBox.LProductName.Caption:= ReadString(LangStr, 'AboutBox.LProductName.Caption', 'Calendrier universel');
    if not AboutBox.checked then AboutBox.LUpdate.Caption:=ReadString(LangStr,'AboutBox.LUpdate.Caption',AboutBox.LUpdate.Caption) else
    begin
      if AboutBox.NewVersion then AboutBox.LUpdate.Caption:= Format(AboutBox.sUpdateAvailable, [AboutBox.LastVersion])
      else AboutBox.LUpdate.Caption:= AboutBox.sNoUpdateAvailable;
    end;
    AboutBox.sLastUpdateSearch:=ReadString(LangStr,'AboutBox.LastUpdateSearch','Dernière recherche de mise à jour');
    AboutBox.sUpdateAvailable:=ReadString(LangStr,'AboutBox.UpdateAvailable','Nouvelle version %s disponible; Cliquer pour la télécharger');
    AboutBox.sNoUpdateAvailable:=ReadString(LangStr,'AboutBox.NoUpdateAvailable','Le Calendrier est à jour');
    Aboutbox.Caption:=ReadString(LangStr,'Aboutbox.Caption','A propos du Calendrier');
    AboutBox.UrlProgSite:= sUrlProgSite+ ReadString(LangStr,'AboutBox.UrlProgSite','Accueil');
    AboutBox.LWebSite.Caption:= ReadString(LangStr,'AboutBox.LWebSite.Caption', AboutBox.LWebSite.Caption);
    AboutBox.LProgPage.Caption:= ReadString(LangStr,'AboutBox.LProgPage.Caption', AboutBox.LProgPage.Caption);      ;
    AboutBox.LSourceCode.Caption:= ReadString(LangStr,'AboutBox.LSourceCode.Caption', AboutBox.LSourceCode.Caption);
    AboutBox.LSourceCode.Caption:= ReadString(LangStr,'AboutBox.LSourceCode.Caption', 'Page Web du code source');

    // Settings
    // Enumerate controls to change captions
    for i:=0 to Prefs.ControlCount-1 do
    begin
      cmp:= Prefs.Controls[i];
      Prefs.Controls[i].Caption:= ReadString(LangStr, 'Prefs.'+cmp.name+'.Caption', cmp.caption);
      for j:= 0 to TTitlePanel(cmp).ControlCount-1 do
      begin
        TTitlePanel(Prefs.Controls[i]).Controls[j].Caption:= ReadString(LangStr,
                'Prefs.'+ TTitlePanel(cmp).Controls[j].Name+'.Caption',
                TTitlePanel(cmp).Controls[j].Caption);
      end;
    end;
    {Prefs.PanColors.Caption:= ReadString(LangStr, 'Prefs.PanColors.Caption', Prefs.PanColors.Caption);
    Prefs.LColUser.Caption:= ReadString(LangStr, 'Prefs.LColUser.Caption', Prefs.LColUser.Caption);
    Prefs.LColSund.Caption := ReadString(LangStr, 'Prefs.LColSund.Caption', Prefs.LColSund.Caption);
    Prefs.LColFerie.Caption := ReadString(LangStr, 'Prefs.LColFerie.Caption', Prefs.LColFerie.Caption);
    Prefs.LColZa.Caption:= ReadString(LangStr, 'Prefs.LColZa.Caption', Prefs.LColZa.Caption);
    Prefs.LColZb.Caption:= ReadString(LangStr, 'Prefs.LColZb.Caption', Prefs.LColZb.Caption);
    Prefs.LColZc.Caption:= ReadString(LangStr, 'Prefs.LColZc.Caption', Prefs.LColZc.Caption);
    Prefs.LColZk.Caption:= ReadString(LangStr, 'Prefs.LColZk.Caption', Prefs.LColZk.Caption);
    Prefs.PanCoords.Caption:= ReadString(LangStr, 'Prefs.PanCoords.Caption', Prefs.PanCoords.Caption);
    Prefs.LTown.Caption:= ReadString(LangStr, 'Prefs.LTown.Caption', Prefs.LTown.Caption);
    Prefs.LLatitude.Caption:= ReadString(LangStr, 'Prefs.LLatitude.Caption', Prefs.LLatitude.Caption);
    Prefs.LLongitude.Caption:= ReadString(LangStr, 'Prefs.LLongitude.Caption', Prefs.LLongitude.Caption);
    Prefs.LTimezone.Caption:= ReadString(LangStr, 'Prefs.LTimezone.Caption', Prefs.LTimezone.Caption);
    Prefs.PanSystem.Caption:= ReadString(LangStr, 'Prefs.PanSystem.Caption', Prefs.PanSystem.Caption);
    Prefs.CBStartwin.Caption:= ReadString(LangStr, 'Prefs.CBStartwin.Caption', Prefs.CBStartwin.Caption);
    Prefs.CBStartmini.Caption:= ReadString(LangStr, 'Prefs.CBStartmini.Caption', Prefs.CBStartmini.Caption);
    Prefs.CBMiniintray.Caption:= ReadString(LangStr, 'Prefs.CBMiniintray.Caption', Prefs.CBMiniintray.Caption);
    Prefs.CBHideinTaskBar.Caption:= ReadString(LangStr, 'Prefs.CBHideinTaskBar.Caption', Prefs.CBHideinTaskBar.Caption);
    Prefs.CBSaveSizPos.Caption:= ReadString(LangStr, 'Prefs.CBSaveSizPos.Caption', Prefs.CBSaveSizPos.Caption);
    Prefs.CBMoonPhases.Caption:= ReadString(LangStr, 'Prefs.CBMoonPhases.Caption', Prefs.CBMoonPhases.Caption);
    Prefs.CBSaveVacs.Caption:= ReadString(LangStr, 'Prefs.CBSaveVacs.Caption', Prefs.CBSaveVacs.Caption);
    Prefs.CBNoChkUpdate.Caption:= ReadString(LangStr, 'Prefs.CBNoChkUpdate.Caption', Prefs.CBNoChkUpdate.Caption); }
    Prefs.SBEditTowns.Hint:= ReadString(LangStr, 'Prefs.SBEditTowns.Hint', Prefs.SBEditTowns.Hint);
    Prefs.BtnCancel.Caption:= CancelBtn;
    Prefs.Caption:= sMainCaption+ ' - '+PMnuSettings.Caption;

    FImgResiz.Caption:= sMainCaption+' - '+ReadString(LangStr, 'sFImgResiz.Caption', 'Choix d''une image');
    FImgResiz.BtnCancel.Caption:= CancelBtn;
    FImgResiz.LInfos.Caption:= ReadString(LangStr, 'FImgResiz.LInfos.Caption', FImgResiz.LInfos.Caption);
    FImgResiz.OPD1.Title:= ReadString(LangStr, 'FImgResiz.OPD1.Title', FImgResiz.OPD1.Title);

    FTowns.Caption:= sMainCaption;
    FTowns.BtnAdd.Caption:= ReadString(LangStr, 'FTowns.BtnAdd.Caption', FTowns.BtnAdd.Caption);
    FTowns.BtnDelete.Caption:= ReadString(LangStr, 'FTowns.BtnDelete.Caption', FTowns.BtnDelete.Caption);
    FTowns.BtnCancel.Caption:= CancelBtn;
    FTowns.PanCoords.Caption:= ReadString(LangStr, 'FTowns.PanCoords.Caption', FTowns.PanCoords.Caption);
    FTowns.sConfirmDelTown:= ReadString(LangStr, 'FTowns.sConfirmDelTown', 'Voulez-vous supprimer');
    FTowns.LTown.Caption:= Prefs.LTown.Caption;
    FTowns.LTimezone.Caption:= Prefs.LTimezone.Caption;


  end;
end;

end.
