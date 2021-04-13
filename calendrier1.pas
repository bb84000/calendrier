unit calendrier1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, ComCtrls,
  Grids, StdCtrls, lazbbcontrols, csvdocument, Types, DateUtils;

type
  TDay = record
    index: integer;
    ddate: TDateTime;
    sday: string;
    sSaint: string;
    sFerie: String;
    sDesc: string;
    bSunday: boolean;
    bFerie: boolean;
    sHoliday: string; //A, B, C,
    iDay: integer;
    iMonth: integer;
    iQuarter: integer;
  end;


  { TFCalendrier }

  TFCalendrier = class(TForm)
    CBLune: TCheckBoxX;
    CBVA: TCheckBoxX;
    CBVB: TCheckBoxX;
    CBVC: TCheckBoxX;
    EYear: TEdit;
    PageControl1: TPageControl;
    PanImg1: TPanel;
    PanImg2: TPanel;
    PanStatus: TPanel;
    ScrollBox1: TScrollBox;
    ScrollBox2: TScrollBox;
    SG1: TStringGrid;
    SG2: TStringGrid;
    SG3: TStringGrid;
    SG4: TStringGrid;
    TS2: TTabSheet;
    TS1: TTabSheet;

    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure SGDrawCell(Sender: TObject; aCol, aRow: integer;
      aRect: TRect; aState: TGridDrawState);
  private
    curyear: integer;
    First: boolean;
    aSG: array[0..3] of TStringGrid;
    ColorDay, ColorSunday, ColorFerie: TColor;
    csvsaints, csvferies: TCSVDocument;
    Days: array of TDay;
    aMonths: array [1..13] of integer;
  public
    procedure UpdateCal(Annee: word);
    function GetBegMonth(dDate: TDateTime): word;
    Function GetPaques(Year: Word): TDateTime;
    Function GetDeportes(Year: Word): TDateTime;
    function GetFetMeres (Year: Word): TDateTime;
  end;

var
  FCalendrier: TFCalendrier;

const
  leapyear: array [1..13] of integer = (0, 31, 60, 91, 121, 152, 182, 213, 244, 274, 305, 335, 366);
  noleapyear: array [1..13] of integer =     (0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334, 365);

implementation

{$R *.lfm}

{ TFCalendrier }

procedure TFCalendrier.FormCreate(Sender: TObject);
var
  saintstream, feriestream: TResourceStream;
begin
  inherited;
  First := True;
  // place properly grids and panels
  SG1.Left := 0;
  PanImg1.left := SG1.Width;
  SG2.Left := SG1.Width + PanImg1.Width + 1;
  SG3.Left := 0;
  PanImg2.left := SG3.Width;
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
  saintstream := TResourceStream.Create(HInstance, 'SAINTSLIST_FR', RT_RCDATA);
  csvsaints.LoadFromStream(saintstream);
  if assigned(saintstream) then
    FreeAndNil(saintstream);
  // load feries from resource
  csvferies := TCSVDocument.Create;
  feriestream := TResourceStream.Create(HInstance, 'FERIESLIST_FR', RT_RCDATA);
  csvferies.LoadFromStream(feriestream);
  if assigned(feriestream) then
    FreeAndNil(feriestream);
end;

procedure TFCalendrier.FormDestroy(Sender: TObject);
begin
  if assigned(csvsaints) then
    FreeAndNil(csvsaints);
end;

procedure TFCalendrier.FormActivate(Sender: TObject);
begin
  First := False;
  CurYear := 2020;
  UpdateCal(YearOf(now));
  if MonthOf(now) < 7 then PageControl1.Activepage:= TS1
  else PageControl1.Activepage:= TS2;
  //ShowMessage(csvferies.CSVText);
end;

procedure TFCalendrier.SGDrawCell(Sender: TObject; aCol, aRow: integer;
  aRect: TRect; aState: TGridDrawState);
var
  X, Y: integer;
  S, s1: string;
  MyDate: TDateTime;
  i, j, w: integer;
  Bmp: TBitmap;
  SGCur: TStringGrid;
  GridNum: word;
  Month: word;
  DefBrushColor: TColor;
  quarter: integer;
  Count: integer;
  max: integer;
begin
  SGCur := TStringGrid(Sender);
  GridNum := StrToInt(Copy(SgCur.Name, 3, 1));
  Month := ACol + 1 + 3 * (GridNum - 1);
  try
    MyDate := EncodeDate(CurYear, Month, ARow);
  except

  end;
  s := SGCur.Cells[ACol, ARow];
  // On centre les mois
  if ARow = 0 then
  begin
    SGCur.Canvas.Font := PanStatus.Font;
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
        SGCur.Canvas.Brush.Color := ColorSunday;
        SGCur.Canvas.Rectangle(aRect.Left,aRect.Top,aRect.Right,aRect.Bottom);
      end;
      if (Days[Count+arow-1].bferie) then
      begin
        SGCur.Canvas.Brush.Color := ColorFerie;
        SGCur.Canvas.Rectangle(aRect.Left,aRect.Top,aRect.Right,aRect.Bottom);
        s1 := Days[Count + arow - 1].sferie;
      end;

      SGCur.Canvas.TextOut(x, y, s + ' ' + s1);     //
    end ;

  end;
end;

procedure TFCalendrier.UpdateCal(Annee: word);
var
  s, s1, s2, saint, genre: string;
  BegYear: TDateTime;
  CYear, CMonth, CDay: word;
  DaysCnt: word;
  i, j, k: integer;
  FilNam1, FilNam2: string;
  Parser: TCSVParser;
  Currentday: TDateTime;
  PaqDay, DepDay, MerDay: TDateTime;
  DOY: Integer;
const
  aDOW: array [1..7] of char = ('D', 'L', 'M', 'M', 'J', 'V', 'S');
begin
  // Sans objet avant l'année 1583 (calendrier julien)
  if Annee < 1583 then Annee := 1583;
  // Ni après l'année 9998
  if Annee > 9998 then Annee := 9998;
  CurYear := Annee;
  // Bissextile ?
  if Isleapyear(curyear) then aMonths := leapyear else aMonths := noleapyear;
  Caption := 'Calendrier ' + IntToStr(CurYear);
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
  // Année bissextile
  if IsLeapYear(Annee) then
    DaysCnt := 366
  else
    DaysCnt := 365;
  setlength(Days, DaysCnt);
  j := 0;
  for i := 1 to DaysCnt do
  begin
    CurrentDay:= BegYear + i - 1;
    DecodeDate(CurrentDay, CYear, CMonth, CDay);
    s1 := csvsaints.Cells[1, j];
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
    //bFerie : Boolean;
    //sHoliday: String; //A, B, C,
    Inc(j);
  end;
    PaqDay:= GetPaques(Annee);
  DepDay:= GetDeportes(Annee);
  MerDay:= GetFetMeres(Annee);
  // Update csvFerie
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
    Days[DOY].sFerie := csvferies.Cells[1,i];
    if length(csvferies.Cells[2,i])>0 then Days[DOY].sDesc:= csvferies.Cells[2,i];
    Days[DOY].bFerie:= true;
  end;
end;

// Jour de début du mois

function TFCalendrier.GetBegMonth(dDate: TDateTime): word;

var
  CurrYear, CurMonth, CurDay: word;
begin
  DecodeDate(dDate, CurrYear, CurMonth, CurDay);
  if IsLeapYear(CurrYear) then
    Result := leapyear[CurMonth]
  else
    Result := noleapyear[CurMonth];
end;

Function TFCalendrier.GetPaques(Year: Word): TDateTime;     // Wikipedia
var
  nMonth, nDay, nMoon, nEpact, nSunday, nGold, nCent, nCorx, nCorz: Integer;
begin
  { The Golden Number of the year in the 19 year Metonic Cycle: }
  nGold := (Year mod 19) + 1;
  { Calculate the Century: }
  nCent := (Year div 100) + 1;
  { Number of years in which leap year was dropped in order... }
  { to keep in step with the sun: }
  nCorx := (3 * nCent) div 4 - 12;
  { Special correction to syncronize Easter with moon's orbit: }
  nCorz := (8 * nCent + 5) div 25 - 5;
  { Find Sunday: }
  nSunday := (Longint(5) * Year) div 4 - nCorx - 10;
  { ^ To prevent overflow at year 6554}
  { Set Epact - specifies occurrence of full moon: }
  nEpact := (11 * nGold + 20 + nCorz - nCorx) mod 30;
  if nEpact < 0 then
    nEpact := nEpact + 30;
  if ((nEpact = 25) and (nGold > 11)) or (nEpact = 24) then
    nEpact := nEpact + 1;
  { Find Full Moon: }
  nMoon := 44 - nEpact;
  if nMoon < 21 then
    nMoon := nMoon + 30;
  { Advance to Sunday: }
  nMoon := nMoon + 7 - ((nSunday + nMoon) mod 7);
  if nMoon > 31 then
  begin
    nMonth := 4;
    nDay   := nMoon - 31;
  end
  else
  begin
    nMonth := 3;
    nDay   := nMoon;
  end;
  result := EncodeDate(Year, nMonth, nDay);
end;

Function TFCalendrier.GetDeportes(Year: Word): TDateTime;
var
  d: TDateTime;
begin
  // dernier dimanche d'avril
  d:= EncodeDate(Year, 4, 30);           // On prend la fin du mois
  result:= d- DayOfWeek(d)+1;            // Et on retire les jours nécessaires
end;

function TFCalendrier.GetFetMeres (Year: Word): TDateTime;
var
  d: TDateTime;
begin
  // Dernier dimanche de mai
    d:= EncodeDate(Year, 5, 31);           // On prend la fin du mois
    result:= d- DayOfWeek(d)+1;            // Et on retire les jours nécessaires
    if result = GetPaques (Year)+49        // Tombe en même temps que la pentecôte ?
    then result:= result+7;                // Alors une semaine plus tard
end;

end.
