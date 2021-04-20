unit calsettings;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
  laz2_DOM, lazbbutils, lazbbcontrols;

type

  {Settings file management }

  TSettings = class
    private
      Parent: TObject;
      FOnChange: TNotifyEvent;
      FOnStateChange: TNotifyEvent;
      fsavsizepos: Boolean;
      fminiintray: Boolean;
      fhideintaskbar: Boolean;
      fwstate: String;
      fnochknewver: Boolean;
      flastupdchk: TDateTime;
      flastversion: String;
      fstartwin: Boolean;
      flangstr: String;
      fColferie: Tcolor;
      fTimezone: Integer;
      fDaysColors: array [0..2] of TColor;
      fVacsColors: array [0..3] of TColor;
      fChkBoxs: array [0..4] of Boolean;
      fCoords: array [0..1] of Double;
      function GetDaysColor(Index: Integer): TColor;
      procedure SetDaysColor(Index: Integer; Value: Tcolor);
      function GetVacsColor(Index: Integer): TColor;
      procedure SetVacsColor(Index: Integer; Value: Tcolor);
      function GetChkBox (Index: Integer): Boolean;
      procedure SetChkBox (Index: Integer; Value: Boolean);
      function GetCoord (Index: Integer): Double;
      procedure SetCoord (Index: Integer; Value: Double);
      procedure setTimezone (Value: Integer);
    public

      constructor Create (Sender: TObject); overload;
      function SaveToXMLnode(iNode: TDOMNode): Boolean;
      function ReadXMLNode(iNode: TDOMNode): Boolean;
    published
      property OnChange: TNotifyEvent read FOnChange write FOnChange;
      property OnStateChange: TNotifyEvent read FOnStateChange write FOnStateChange;
      property savsizepos: Boolean read fsavsizepos;
      Property miniintray: Boolean read fminiintray;
      property hideintaskbar : Boolean read fhideintaskbar;
      property wstate: String read fwstate;
      property nochknewver: Boolean read fnochknewver;
      property lastupdchk: TDateTime read flastupdchk;
      property lastversion: String read flastversion;
      property startwin: Boolean read fstartwin;
      property langstr: String read flangstr;
      property timezone: integer read fTimezone write setTimezone;
      property latitude: Double index 0 read GetCoord write SetCoord;
      property longitude: Double index 1 read GetCoord write SetCoord;
      property colweekday: TColor index 0 read GetDaysColor write SetDaysColor;
      property colsunday: Tcolor index 1 read GetDaysColor write SetDaysColor;
      property colferie: TColor index 2 read GetDaysColor write SetDaysColor;
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
    CBSaveSizPos: TCheckBox;
    CBSaveSizPos1: TCheckBox;
    CBSaveVacs: TCheckBox;
    CBStartmini: TCheckBox;
    CBStartwin: TCheckBox;
    CPcolText: TColorPicker;
    CPcolsunday: TColorPicker;
    CPColferie: TColorPicker;
    CPcolvack: TColorPicker;
    CPcolvacc: TColorPicker;
    CPcolvacb: TColorPicker;
    CPcolweek: TColorPicker;
    ComboBox1: TComboBox;
    CPcolvaca: TColorPicker;
    ELatitude: TEdit;
    Edit10: TEdit;
    Edit11: TEdit;
    Edit2: TEdit;
    Edit3: TEdit;
    Edit4: TEdit;
    Edit5: TEdit;
    ELongitude: TEdit;
    Edit7: TEdit;
    Edit8: TEdit;
    Edit9: TEdit;
    LColtText: TLabel;
    LLatitude: TLabel;
    LLatitude1: TLabel;
    LLatitude2: TLabel;
    LLatitude3: TLabel;
    LLatitude4: TLabel;
    LLatitude5: TLabel;
    LLatitude6: TLabel;
    LLatitude7: TLabel;
    LTown: TLabel;
    LTimezone: TLabel;
    LZonek: TLabel;
    LZonec: TLabel;
    LZoneb: TLabel;
    lLColBack: TLabel;
    LColSund: TLabel;
    LColferie: TLabel;
    LZonea: TLabel;
    PanCoords: TTitlePanel;
    PanButtons: TPanel;
    PanStatus: TPanel;
    PanColors: TTitlePanel;
    PanSystem: TTitlePanel;
    procedure PanButtonsClick(Sender: TObject);
  private

  public

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

procedure TPrefs.PanButtonsClick(Sender: TObject);
begin

end;

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

function TSettings.SaveToXMLnode(iNode: TDOMNode): Boolean;
begin
  Try
    TDOMElement(iNode).SetAttribute ('savsizepos', BoolToString(FSavSizePos));
    TDOMElement(iNode).SetAttribute ('miniintray',BoolToString(FMiniInTray));
    TDOMElement(iNode).SetAttribute ('hideintaskbar', BoolToString(FHideInTaskBar));
    TDOMElement(iNode).SetAttribute ('wstate', FWState);
    TDOMElement(iNode).SetAttribute ('nochknewver', BoolToString(FNoChkNewVer));
    TDOMElement(iNode).SetAttribute ('lastupdchk', DateToStr(FLastUpdChk));
    TDOMElement(iNode).SetAttribute ('lastupdchk', TimeDateToString(FLastUpdChk, 'dd/mm/yyyy hh:nn:ss'));
    TDOMElement(iNode).SetAttribute ('lastversion', FLastVersion);
    TDOMElement(iNode).SetAttribute ('startwin', BoolToString(FStartWin));
    TDOMElement(iNode).SetAttribute ('langstr', FLangStr);
    TDOMElement(iNode).SetAttribute ('timezone', IntToStr(fTimezone));
    TDOMElement(iNode).SetAttribute ('latitude', FloatToString(fCoords[0]));     // latitude
    TDOMElement(iNode).SetAttribute ('longitude', FloatToString(fCoords[1]));    // longitude
    TDOMElement(iNode).SetAttribute ('colweekday', ColorToString(colweekday));
    TDOMElement(iNode).SetAttribute ('colsunday', ColorToString(colsunday));
    TDOMElement(iNode).SetAttribute ('colferie', ColorToString(colferie));
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
    FSavSizePos:= StringToBool(TDOMElement(iNode).GetAttribute('savsizepos'));
    FMiniInTray:= StringToBool(TDOMElement(iNode).GetAttribute('miniintray'));
    FHideInTaskBar:= StringToBool(TDOMElement(iNode).GetAttribute('hideintaskbar'));
    FWState:= TDOMElement(iNode).GetAttribute('wstate');
    FNoChkNewVer:= StringToBool(TDOMElement(iNode).GetAttribute('nochknewver'));
    FLastUpdChk:= StringToTimeDate(TDOMElement(iNode).GetAttribute('lastupdchk'));
    FLastVersion:= TDOMElement(iNode).GetAttribute('lastversion');
    FStartWin:= StringToBool(TDOMElement(iNode).GetAttribute('startwin'));
    FLangStr:= TDOMElement(iNode).GetAttribute('langstr');
    fTimezone:= StringToInt(TDOMElement(iNode).GetAttribute('timezone'));
    fCoords[0]:= StringToFloat(TDOMElement(iNode).GetAttribute('latitude'));
    fCoords[1]:= StringToFloat(TDOMElement(iNode).GetAttribute('longitude'));
    fDaysColors[0]:= StringToColour(TDOMElement(iNode).GetAttribute('colweekday'));
    fDaysColors[1]:= StringToColour(TDOMElement(iNode).GetAttribute('colsunday'));
    fDaysColors[2]:= StringToColour(TDOMElement(iNode).GetAttribute('colferie'));
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
     TDOMElement(FileNode).SetAttribute('index', IntToStr(TFichier(Items[i]^).Index));
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
      K^.Index:= StringToInt(TDOMElement(chNode).GetAttribute('index'));
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

