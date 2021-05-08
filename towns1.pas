unit towns1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  lazbbcontrols, csvDocument, lazbbutils;

type

  { TFTowns }

  TFTowns = class(TForm)
    BtnAdd: TButton;
    BtnCancel: TButton;
    BtnDelete: TButton;
    BtnOK: TButton;
    EDegLat: TEdit;
    EDeglon: TEdit;
    ETown: TEdit;
    EEOlon: TEdit;
    ELatitude: TEdit;
    ELongitude: TEdit;
    EMinLat: TEdit;
    EMinLon: TEdit;
    ENSLat: TEdit;
    ESecLat: TEdit;
    ESeclon: TEdit;
    ETimeZone: TEdit;
    ListTowns: TListBox;
    Llatdeg: TLabel;
    LLatitude: TLabel;
    LLatmin: TLabel;
    Llatsec: TLabel;
    Llondeg: TLabel;
    LLongitude: TLabel;
    Llonmin: TLabel;
    Llonsec: TLabel;
    LTimezone: TLabel;
    LTown: TLabel;
    PanCoords: TTitlePanel;
    PanStatus: TPanel;
    procedure BtnAddClick(Sender: TObject);
    procedure BtnChangeClick(Sender: TObject);
    procedure BtnDeleteClick(Sender: TObject);
    procedure EDegLatChange(Sender: TObject);
    procedure EDeglonChange(Sender: TObject);
    procedure ELatitudeChange(Sender: TObject);
    procedure ECoordKeyPress(Sender: TObject; var Key: char);
    procedure ELongitudeChange(Sender: TObject);
    procedure ETownChange(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure ListTownsClick(Sender: TObject);

  private
    CurIndex: integer;

    prevTown, prevLatitude, prevLongitude, prevTimezone: String;
    function findlsttown(tlst: TListBox; tname: string): Integer;
    function findcsvtown(tcsv: TcsvDocument; tname: string): Integer;

  public
    TownsListChanged: Boolean;
    csv: TCSVDocument;
    sConfirmDelTown: String;
  end;

var
  FTowns: TFTowns;

implementation

{$R *.lfm}

{ TFTowns }

uses calsettings;

procedure TFTowns.FormShow(Sender: TObject);
var
  i: Integer;
begin
  if not assigned(csv) then csv:= TCSVDocument.Create;
  TownsListChanged:= False;
  if not assigned (Prefs.csvtowns) then ModalResult:= mrcancel;
  csv.CSVText:= Prefs.csvtowns.csvText;
  ListTowns.Clear;
  for i:= 0 to  csv.RowCount-1 do
  begin
    ListTowns.Items.Add(csv.Cells[0, i]);
  end;
  Etown.Text:= Prefs.CBTowns.Text;
  ELongitude.Text:= Prefs.ELongitude.Text;
  ELatitude.Text:= Prefs.ELatitude.Text;
  ETimeZone.Text:= Prefs.ETimeZone.Text;
  ListTowns.ItemIndex:= Prefs.CBTowns.ItemIndex;
  if ListTowns.ItemIndex=-1 then
  begin
    BtnAdd.Enabled:= true;
    BtnDelete.Enabled:= false;
  end else
  begin
    BtnAdd.Enabled:= false;
    BtnDelete.Enabled:= true;
  end;
  ETown.OnChange:= @ETownChange;
end;

procedure TFTowns.ListTownsClick(Sender: TObject);
begin
  if ListTowns.ItemIndex>=0 then CurIndex:= findcsvtown(csv, ListTowns.Items[ListTowns.ItemIndex])
  else exit;
  ETown.OnChange:= nil;
  prevTown:= csv.Cells[0,CurIndex] ;
  ETown.Text:= prevTown;
  prevLatitude:= csv.Cells[2,CurIndex] ;
  Elatitude.Text:= prevLatitude;
  prevLongitude:= csv.Cells[3,CurIndex] ;
  Elongitude.Text:= prevLongitude;
  prevTimezone:= csv.Cells[4,CurIndex] ;
  ETimeZone.Text:= prevTimezone;
  BtnAdd.enabled:= false;
  BtnDelete.Enabled:= true;
  ETown.OnChange:= @EtownChange;;
end;

procedure TFTowns.ELatitudeChange(Sender: TObject);
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
  BtnAdd.Enabled:= true;
end;


procedure TFTowns.ECoordKeyPress(Sender: TObject; var Key: char);
begin
   if not (Key in ['0'..'9', '.','-', #8, #9]) then Key := #0;
end;

procedure TFTowns.ELongitudeChange(Sender: TObject);
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
  BtnAdd.Enabled:= True;
end;

procedure TFTowns.ETownChange(Sender: TObject);
begin
  BtnAdd.Enabled:= True;
end;



procedure TFTowns.EDegLatChange(Sender: TObject);
var
  min: double;
  sec: double;
  lat: double;
  s: String;
  Decpt: integer;
begin
  ELatitude.OnChange:= nil;
  lat:= StringToInt(EDegLat.text);
  min:= StringToInt(EMinLat.text) / 60;
  sec:= StringToFloat(ESecLat.text, '.')/3600;
  lat:= lat+min+sec;
  if uppercase(ENSLat.text)='S' then lat:= lat*(-1);
  s:= FloatToString(lat, '.');
  Decpt:= Pos('.', s);
  Elatitude.Text:= Copy (s, 1, DecPt+6);
  ELatitude.OnChange:= @ELatitudeChange;
end;

procedure TFTowns.BtnAddClick(Sender: TObject);
var
  i: Integer;
begin
  if TButton(Sender).tag= 0 then // Add
  begin
    // Add new town at the csv list
    csv.AddRow(ETown.text);
    csv.AddCell(csv.RowCount-1, '');
    csv.AddCell(csv.RowCount-1, ELatitude.Text);
    csv.AddCell(csv.RowCount-1, ELongitude.Text);
    csv.AddCell(csv.RowCount-1, ETimeZone.Text);
    // reload towns in the list
    ListTowns.Items.Clear;
    for i:= 0 to csv.RowCount-1 do ListTowns.Items.Add(csv.Cells[0,i]);
    ListTowns.ItemIndex:= findlsttown(ListTowns, ETown.text);
    TownsListChanged:= true;
  end;
end;

procedure TFTowns.BtnChangeClick(Sender: TObject);
begin

end;

procedure TFTowns.BtnDeleteClick(Sender: TObject);
var
  i: Integer;
  s: String;
begin
  s:= ListTowns.Items[ListTowns.ItemIndex];
  if  MsgDlg(Caption, sConfirmDelTown+' '+s+' ?',mtWarning,
            [mbYes, mbNo], ['Oui','Non'])=mrYes then
  begin
    i:= findcsvtown(csv, s);
    csv.RemoveRow(i);
    ListTowns.Items.Clear;
    for i:= 0 to csv.RowCount-1 do ListTowns.Items.Add(csv.Cells[0,i]);
    ListTowns.ItemIndex:= 0;
    TownsListChanged:= true;
  end;
end;

procedure TFTowns.EDeglonChange(Sender: TObject);
var
  min: double;
  sec: double;
  lon: double;
  s: string;
  DecPt: Integer;
begin
  ELongitude.OnChange:= nil;
  lon:= StringToInt(EDegLon.text);
  min:= StringToInt(EMinLon.text) / 60;
  sec:= StringToFloat(ESecLon.text, '.')/3600;
  lon:= lon+min+sec;
  if uppercase(EEOlon.text)='O' then lon:= lon*(-1);
  s:= FloatToString(lon, '.');
  Decpt:= Pos('.', s);
  Elongitude.Text:= Copy (s, 1, DecPt+6);
  ELongitude.OnChange:= @ELongitudeChange;
end;

function TFTowns.findcsvtown(tcsv: TcsvDocument; tname: string): Integer;
var
  i: Integer;
begin
 result:= -1;
 for i:= 0 to tcsv.RowCount-1 do
  begin
    if tname=tcsv.cells[0,i] then
    begin
      result:= i;
      break;
    end;
  end;
end;

function TFTowns.findlsttown(tlst: TListBox; tname: string): Integer;
var
  i: Integer;
begin
 result:= -1;
 for i:= 0 to tlst.Count-1 do
  begin
    if tname=tlst.Items[i] then
    begin
      result:= i;
      break;
    end;
  end;
end;


end.

