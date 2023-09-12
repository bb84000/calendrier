//******************************************************************************
// Printcal unit
// Preview and printing functions for Calendar application
// bb - sdtp - May 2023
// Parameters:
//
//******************************************************************************

unit printcal;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, PrintersDlgs, Printers,
  ExtCtrls, StdCtrls, calsettings, lazbbutils, strutils;

type

  { TFPrintCal }

  TFPrintCal = class(TForm)
    BtnClose: TButton;
    BtnPrint: TButton;
    CBPrinters: TComboBox;
    ImgPreview: TImage;
    PanBtns: TPanel;
    PanPreview: TPanel;
    PrintDialog1: TPrintDialog;
    RB1: TRadioButton;
    RB2: TRadioButton;
    procedure BtnPrintClick(Sender: TObject);
    procedure CBPrintersChange(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure RBChange(Sender: TObject);
  private

    myPrinter: Tprinter;
    myBmp: TBitmap;
    scaleFactor: Double;
    procedure SetBitmap;
    function pSize(value: Integer): Integer;
    function txtwrap(cnv: TCanvas; sz: integer; s: string): String;
    procedure TextRect(Canv: TCanvas; Rec: Trect; x, y : Integer; s: String; styl: TTextStyle);
  public
    half: Integer;
  end;

var
  FPrintCal: TFPrintCal;

implementation

uses Calendrier1;
{$R *.lfm}

{ TFPrintCal }

procedure TFPrintCal.FormShow(Sender: TObject);
var
  i: Integer;
begin
  RB1.Onchange:= nil;
  RB2.OnChange:= nil;
  CBPrinters.OnChange:= nil;
  if not PrintDialog1.Execute then close;
  myPrinter:= Printer;
  CBPrinters.Items.Assign(MyPrinter.Printers);
  For i:=0 to CBPrinters.Items.Count-1 do
  begin
    if CBPrinters.Items[i]=myPrinter.PrinterName then
    begin
      CBPrinters.ItemIndex:= i;
      break;
    end else CBPrinters.ItemIndex:= 0   ;
  end;
  RB1.Checked:= true;
  if half=2 then RB2.Checked:= true;
  RB1.Onchange:= @RBChange;
  RB2.OnChange:= @RBChange;
  CBPrinters.OnChange:= @CBPrintersChange;
  myPrinter.SetPrinter(CBPrinters.Items[CBPrinters.ItemIndex]);
  SetBitmap;
end;

procedure TFPrintCal.BtnPrintClick(Sender: TObject);
begin
  MyPrinter.Title:= FCalendrier.sMainCaption;
  MyPrinter.BeginDoc;
  myPrinter.Canvas.CopyRect(Rect(0, 0, MyPrinter.PageWidth, MyBmp.Height), myBmp.Canvas, Rect(0, 0, myBmp.Width , myBmp.Height));
  MyPrinter.EndDoc;
end;

procedure TFPrintCal.CBPrintersChange(Sender: TObject);
begin
   Application.ProcessMessages;
   myPrinter.SetPrinter(CBPrinters.Items[CBPrinters.ItemIndex]);
   SetBitmap;
end;



procedure TFPrintCal.RBChange(Sender: TObject);
var
  value: Integer;
begin
 if RB1.checked then value:= 1 else Value:=2;
 if value<>half then
 begin
   half:= value;
   myPrinter.SetPrinter(CBPrinters.Items[CBPrinters.ItemIndex]);
   SetBitmap;
 end;
end;

// convert screen pixels to printer equivalents

function TFPrintCal.pSize(value: Integer): Integer;
begin
   result:= trunc(value*scaleFactor);
end;

// Canvas Text wrap function (wordwrap style partially broken in win32)
// Works ony with 2 lines, insert '_' at break

function TFPrintCal.txtwrap(cnv: TCanvas; sz: integer; s: string): String;
var
  p: Integer;
  s1: String;
begin
  if cnv.TextWidth(s) < sz then
  begin
    result:=s;
    exit
  end;
  s1:= s;
  p:= rpos(' ', s1);
  s1:= copy(s, 1, p-1);
  while cnv.TextWidth(s1) > sz do
  begin
    p:= RPos(' ', s1);
    s1:= Copy(s, 1, p-1);
  end;
  Result:= s1+'_'+Copy(s, p, length(s));
end;

// Workaround for win32 where Wordbreak style is broken

procedure TFPrintCal.TextRect(Canv: TCanvas; Rec: Trect; x, y : Integer; s: String; styl: TTextStyle);
{$IFDEF win32}
var
  p: Integer;
  th: Integer;
{$ENDIF}
begin
  {$IFDEF win32}
    th:= 95*Canv.TextHeight(s) div 100; // Interline 95 % of text height
    p:= pos('_', txtwrap(Canv,Rec.Right-x, s));
    if (p>0) and Styl.Wordbreak then
    begin
      Canv.TextRect(Rec, x,y, Copy(s, 1, p-1), Styl);
      Canv.TextRect(Rec, x,y+th, Copy(s, p+1, length(s)), Styl);
    end else Canv.TextRect(Rec, x,y, s, Styl);
 {$ELSE}
    Canv.TextRect(Rec, x,y, s, Styl);
 {$ENDIF}
end;

procedure TFPrintCal.SetBitmap;
var
  pw, ph: Integer;
  colw, rowh: Integer;
  tStyle: TTextStyle;
  txtheight, txtwidth: Integer;
  topMargin, leftMargin: Integer;
  x, xl, xr, y, yt, yb : integer;
  acol, arow: Integer;
  s, s1: string;
  count, max, numday: Integer;
  curday: TDay;
  Monthoffset: Integer;
  ImgL, ImgR, ImgT, ImgB: Integer;
  PageRatio: Double;
  Pict: Tpicture;
  ImgHalf: TFichier;
  i: Integer;
  imgname: string;
  mRect: TRect;
  imgnum: Integer;
  DefBrushColor: Tcolor;
begin
  BtnPrint.Enabled:= false;
  myPrinter.Orientation:= poLandscape;
  // adapt window to paper aspect ratio
  scaleFactor:=myPrinter.YDPI /Screen.PixelsPerInch;
  pw:= myPrinter.PageWidth;
  ph:= myPrinter.PageHeight;
  Pageratio:= ph/pw;
  PanPreview.Height:= trunc(PanPreview.width*PageRatio);
  ClientHeight:= PanPreview.Height+PanBtns.Height;
  colw:= pSize(FCalendrier.SG1.DefaultColWidth);
  rowh:= pSize(FCalendrier.SG1.DefaultRowHeight);
  myBmp:= TBitmap.Create;
  myBmp.Width:= pw;
  myBmp.Height:= ph;
  myBmp.Canvas.Brush.Color:= clWhite;//
  myBmp.Canvas.FillRect(0,0,pw, ph) ;
  myBmp.Canvas.Pen.Width:=pSize(1);
  leftMargin:= 20;
  // Important to get proper win32 Textrect
  tStyle.SystemFont:= false;
  tstyle.RightToLeft:= false;
  // center vertically
  topMargin:= (myBmp.Height-(33*rowh)) div 2;
  yb:= topMargin;
  MonthOffset:= 0;
  if Half=2 then Monthoffset:= 6 else MonthOffset:= 0;
  for aCol:= 0 to 5 do
  begin
    for arow:= 0 to FCalendrier.SG1.RowCount-1 do
    begin
      if arow=0 then // First line, months, change font size
      begin
        s:= DefaultFormatSettings.LongMonthNames[acol+1+Monthoffset];
        s[1]:= Upcase(s[1]);
        myBmp.Canvas.Font.Name:= 'Arial';
        myBmp.Canvas.Font.size:= pSize(10);
        myBmp.Canvas.Font.Style:= [fsBold];
        txtwidth:= myBmp.Canvas.TextWidth(s);
        txtheight:=myBmp.Canvas.TextHeight(s);
        x:= colw*acol+leftMargin+(colw-txtWidth)div 2;
        xl:= leftMargin+aCol*colw;
        if acol>2 then
        begin
          x:= pw-(colw*3)-leftMargin+colw*(acol-3)+(colw-txtWidth)div 2;
          xl:= pw-(colw*3)-leftMargin+colw*(acol-3);
        end;
        xr:= xl+colw;
        yt:= topMargin;
        yB:= yT+ RowH;
        y:= yt+(RowH-TxtHeight) div 2;
        // First line
        myBmp.Canvas.Brush.Color:= clBtnFace;
        myBmp.Canvas.Rectangle (xl,yt,xr,yb);
        tStyle.Alignment:= taCenter;
        tstyle.Layout:= tlCenter;
        TextRect(myBmp.Canvas, Rect(xl,yt,xr,yb), 0,0, s, tStyle);
        myBmp.Canvas.Brush.Style := bsClear;
        // Draw months rectangles
        yt:= yb;
        yb:= yt+31*rowh;
        myBmp.Canvas.Rectangle (xl,yt,xr,yb);
      end else
      begin
        myBmp.Canvas.Font.Name:= 'Arial Narrow';
        myBmp.Canvas.Font.size:= pSize(9);
        myBmp.Canvas.Font.Style:= [];
        x:= leftMargin+acol*Colw;
        if acol >2 then  x:= pw-(colw*3)-leftMargin+colw*(acol-3);
        y:= yt+Rowh*(aRow-1);
        Count:= FCalendrier.aMonths[(acol+1+Monthoffset )];
        max:= FCalendrier.aMonths[(acol + 2+Monthoffset)];
        numDay:= Count+arow-1;
        try
          curDay:= FCalendrier.Days[numDay];
        except
          exit;
        end;
        s:= Format('%d %s', [curDay.iDay, UpCase(curDay.sday[1])]);
        s1 := curDay.sSaint;
        // Sunday and feries
        if (curDay.bSunday) then
        begin
          myBmp.Canvas.Brush.Color := FCalendrier.Settings.colsunday;
        end;
        if (curDay.bferie) then
        begin
          myBmp.Canvas.Brush.Color := FCalendrier.Settings.colferie;
          s1 := curDay.sferie;
        end;
        if numday >= max then break;
        // avoid day colors to reduce top line and bottom line
        // Fill with proper colors
        if (arow=1) then mRect.Top:= y+pSize(1) else mRect.Top:= y;
        if (arow=31) then mRect.Bottom:= y+rowh-pSize(1) else mRect.Bottom:= y+rowh;
        MyBmp.Canvas.FillRect(Rect(x+pSize(1),mRect.top,x+colw-pSize(1),mRect.Bottom));
        myBmp.Canvas.Brush.Style:=bsClear;
        tstyle.Alignment:= taLeftJustify;
        tStyle.Layout:= tlCenter;
        tstyle.Wordbreak:= False;
        // draw day text
        TextRect(myBmp.Canvas, Rect(x,y,x+colw,y+rowh),x+pSize(1), 0, s+' '+s1, tStyle);
        // Holidays
        if curDay.bHoliday then
        begin
          s1:= curDay.sHoliday;
          DefBrushColor:= Brush.Color;  // pour remettre à la couleur d'origine
          myBmp.Canvas.Pen.Style:=psClear;
          myBmp.Canvas.Brush.Style:=bsSolid;
          mRect.Right:=x+colw-pSize(1);
          if (FCalendrier.CBVA.Checked) and (Pos('A', s1) > 0) then
          begin
            myBmp.Canvas.Brush.Color:= FCalendrier.Settings.colvaca;
            myBmp.Canvas.Rectangle(mRect.Right-pSize(9),mRect.Top,mRect.Right-pSize(6),mRect.Bottom);
          end;
          if (FCalendrier.CBVB.Checked) and (Pos('B', s1) > 0) then
          begin
            myBmp.Canvas.Brush.Color:= FCalendrier.Settings.colvacb;
            myBmp.Canvas.Rectangle(mRect.Right-pSize(6),mRect.Top,mRect.Right-pSize(3),mRect.Bottom);
          end;
          if (FCalendrier.CBVC.Checked) and (Pos('C', s1) > 0) then
          begin
            myBmp.Canvas.Brush.Color:= FCalendrier.Settings.colvacc;
            myBmp.Canvas.Rectangle(mRect.Right-pSize(3),mRect.Top,mRect.Right,mRect.Bottom);
          end;
          if (FCalendrier.CBVK.Checked) and (Pos('K', s1) > 0) then
          begin
            myBmp.Canvas.Brush.Color:= FCalendrier.Settings.colvack;
            myBmp.Canvas.Rectangle(mRect.Right-pSize(12),mRect.Top,mRect.Right-pSize(9),mRect.Bottom);
          end;
          myBmp.Canvas.Brush.Color:= DefBrushColor;
          myBmp.Canvas.Pen.Style:=psSolid;
        end;
        // lune
        if (FCalendrier.CBLune.Checked) and (curDay.bMoon) then
        begin
          i:= rowh-pSize(12);
          mRect.Top:= y+(i div 2); // L'image va faire 12 px
          mRect.Bottom:= y+rowh-(i div 2);
          mRect.Right:= x+colw-pSize(1);
          mRect.Left:= mRect.Right-pSize(12);
          ImgNum:= curDay.iMoonIndex;
          FCalendrier.Moonphases1.MoonImages.StretchDraw(myBmp.Canvas, ImgNum, mRect);
        end;
      end;
    end;
  end;
  // Now place image
  xl:= pSize(2)+leftMargin+colw*3;
  xr:= pw-(colw*3)-leftMargin-pSize(2);
  yt:= topMargin;
  yb:= yt+Trunc((xr-xl)*FCalendrier.ImageHalf.Height/FCalendrier.ImageHalf.Width);
  myBmp.Canvas.Rectangle(xl, yt, xr, yb);
  ImgL:= xl+pSize(1);
  ImgR:= xr-pSize(1);
  ImgT:= yt+pSize(1);
  ImgB:= yb-pSize(1);
  i:= FCalendrier.HalfImgsList.FindYearAndHalf(FCalendrier.curyear, Half);
  if i>=0 then
  begin
    Pict:= TPicture.Create;
    i:= FCalendrier.HalfImgsList.FindYearAndHalf(FCalendrier.Curyear, Half);
    ImgHalf:= FCalendrier.HalfImgsList.GetItem(i);
    if FileExists(ImgHalf.LocalCopy) then imgname:= ImgHalf.LocalCopy
    else imgname:= ImgHalf.name;
    Pict.LoadFromFile(imgname);
    myBmp.Canvas.CopyRect(Rect(ImgL, ImgT, ImgR, ImgB), Pict.Bitmap.Canvas, Rect(0,0, Pict.Width,Pict.Height));
  end;
  // Todo place title
  yt:= yb;
  yb:= yt+rowh*2;
  if Half=1 then s:= Format(FCalendrier.SPrintHalf, [FCalendrier.sFirst, FCalendrier.curyear])
  else s:= Format(FCalendrier.SPrintHalf, [FCalendrier.sSecond, FCalendrier.curyear]) ;
  myBmp.Canvas.Font.Name:= 'Arial';
  myBmp.Canvas.Font.size:= pSize(12);
  myBmp.Canvas.Font.Style:= [fsBold];
  tStyle.Alignment:= taCenter;
  myBmp.Canvas.TextRect(Rect(xl, yt+rowh, xr, yb), x,yt+rowh, s, tStyle);
  // seasons panel
  myBmp.Canvas.Font.Name:= 'Arial';
  myBmp.Canvas.Font.size:= pSize(9);
  myBmp.Canvas.Font.Style:= [];
  txtheight:= myBmp.Canvas.TextHeight('Texte');
  yb:= topMargin+32*rowh;
  yt:= yb-txtheight*5;
  myBmp.Canvas.Rectangle(xl, yt, xr, yb);
  tStyle.Alignment:= taCenter;
  tStyle.Layout:= tlTop;
  i:= pos(LineEnding, FCalendrier.LSeasons1.Caption);
  s:= Copy(FCalendrier.LSeasons1.Caption, 1, i-1);
  TextRect(myBmp.Canvas, Rect(xl, yt, xr, yb), xl, yt+txtHeight div 2, s, tStyle);
  s:= Copy(FCalendrier.LSeasons1.Caption, i+length(LineEnding), 75);
  TextRect(myBmp.Canvas, Rect(xl, yt, xr, yb), xl, yt+txtHeight+txtHeight div 2, s, tStyle);
  i:= pos(LineEnding, FCalendrier.LSeasons2.Caption);
  s:= Copy(FCalendrier.LSeasons2.Caption, 1, i-1);
  TextRect(myBmp.Canvas, Rect(xl, yt, xr, yb), xl, yt+txtHeight*2+txtHeight div 2, s, tStyle);
  s:= Copy(FCalendrier.LSeasons2.Caption, i+length(LineEnding), 75);
  TextRect(myBmp.Canvas, Rect(xl, yt, xr, yb), xl, yt+txtHeight*3+txtHeight div 2, s, tStyle);
  yb:= yt+pSize(5);
  yt:= yb-pSize(120);
  myBmp.Canvas.Font.Name:= 'Arial Narrow';
  myBmp.Canvas.Font.size:= pSize(9);
  tStyle.Alignment:= taLeftJustify;
  tStyle.Wordbreak:= true;
  tStyle.Layout:= tlTop;
  i:= 10;
  if (FCalendrier.CBVA.Checked)  then
  begin
    myBmp.Canvas.Brush.Color:= FCalendrier.CBVA.CheckColor;   ;
    MyBmp.Canvas.Rectangle(xl+pSize(5), yt+pSize(i),xl+pSize(15),yt+pSize(i+10));
    myBmp.Canvas.Brush.style:= bsClear;
    s:= FCalendrier.CBVA.Caption+' ('+FCalendrier.CBVA.Hint+')';
    TextRect(MyBmp.Canvas, Rect(xl, yt, xr, yb), xl+pSize(20),yt+pSize(i-3), s, tStyle);
    i:= i+27;
  end;
  if (FCalendrier.CBVB.Checked)  then
  begin
    myBmp.Canvas.Brush.color:= FCalendrier.CBVB.CheckColor;
    MyBmp.Canvas.Rectangle(xl+pSize(5), yt+pSize(i),xl+pSize(15),yt+pSize(i+10)  );
    myBmp.Canvas.Brush.style:= bsClear;
    s:= FCalendrier.CBVB.Caption+' ('+FCalendrier.CBVB.Hint+')';
    TextRect(MyBmp.Canvas, Rect(xl, yt, xr, yb), xl+pSize(20),yt+pSize(i-3), s, tStyle);
    i:= i+27;
  end;
  if (FCalendrier.CBVC.Checked)  then
  begin
    myBmp.Canvas.Brush.Color:= FCalendrier.CBVC.CheckColor;   ;
    MyBmp.Canvas.Rectangle(xl+pSize(5), yt+pSize(i),xl+pSize(15),yt+pSize(i+10)  );
    myBmp.Canvas.Brush.style:= bsClear;
    s:= FCalendrier.CBVC.Caption+' ('+FCalendrier.CBVC.Hint+')';
    TextRect(MyBmp.Canvas, Rect(xl, yt, xr, yb), xl+pSize(20),yt+pSize(i-3), s, tStyle);
    i:= i+27;
  end;
  if (FCalendrier.CBVK.Checked)  then
  begin
    myBmp.Canvas.Brush.color:= FCalendrier.CBVK.CheckColor;
    MyBmp.Canvas.Rectangle(xl+pSize(5), yt+pSize(i),xl+pSize(15),yt+pSize(i+10)  );
    myBmp.Canvas.Brush.style:= bsClear;
    s:= FCalendrier.CBVK.Caption+' ('+FCalendrier.CBVK.Hint+')';
    TextRect(MyBmp.Canvas, Rect(xl, yt, xr, yb), xl+pSize(20),yt+pSize(i-3), s, tStyle);
  end;
  // Display preview
  ImgPreview.Canvas.CopyRect(Rect(0, 0, ImgPreview.width, ImgPreview.height), myBmp.Canvas, Rect(0, 0, pw, mybmp.Height));
  BtnPrint.Enabled:= true;
end;



end.

