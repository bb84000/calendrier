unit printcal;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, PrintersDlgs, Printers,
  ExtCtrls, StdCtrls, calsettings;

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
    procedure PanBtnsClick(Sender: TObject);
    procedure RBChange(Sender: TObject);
  private
    half: Integer;
    myPrinter: Tprinter;
    myBmp: Tbitmap;
    //  bmpHeight: Integer;
    procedure SetBitmap;
  public

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
  Half:= FCalendrier.Half;
  RB1.Checked:= true;
  if half=2 then RB2.Checked:= true;
  RB1.Onchange:= @RBChange;
  RB2.OnChange:= @RBChange;
  CBPrinters.OnChange:= @CBPrintersChange;
  SetBitmap;
end;

procedure TFPrintCal.BtnPrintClick(Sender: TObject);
begin
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

procedure TFPrintCal.PanBtnsClick(Sender: TObject);
begin

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

procedure TFPrintCal.SetBitmap;
var

  pw, ph: Integer;
  //scale: Integer;
  scaleFactor: Double;
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
begin
  BtnPrint.Enabled:= false;
  myPrinter.Orientation:= poLandscape;
  // adapt window to paper aspect ratio
  pw:= myPrinter.PageWidth;
  ph:= myPrinter.PageHeight;
  Pageratio:= ph/pw;
  PanPreview.Height:= trunc(PanPreview.width*PageRatio);
  ClientHeight:= PanPreview.Height+PanBtns.Height;
  scaleFactor:=myPrinter.YDPI div Screen.PixelsPerInch;
  colw:= Trunc((FCalendrier.SG1.DefaultColWidth)*scaleFactor);
  rowh:= Trunc((FCalendrier.SG1.DefaultRowHeight)*scaleFactor);
  myBmp:= TBitmap.create;
  myBmp.Width:= pw;
  myBmp.Height:= ph;
  myBmp.Canvas.Brush.Color:= clWhite;
  myBmp.Canvas.FillRect(0,0,pw, ph) ;
  myBmp.Canvas.Pen.Width:=2;
  leftMargin:= 20;
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
        myBmp.Canvas.Font.size:= Trunc(10*scalefactor);
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
        myBmp.Canvas.TextOut(x,y,s);
        myBmp.Canvas.Brush.Style := bsClear;
        // Draw months rectangles
        yt:= yb;
        yb:= yt+31*rowh;
        myBmp.Canvas.Rectangle (xl,yt,xr,yb);
      end else
      begin
        myBmp.Canvas.Font.Name:= 'Arial Narrow';
        myBmp.Canvas.Font.size:= trunc(9*scalefactor-1);
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
        s:= ' '+IntToStr(curDay.iDay)+ ' ' + UpCase(curDay.sday[1]);
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
        MyBmp.Canvas.FillRect(Rect(x+trunc(scalefactor),y,x+colw-trunc(scalefactor),y+rowh-trunc(scalefactor)));
        myBmp.Canvas.Brush.Style:=bsClear;
        tstyle.Alignment:= taLeftJustify;
        tStyle.Layout:= tlCenter;
        myBmp.Canvas.TextRect(Rect(x,y,x+colw,y+rowh),x+trunc(scalefactor), 0, s+' '+s1, tStyle);
        // lune
        if (FCalendrier.CBLune.Checked) and (curDay.bMoon) then
        begin
          i:= rowh-12*trunc(scalefactor);
          mRect.Top:= y+(i div 2); //+(aRect.Bottom-aRect.Top-12) div 2;    // L'image va faire 12 px
          mRect.Bottom:= y+rowh-(i div 2); //aRect.Top+ 12;
          mRect.Right:= x+colw-trunc(scalefactor); //aRect.Right-2;                                 // Espace de 2 px à droite
          mRect.Left:= mRect.Right-12*trunc(scalefactor);
          ImgNum:= curDay.iMoonIndex;
          FCalendrier.Moonphases1.MoonImages.StretchDraw(myBmp.Canvas, ImgNum, mRect);
        end;
      end;
     end;

  end;
  // Now place image  Todo change half image
  xl:= Trunc(ScaleFactor*2)+leftMargin+colw*3;
  xr:= pw-(colw*3)-leftMargin-Trunc(ScaleFactor*2);
  yt:= topMargin;
  yb:= yt+Trunc((xr-xl)*FCalendrier.ImageHalf.Height/FCalendrier.ImageHalf.Width);
  myBmp.Canvas.Rectangle(xl, yt, xr, yb);
  ImgL:= xl+Trunc(ScaleFactor);
  ImgR:= xr-Trunc(ScaleFactor);
  ImgT:= yt+Trunc(ScaleFactor);
  ImgB:= yb-Trunc(ScaleFactor);
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
  // Todo place title and
  yt:= yb;
  yb:= yt+rowh*2;
  tStyle.Alignment:= taCenter;
  tStyle.Layout:= tlCenter;
  s:= InttoStr(half)+'e semestre '+InttoStr(FCalendrier.curyear);
  myBmp.Canvas.Font.Name:= 'Arial';
  myBmp.Canvas.Font.size:= Trunc(12*scalefactor);
  myBmp.Canvas.TextRect(Rect(xl, yt, xr, yb), 0,0, s, tStyle);
  // seasons panel
  yt:= topMargin+29*rowh;
  yb:= topMargin+32*rowh;
  myBmp.Canvas.Rectangle(xl, yt, xr, yb);
  i:= pos(LineEnding, FCalendrier.LSeasons1.Caption);
  s:= Copy(FCalendrier.LSeasons1.Caption, 1, i);
  myBmp.Canvas.Font.Name:= 'Arial';
  myBmp.Canvas.Font.size:= Trunc(8*scalefactor);
  txtheight:= myBmp.Canvas.TextHeight('Texte');
  myBmp.Canvas.TextOut(xl+Trunc(4*scaleFactor), yt+(txtheight div 2), s);
  s:= Copy(FCalendrier.LSeasons1.Caption, i, 75);
  myBmp.Canvas.TextOut(xl+Trunc(4*scaleFactor), yt+(txtheight*2), s);
  i:= pos(LineEnding, FCalendrier.LSeasons2.Caption);
  s:= Copy(FCalendrier.LSeasons2.Caption, 1, i);
  myBmp.Canvas.TextOut(xl+Trunc(4*scaleFactor)+(xr-xl) div 2, yt+(txtheight div 2), s);
  s:= Copy(FCalendrier.LSeasons2.Caption, i, 75);
  myBmp.Canvas.TextOut(xl+Trunc(4*scaleFactor)+(xr-xl) div 2, yt+(txtheight*2), s);
  ImgPreview.Canvas.CopyRect(Rect(0, 0, ImgPreview.width, ImgPreview.height), myBmp.Canvas, Rect(0, 0, pw, mybmp.Height));    BtnPrint.Enabled:= true;
end;



end.

