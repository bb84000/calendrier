unit calsettings;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
  laz2_DOM, lazbbutils, lazbbcontrols, csvdocument;

type
    TTown = record
    name: string;
    depart: string;
    latitude: double;
    longitude: double;
    timezone: integer;
  end;

  {Settings file management }
  { We use array properties to avoid quasi duplicates in procedures}

  TSettings = class
    private
      Parent: TObject;
      FOnChange: TNotifyEvent;
      FOnStateChange: TNotifyEvent;
      fSysStates: array[0..5]of Boolean; //startwin, savsizepos, startmini, miniintray, hideintaskbar: Boolean;
      fsaveMoon: Boolean;
      fsaveVacs: Boolean;
      fwstate: String;
      fnochknewver: Boolean;
      flastupdchk: TDateTime;
      fVersion: String;
      flastversion: String;
      flangstr: String;
      fColferie: Tcolor;
      ftown: String;
      ftownIndex: Integer;
      fTimezone: Integer;
      fDaysColors: array [0..4] of TColor;
      fVacsColors: array [0..3] of TColor;
      fChkBoxs: array [0..4] of Boolean;
      fCoords: array [0..1] of Double;
      procedure setVersion(value: String);
      procedure setWstate(value: string);
      procedure setSaveMoon(value: boolean);
      procedure setSavevacs(value: Boolean);
      function GetSysState(Index: Integer): Boolean;
      procedure SetSysState(Index: Integer; value: Boolean);
      function GetDaysColor(Index: Integer): TColor;
      procedure SetDaysColor(Index: Integer; Value: Tcolor);
      function GetVacsColor(Index: Integer): TColor;
      procedure SetVacsColor(Index: Integer; Value: Tcolor);
      function GetChkBox (Index: Integer): Boolean;
      procedure SetChkBox (Index: Integer; Value: Boolean);
      function GetCoord (Index: Integer): Double;
      procedure SetCoord (Index: Integer; Value: Double);
      procedure setTimezone (Value: Integer);
      procedure setTown(value: String);
      procedure setTownIndex(value: Integer);
      procedure setLastupdchk(value: TDateTime);
      procedure setNochknewver(value: Boolean);
      procedure setLastversion(value: string);
      procedure setLangstr(value: String);
    public

      constructor Create (Sender: TObject); overload;
      function SaveToXMLnode(iNode: TDOMNode): Boolean;
      function ReadXMLNode(iNode: TDOMNode): Boolean;
    published
      property OnChange: TNotifyEvent read FOnChange write FOnChange;
      property OnStateChange: TNotifyEvent read FOnStateChange write FOnStateChange;
      property startwin: Boolean index 0 read GetSysState write SetSysState;
      property savsizepos: Boolean index 1 read GetSysState write SetSysState;
      property startmini: Boolean index 2 read GetSysState write SetSysState;
      Property miniintray: Boolean index 3 read GetSysState write SetSysState;
      property hideintaskbar : Boolean index 4 read GetSysState write SetSysState;
      property savemoon: Boolean read fsaveMoon write setSaveMoon;
      property savevacs: boolean read fsaveVacs write setSavevacs;
      property wstate: String read fwstate write setWstate;
      property nochknewver: Boolean read fnochknewver write setNochknewver;
      property lastupdchk: TDateTime read flastupdchk write setLastupdchk;
      property version: String read fversion write setVersion;
      property lastversion: String read flastversion write setLastversion;
      property langstr: String read flangstr write setLangstr;
      property town: String read ftown write setTown;
      property townIndex: Integer read ftownIndex write setTownIndex;
      property timezone: integer read fTimezone write setTimezone;
      property latitude: Double index 0 read GetCoord write SetCoord;
      property longitude: Double index 1 read GetCoord write SetCoord;
      property colback: TColor index 0 read GetDaysColor write SetDaysColor;
      property colsunday: Tcolor index 1 read GetDaysColor write SetDaysColor;
      property colferie: TColor index 2 read GetDaysColor write SetDaysColor;
      property coluser: TColor index 3 read GetDaysColor write SetDaysColor;
      property coltext: Tcolor index 4 read GetDaysColor write SetDaysColor;
      property colvaca: Tcolor index 0 read GetVacsColor write SetVacsColor;
      property colvacb: TColor index 1 read GetVacsColor write SetVacsColor;
      property colvacc: Tcolor index 2 read GetVacsColor write SetVacsColor;
      property colvack: TColor index 3 read GetVacsColor write SetVacsColor;
      property cbmoon: Boolean index 0 read GetChkBox write SetChkBox;
      property cbvaca: Boolean index 1 read GetChkBox write SetChkBox;
      property cbvacb: Boolean index 2 read GetChkBox write SetChkBox;
      property cbvacc: Boolean index 3 read GetChkBox write SetChkBox;
      property cbvack: Boolean index 4 read GetChkBox write SetChkBox;
    end;

  {Half year images }
  TChampsCompare = (cdcNone, cdcYear, cdcHalf);
  //TSortDirections = (ascend, descend);

  PFichier = ^TFichier;
  TFichier = Record
    Index: Integer;
    Name: String;
    Path: String;
    LocalCopy: String;
    Year: Integer;
    Half: Integer;
  end;

  TFichierList = class(TList)
  private
    FOnChange: TNotifyEvent;
    FSortType: TChampsCompare;
  public
    procedure DoSort;
    procedure AddFile(Fichier : TFichier);
    procedure Delete (const i : Integer);
    procedure ModifyFile (const i: integer; Fichier : TFichier);
    procedure ModifyField (const i: integer; field: string; value: variant);
    function FindYearAndHalf(yr, hf: Integer): Integer;
    procedure Reset;
    function GetItem(const i: Integer): TFichier;
    function ReadXMLNode(iNode: TDOMNode): Boolean;
    function SaveToXMLnode(iNode: TDOMNode): Boolean;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    Property SortType : TChampsCompare read FSortType write FSortType default cdcNone;

  end;





  { TPrefs preferences dialog}

  TPrefs = class(TForm)
    BtnOK: TButton;
    BtnCancel: TButton;
    CBMiniintray: TCheckBox;
    CBMoonPhases: TCheckBox;
    CBNoChkUpdate: TCheckBox;
    CBSaveSizPos: TCheckBox;
    CBHideinTaskBar: TCheckBox;
    CBSaveVacs: TCheckBox;
    CBStartmini: TCheckBox;
    CBStartwin: TCheckBox;
    CPcolback: TColorPicker;
    CPcolText: TColorPicker;
    CPcolsunday: TColorPicker;
    CPColferie: TColorPicker;
    CPcolvack: TColorPicker;
    CPcolvacc: TColorPicker;
    CPcolvacb: TColorPicker;
    CPcoluser: TColorPicker;
    CBTowns: TComboBox;
    CPcolvaca: TColorPicker;
    ELatitude: TEdit;
    EEOlon: TEdit;
    ETimeZone: TEdit;
    EDegLat: TEdit;
    EMinLat: TEdit;
    ESecLat: TEdit;
    ENSLat: TEdit;
    ELongitude: TEdit;
    EDeglon: TEdit;
    EMinLon: TEdit;
    ESeclon: TEdit;
    LColBack: TLabel;
    LColText: TLabel;
    LLatitude: TLabel;
    Llatdeg: TLabel;
    LLatmin: TLabel;
    Llatsec: TLabel;
    LLongitude: TLabel;
    Llondeg: TLabel;
    Llonmin: TLabel;
    Llonsec: TLabel;
    LTown: TLabel;
    LTimezone: TLabel;
    LColZk: TLabel;
    LColZc: TLabel;
    LColZb: TLabel;
    LColUser: TLabel;
    LColSund: TLabel;
    LColFerie: TLabel;
    LColZa: TLabel;
    PanCoords: TTitlePanel;
    PanButtons: TPanel;
    PanStatus: TPanel;
    PanColors: TTitlePanel;
    PanSystem: TTitlePanel;
    procedure CBMiniintrayClick(Sender: TObject);
    procedure CBTownsSelect(Sender: TObject);
    procedure EDegLatChange(Sender: TObject);
    procedure EDeglonChange(Sender: TObject);
    procedure ELatitudeChange(Sender: TObject);
    procedure ELongitudeChange(Sender: TObject);
  private
    function findtown(tname: string): Integer;
  public
    csvtowns: TcsvDocument;
  end;

var
  Prefs: TPrefs;

implementation
{$R *.lfm}

// Functions can be used by several of this unit classes

function stringCompare(Item1, Item2: String): Integer; forward;
function NumericCompare(Item1, Item2: Double): Integer; forward;

var  ClesTri: array[0..Ord(High(TChampsCompare))] of TChampsCompare;

{ TPrefs }


procedure TPrefs.ELatitudeChange(Sender: TObject);
var
  lat: Double;
  deg: Integer;
  min: Integer;
  sec: Double;
begin
  lat:= StringToFloat(ELatitude.text, '.') ;
  if lat < 0 then  lat:= lat*(-1);
  deg:= trunc(lat);
  min:= trunc((lat-deg)*60);
  sec:= (((lat-deg)*60)-min)*60;
  sec:= floatround(sec, 6);
  EDegLat.OnChange:= nil;
  EDegLat.Text:= InttoStr(deg);
  EminLat.Text:= InttoStr(min);
  ESecLat.text:= FloatToString (sec, '.');
  if lat>0 then ENSLat.text:= 'N' else   ENSLat.text:= 'S';
  EDegLat.OnChange:= @EDegLatChange;
end;

procedure TPrefs.EDegLatChange(Sender: TObject);
var
  min: double;
  sec: double;
  lat: double;
begin
  ELatitude.OnChange:= nil;
  lat:= StringToInt(EDegLat.text);
  min:= StringToInt(EMinLat.text) / 60;
  sec:= StringToFloat(ESecLat.text, '.')/3600;
  lat:= lat+min+sec;
  if uppercase(ENSLat.text)='S' then lat:= lat*(-1);
  Elatitude.Text:= FloatToString(lat, '.');
  ELatitude.OnChange:= @ELatitudeChange;
end;

procedure TPrefs.CBTownsSelect(Sender: TObject);
var
  n: integer;
begin
  n:= findtown(CBTowns.Items[CBTowns.ItemIndex]);
  ELatitude.Text:= csvtowns.cells[2,n];
  ELongitude.Text:= csvtowns.cells[3,n];
  ETimeZone.Text:= csvtowns.cells[4,n];
end;

procedure TPrefs.CBMiniintrayClick(Sender: TObject);
begin
  CBHideinTaskBar.Enabled:= (CBMiniintray.checked=true);
end;


function TPrefs.findtown(tname: string): Integer;
var
  i: Integer;
  curtown: TTown;
begin
 result:= -1;
 for i:= 0 to csvtowns.RowCount-1 do
  begin
    if tname=csvtowns.cells[0,i] then
    begin
      result:= i;
      break;
    end;
  end;
end;

procedure TPrefs.ELongitudeChange(Sender: TObject);
var
  lon: Double;
  deg: Integer;
  min: Integer;
  sec: Double;
begin
  lon:= StringToFloat(ELongitude.text, '.') ;
  if lon < 0 then  lon:= lon*(-1);
  deg:= trunc(lon);
  min:= trunc((lon-deg)*60);
  sec:= (((lon-deg)*60)-min)*60;
  sec:= floatround(sec, 6);
  EDeglon.OnChange:= nil;
  EDegLon.Text:= InttoStr(deg);
  EminLon.Text:= InttoStr(min);
  ESecLon.text:= FloatToString (sec, '.');
  if lon>0 then EEOlon.text:= 'E' else   EEOLon.text:= 'O';
  EDeglon.OnChange:= @EDeglonChange;
end;


procedure TPrefs.EDeglonChange(Sender: TObject);
var
  min: double;
  sec: double;
  lon: double;
begin
  ELongitude.OnChange:= nil;
  lon:= StringToInt(EDegLon.text);
  min:= StringToInt(EMinLon.text) / 60;
  sec:= StringToFloat(ESecLon.text, '.')/3600;
  lon:= lon+min+sec;
  if uppercase(EEOlon.text)='O' then lon:= lon*(-1);
  Elongitude.Text:= FloatToString(lon, '.');
  ELongitude.OnChange:= @ELongitudeChange;

end;




// TSettings

constructor TSettings.Create(Sender: TObject);
begin
  Create;
  Parent:= Sender;
end;

function stringCompare(Item1, Item2: String): Integer;
begin

  result := Comparestr(UpperCase(Item1), UpperCase(Item2));
end;

function NumericCompare(Item1, Item2: Double): Integer;
begin
  if Item1 > Item2 then result := 1
  else
  if Item1 = Item2 then result := 0
  else result := -1;
end;

function CompareMulti(Item1, Item2: Pointer): Integer;
var
 Entry1, Entry2: PFichier;
 R, J: integer;
 ResComp: array[TChampsCompare] of integer;
begin
 Entry1:= PFichier(Item1);
 Entry2:= PFichier(Item2);
 ResComp[cdcNone]:= 0;
 ResComp[cdcYear]:= NumericCompare(Entry1^.Year, Entry2^.Year);
 ResComp[cdcHalf]:= NumericCompare(Entry1^.Half, Entry2^.Half);
 R := 0;
 for J := 0 to Ord(High(TChampsCompare)) do
 begin
   if ResComp[ClesTri[J]] <> 0 then
    begin
      R := ResComp[ClesTri[J]];
      break;
    end;
 end;
 result :=  R;
end;

// End of common functions

procedure TSettings.setSaveMoon(value: Boolean);
begin
 if fsaveMoon<> value then
  begin
    fsaveMoon:= value;
    if Assigned(FOnChange) then FOnChange(Self);
  end;
end;

procedure TSettings.setSaveVacs(value: Boolean);
begin
 if fsavevacs<> value then
  begin
    fsavevacs:= value;
    if Assigned(FOnChange) then FOnChange(Self);
  end;
end;

procedure TSettings.setWstate(value: String);
begin
 if fwstate<> value then
  begin
    fwstate:= value;
    if Assigned(FOnChange) then FOnChange(Self);
  end;
end;

function TSettings.GetSysState(Index: Integer): Boolean;
begin
  result:= fSysStates[index];
end;

procedure TSettings.SetSysState(Index: Integer; value: Boolean);
begin
  if fSysStates[Index]<> value then
  begin
    fSysStates[Index]:= Value;
    if Assigned(FOnChange) then FOnChange(Self);
  end;
end;

procedure TSettings.setVersion(value: String);
begin
 if fversion<> value then
  begin
    fversion:= value;
    if Assigned(FOnChange) then FOnChange(Self);
  end;
end;


procedure TSettings.SetTown(value: String);
begin
 if fTown<> value then
  begin
    fTown:= value;
    if Assigned(FOnChange) then FOnChange(Self);
  end;
end;

procedure TSettings.setTownIndex(value: Integer);
begin
   if fTownIndex<> value then
  begin
    fTownIndex:= value;
    if Assigned(FOnChange) then FOnChange(Self);
  end;
end;

function TSettings.GetDaysColor(Index: Integer): TColor;
begin
  result:= FDaysColors[index];
end;

procedure TSettings.SetDaysColor(Index: Integer; Value: TColor);
begin
  if FDaysColors[Index]<> value then
  begin
    FDaysColors[Index]:= Value;
    if Assigned(FOnChange) then FOnChange(Self);
  end;
end;
function TSettings.GetVacsColor(Index: Integer): TColor;
begin
  result:= FVacsColors[index];
end;

procedure TSettings.SetVacsColor(Index: Integer; Value: TColor);
begin
  if FVacsColors[Index]<> value then
  begin
    FVacsColors[Index]:= Value;
    if Assigned(FOnChange) then FOnChange(Self);
  end;
end;

function TSettings.GetChkBox (Index: Integer): Boolean;
begin
  Result:= fChkBoxs[Index];
end;

procedure TSettings.SetChkBox (Index: Integer; Value: Boolean);
begin
  if fChkBoxs[Index]<> value then
  begin
    fChkBoxs[Index]:= Value;
    if Assigned(FOnChange) then FOnChange(Self);
  end;
end;

function TSettings.GetCoord (Index: Integer): Double;
begin
  Result:= fCoords[Index];
end;

procedure TSettings.SetCoord (Index: Integer; Value: Double);
begin
  if fCoords[Index]<> value then
  begin
    fCoords[Index]:= Value;
    if Assigned(FOnChange) then FOnChange(Self);
  end;
end;

procedure TSettings.setTimezone(Value: integer);
begin
  if fTimezone<> value then
  begin
    fTimezone:= Value;
    if Assigned(FOnChange) then FOnChange(Self);
  end;
end;

procedure TSettings.setLastupdchk(value: TDateTime);
begin
 if flastupdchk<>value then
 begin
   flastupdchk:= value;
   if Assigned(FOnChange) then FOnChange(Self);
 end;
end;

procedure TSettings.setNochknewver(value: Boolean);
begin
 if fnochknewver<>value then
 begin
   fnochknewver:= value;
   if Assigned(FOnChange) then FOnChange(Self);
 end;
end;

procedure TSettings.setLastversion(value: string);
begin
  if flastversion<>value then
  begin
    flastversion:= value;
    if Assigned(FOnChange) then FOnChange(Self);
  end;
end;

procedure TSettings.setLangstr(value: String);
begin
 if FLangStr<>value then
 begin
   flangstr:= value;
   if Assigned(FOnChange) then FOnChange(Self);
 end;
end;

function TSettings.SaveToXMLnode(iNode: TDOMNode): Boolean;
begin
  Try
    TDOMElement(iNode).SetAttribute ('version', fversion);
    TDOMElement(iNode).SetAttribute ('startwin', BoolToString(startwin));
    TDOMElement(iNode).SetAttribute ('savsizepos', BoolToString(savSizePos));
    TDOMElement(iNode).SetAttribute ('startmini', BoolToString(startmini));
    TDOMElement(iNode).SetAttribute ('miniintray',BoolToString(MiniInTray));
    TDOMElement(iNode).SetAttribute ('hideintaskbar', BoolToString(HideInTaskBar));
    TDOMElement(iNode).SetAttribute ('savemoon', BoolToString(fsaveMoon));
    TDOMElement(iNode).SetAttribute ('savevacs', BoolToString(fsavevacs));
    TDOMElement(iNode).SetAttribute ('wstate', FWState);
    TDOMElement(iNode).SetAttribute ('nochknewver', BoolToString(FNoChkNewVer));
    TDOMElement(iNode).SetAttribute ('lastupdchk', DateToStr(FLastUpdChk));
    TDOMElement(iNode).SetAttribute ('lastupdchk', TimeDateToString(FLastUpdChk, 'dd/mm/yyyy hh:nn:ss'));
    TDOMElement(iNode).SetAttribute ('lastversion', FLastVersion);
    TDOMElement(iNode).SetAttribute ('langstr', FLangStr);
    TDOMElement(iNode).SetAttribute ('town', fTown);
    TDOMElement(iNode).SetAttribute ('townindex', InttoStr(fTownindex));
    TDOMElement(iNode).SetAttribute ('timezone', IntToStr(fTimezone));
    TDOMElement(iNode).SetAttribute ('latitude', FloatToString(fCoords[0]));     // latitude
    TDOMElement(iNode).SetAttribute ('longitude', FloatToString(fCoords[1]));    // longitude
    TDOMElement(iNode).SetAttribute ('colback', ColorToString(colback));
    TDOMElement(iNode).SetAttribute ('colsunday', ColorToString(colsunday));
    TDOMElement(iNode).SetAttribute ('colferie', ColorToString(colferie));
    TDOMElement(iNode).SetAttribute ('coluser', ColorToString(coluser));
    TDOMElement(iNode).SetAttribute ('colvaca', ColorToString(colvaca));
    TDOMElement(iNode).SetAttribute ('colvacb', ColorToString(colvacb));
    TDOMElement(iNode).SetAttribute ('colvacc', ColorToString(colvacc));
    TDOMElement(iNode).SetAttribute ('colvack', ColorToString(colvack));
    TDOMElement(iNode).SetAttribute ('cbmoon', BoolToString(cbmoon));
    TDOMElement(iNode).SetAttribute ('cbvaca', BoolToString(cbvaca));
    TDOMElement(iNode).SetAttribute ('cbvacb', BoolToString(cbvacb));
    TDOMElement(iNode).SetAttribute ('cbvacc', BoolToString(cbvacc));
    TDOMElement(iNode).SetAttribute ('cbvack', BoolToString(cbvack));


    Result:= True;
  except
    result:= False;
  end;
end;




function TSettings.ReadXMLNode(iNode: TDOMNode): Boolean;
begin
  try
    fVersion:= TDOMElement(iNode).GetAttribute('version');
    fSysStates[0]:= StringToBool(TDOMElement(iNode).GetAttribute('startwin'));
    fSysStates[1]:= StringToBool(TDOMElement(iNode).GetAttribute('savsizepos'));
    fSysStates[2]:= StringToBool(TDOMElement(iNode).GetAttribute('startmini'));
    fSysStates[3]:= StringToBool(TDOMElement(iNode).GetAttribute('miniintray'));
    fSysStates[4]:= StringToBool(TDOMElement(iNode).GetAttribute('hideintaskbar'));
    fsaveMoon:= StringToBool(TDOMElement(iNode).GetAttribute('savemoon'));
    fsaveVacs:= StringToBool(TDOMElement(iNode).GetAttribute('savevacs'));
    FWState:= TDOMElement(iNode).GetAttribute('wstate');
    FNoChkNewVer:= StringToBool(TDOMElement(iNode).GetAttribute('nochknewver'));
    FLastUpdChk:= StringToTimeDate(TDOMElement(iNode).GetAttribute('lastupdchk'));
    FLastVersion:= TDOMElement(iNode).GetAttribute('lastversion');
    FLangStr:= TDOMElement(iNode).GetAttribute('langstr');
    fTown:= TDOMElement(iNode).GetAttribute('town');
    ftownIndex:= StringToInt(TDOMElement(iNode).GetAttribute('townindex'));
    fTimezone:= StringToInt(TDOMElement(iNode).GetAttribute('timezone'));
    fCoords[0]:= StringToFloat(TDOMElement(iNode).GetAttribute('latitude'));
    fCoords[1]:= StringToFloat(TDOMElement(iNode).GetAttribute('longitude'));
    fDaysColors[0]:= StringToColour(TDOMElement(iNode).GetAttribute('colback'));
    fDaysColors[1]:= StringToColour(TDOMElement(iNode).GetAttribute('colsunday'));
    fDaysColors[2]:= StringToColour(TDOMElement(iNode).GetAttribute('colferie'));
    fDaysColors[3]:= StringToColour(TDOMElement(iNode).GetAttribute('coluser'));
    fDaysColors[4]:= StringToColour(TDOMElement(iNode).GetAttribute('coltext'));
    fVacsColors[0]:= StringToColour(TDOMElement(iNode).GetAttribute('colvaca'));
    fVacsColors[1]:= StringToColour(TDOMElement(iNode).GetAttribute('colvacb'));
    fVacsColors[2]:= StringToColour(TDOMElement(iNode).GetAttribute('colvacc'));
    fVacsColors[3]:= StringToColour(TDOMElement(iNode).GetAttribute('colvack'));
    fChkBoxs[0]:= StringToBool(TDOMElement(iNode).GetAttribute('cbmoon'));
    fChkBoxs[1]:= StringToBool(TDOMElement(iNode).GetAttribute('cbvaca'));
    fChkBoxs[2]:= StringToBool(TDOMElement(iNode).GetAttribute('cbvacb'));
    fChkBoxs[3]:= StringToBool(TDOMElement(iNode).GetAttribute('cbvacc'));
    fChkBoxs[4]:= StringToBool(TDOMElement(iNode).GetAttribute('cbvack'));
    result:= true;
  except
    Result:= False;
  end;
end;


// TFichierList

procedure TFichierList.DoSort;
begin
  if FSortType <> cdcNone then
  begin
    ClesTri[1] := FSortType;
    sort(@comparemulti);
  end;
end;

procedure TFichierList.AddFile(Fichier : TFichier);
var
 K: PFichier;
begin
  new(K);
  K^.Index:= Fichier.Index;
  K^.Year:= Fichier.Year;
  K^.Half:= Fichier.Half;
  K^.LocalCopy:= Fichier.LocalCopy;
  K^.Name := Fichier.Name;
  K^.Path := Fichier.Path;
  add(K);
  DoSort;
  if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TFichierList.Delete(const i: Integer);
begin
  inherited delete(i);
  DoSort;
  if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TFichierList.ModifyFile (const i: integer; Fichier : TFichier);
begin
  TFichier(Items[i]^).Index:= Fichier.Index;
  TFichier(Items[i]^).Year:= Fichier.Year;
  TFichier(Items[i]^).Half:= Fichier.Half;
  TFichier(Items[i]^).LocalCopy:= Fichier.LocalCopy;
  TFichier(Items[i]^).Name := Fichier.Name;
  TFichier(Items[i]^).Path:= Fichier.Path;
  DoSort;
  if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TFichierList.ModifyField (const i: integer; field: string; value: variant);
begin
  if field='Index' then TFichier(Items[i]^).Index:= value;
  if field='Year' then TFichier(Items[i]^).Year:= value;
  if field='Half' then TFichier(Items[i]^).Half:= value;
  if field='LocalCopy' then TFichier(Items[i]^).LocalCopy:= value;
  if field='Name' then TFichier(Items[i]^).Name := value;
  if field='Path' then TFichier(Items[i]^).Path:= value;
  DoSort;
  if Assigned(FOnChange) then FOnChange(Self);
end;

function TFichierList.FindYearAndHalf(yr, hf: Integer): integer;
var
 i: integer;
 yr1, hf1: Integer;
begin
  result:=-1;
for i:= 0 to count-1 do
    if (yr=TFichier(Items[i]^).Year) and (hf=TFichier(Items[i]^).half) then
    begin
      result:= i;
      break;
    end;
end;

procedure TFichierList.Reset;
var
 i: Integer;
begin
 for i := 0 to Count-1 do
  if Items[i] <> nil then Items[i]:= nil;
 Clear;
end;

function TFichierList.GetItem(const i: Integer): TFichier;
begin
 Result := TFichier(Items[i]^);
end;

function TFichierList.SaveToXMLnode(iNode: TDOMNode): Boolean;
var
  i: Integer;
  FileNode: TDOMNode;
begin
  Result:= True;
  If Count > 0 Then
   For i:= 0 to Count-1 do
   Try
     FileNode := iNode.OwnerDocument.CreateElement('file');
     //TDOMElement(FileNode).SetAttribute('index', IntToStr(TFichier(Items[i]^).Index));
     TDOMElement(FileNode).SetAttribute('year', IntToStr(TFichier(Items[i]^).Year));
     TDOMElement(FileNode).SetAttribute('half', IntToStr(TFichier(Items[i]^).Half));
     TDOMElement(FileNode).SetAttribute('name', TFichier(Items[i]^).Name);
     TDOMElement(FileNode).SetAttribute('path', TFichier(Items[i]^).Path );
     TDOMElement(FileNode).SetAttribute('localcopy', TFichier(Items[i]^).LocalCopy);
     iNode.Appendchild(FileNode);
  except
    Result:= False;
  end;
end;

function TFichierList.ReadXMLNode(iNode: TDOMNode): Boolean;
var
  chNode: TDOMNode;
  k: PFichier;
begin
  chNode := iNode.FirstChild;
  while (chNode <> nil) and (chnode.NodeName='file')  do
  begin
    Try
      new(K);
      //K^.Index:= StringToInt(TDOMElement(chNode).GetAttribute('index'));
      K^.Year:= StringToInt(TDOMElement(chNode).GetAttribute('year'));
      K^.Half := StringToInt(TDOMElement(chNode).GetAttribute('half'));
      K^.Name := TDOMElement(chNode).GetAttribute('name');
      K^.Path := TDOMElement(chNode).GetAttribute('path');
      K^.LocalCopy:= TDOMElement(chNode).GetAttribute('localcopy');
      add(K);
    finally
      chNode := chNode.NextSibling;
    end;
  end;
end;

end.

