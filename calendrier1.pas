unit calendrier1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, ComCtrls,
  Grids, StdCtrls, lazbbcontrols, csvdocument, Types;

type

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
    procedure SGDrawCell(Sender: TObject; aCol, aRow: Integer; aRect: TRect;
      aState: TGridDrawState);
  private
    curyear: integer;
    First: Boolean;
    aSG: array[0..3] of TStringGrid;
    ColorDay, ColorSunday : TColor;
    csvsaints: TCSVDocument;

  public
  procedure UpdateCal (Annee : word);
    Function GetBegMonth(dDate: TDateTime): word;
  end;

var
  FCalendrier: TFCalendrier;

implementation

{$R *.lfm}

{ TFCalendrier }

procedure TFCalendrier.FormCreate(Sender: TObject);
begin
  Inherited;
  First:= true;
  // place properly grids and panels
  SG1.Left:= 0;
  PanImg1.left:= SG1.Width;
  SG2.Left:= SG1.Width+PanImg1.Width+1;
  SG3.Left:= 0;
  PanImg2.left:= SG3.Width;
  SG4.Left:= SG3.Width+PanImg2.Width+1;
  // populate array of quarters
  aSG[0]:= SG1;
  aSG[1]:= SG2;
  aSG[2]:= SG3;
  aSG[3]:= SG4;
  ColorDay:= clDefault;
  ColorSunday:= RGBToColor(128,255,255);
  csvsaints:= TCSVDocument.Create;
  csvsaints.LoadFromFile('saints.csv');
end;

procedure TFCalendrier.FormActivate(Sender: TObject);
begin
  first:= false;
  CurYear:= 2021;
  UpdateCal(Curyear);
end;

procedure TFCalendrier.SGDrawCell(Sender: TObject; aCol, aRow: Integer;
  aRect: TRect; aState: TGridDrawState);
Var
  X,Y: Integer;
  S, s1   : String;
  MyDate : TDateTime;
  i, j, w: Integer;
  Bmp: TBitmap;
  SGCur: TStringGrid;
  GridNum: Word;
  Month: Word;
  DefBrushColor: TColor;
begin
  SGCur:= TStringGrid(Sender);
  GridNum:= StrToInt(Copy(SgCur.Name, 3, 1));
  Month:= ACol+1+ 3*(GridNum-1);
  try
    MyDate:= EncodeDate(CurYear, Month, ARow) ;
  except

  end;
  s:=SGCur.Cells[ACol,ARow];
  // On centre les mois
  If ARow = 0 then
  begin
    SGCur.Canvas.Font:= PanStatus.Font;
    w:= SGCur.Canvas.TextWidth(s);
    x:=aRect.Left+(aRect.Right-aRect.Left-w) div 2;
    y:=1+aRect.Top;
    SGCur.Canvas.Brush.Color:= clBtnface;
    SGCur.Canvas.Rectangle(aRect.Left,aRect.Top,aRect.Right,aRect.Bottom);
    SGCur.Canvas.TextOut(x,y,s);
    SGCur.Canvas.Font:= SGCur.Font;

  end;
  // Get current day
  if DayOfWeek(MyDate)= 1 then
  begin
    x:=2+aRect.Left;
    y:=1+aRect.Top;
    SGCur.Canvas.Brush.Color:= ColorSunday;
    SGCur.Canvas.Rectangle(aRect.Left,aRect.Top,aRect.Right,aRect.Bottom);
    SGCur.Canvas.Font.Color:= clBlack;
    SGCur.Canvas.TextOut(x,y,s);
    //SGCur.Canvas.Font:= SGCur.Font;
  end;

end;

procedure TFCalendrier.UpdateCal (Annee : word);
var
  s, s1, s2, saint, genre : string;
  BegYear : TDateTime;
  CYear, CMonth, CDay: Word;
  DaysCnt: Word;
  i, j, k: Integer;
  FilNam1, FilNam2: string;
  Parser: TCSVParser;
begin
  // Sans objet avant l'année 1583 (calendrier julien)
  if Annee < 1583 then Annee:= 1583;
  // Ni après l'année 9998
  if Annee > 9998 then Annee:= 9998;
  CurYear:= Annee;
  Caption:= 'Calendrier '+IntToStr(CurYear);
  EYear.Text:= IntToStr(Annee);
  Application.Title:= Caption;
  For i:= 0 to 11 do
  begin
    s:=  DefaultFormatSettings.LongMonthNames[i+1];
    s[1]:= upcase (s[1]);
    aSG[i div 3].Cells[i -3*(i div 3), 0]:= s;
  end;
  // Ecrit les jours
  BegYear:= EncodeDate(Annee,1,1);
  // Année bissextile
  if IsLeapYear(Annee) then DaysCnt:= 366 else DaysCnt:= 365;

  j:= 0;
  For i:= 1 to DaysCnt do
  begin
    DecodeDate(BegYear+i-1, CYear, CMonth, CDay);
    s1:= csvsaints.Cells[1,j];
    if (DaysCnt=365) and (j=58) then inc(j); // on saute le 298 février !
    s:= DefaultFormatSettings.ShortDayNames[DayOfWeek(BegYear+i-1)];
    aSG[(cMonth-1) div 3].Cells[cMonth-1 -3*((cMonth-1) div 3),i-GetBegMonth(BegYear+i-1)]:= FormatDateTime('d', BegYear+i-1)+' '+upcase(s[1])+'  '+s1;
    inc(j);
  end;
end;

// Jour de début du mois

Function TFCalendrier.GetBegMonth(dDate: TDateTime): word;
const
  leapyear : array [1..12] of Integer = (0,31,60,91,121,152,182,213,244,274,305,335);
  noleapyear: array [1..12] of Integer = (0,31,59,90,120,151,181,212,243,273,304,334);
var
  CurrYear, CurMonth, CurDay: Word;
begin
  DecodeDate(dDate, CurrYear, CurMonth, CurDay);
  if IsLeapYear(CurrYear) then  result:= leapyear[CurMonth] else result:= noleapyear[CurMonth] ;
end;

end.

