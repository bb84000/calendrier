unit ImgResiz;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
  ExtDlgs, Buttons;

type

  { TFImgResiz }

  TFImgResiz = class(TForm)
    BtnOK: TButton;
    BtnCancel: TButton;
    EFilename: TEdit;
    ImgOrig: TImage;
    Image2: TImage;
    LInfos: TLabel;
    OPD1: TOpenPictureDialog;
    PanImgOrig: TPanel;
    PanImgRsizd: TPanel;
    Sel: TShape;
    procedure BtnOKClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure SelMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure SelMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure SelMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
  private
    prevx, prevy: Integer;
    ratio1, ratio2: Double;
    lmargin, rmargin, tmargin, bmargin: Integer;
    rec1: Trect;
    sizratio: Double;
    bmp: Tbitmap;
    InitImgWidth, initImgHeight: Integer;
  public
    jpeg:TJPEGImage;
    ImgWidth, ImgHeight: Integer;
    InitialDir, filename: String;
  end;

var
  FImgResiz: TFImgResiz;

implementation

{$R *.lfm}



{ TFImgResiz }



procedure TFImgResiz.BtnOKClick(Sender: TObject);
begin
  jpeg.Canvas.StretchDraw (Rect(0,0,jpeg.width,jpeg.height),bmp);
end;

procedure TFImgResiz.FormCreate(Sender: TObject);
begin
  bmp:= TBitmap.Create;
  jpeg:= TJPEGImage.Create;
  initImgHeight:= ImgOrig.Height;
  InitImgWidth:= ImgOrig.Width;
end;

procedure TFImgResiz.FormDestroy(Sender: TObject);
begin
  if assigned(bmp) then FreeAndNil(bmp);
  if assigned(jpeg) then FreeAndNil(jpeg);
end;

procedure TFImgResiz.FormShow(Sender: TObject);

begin
  jpeg.SetSize(ImgWidth, ImgHeight);
  OPD1.InitialDir:= InitialDir;
  OPD1.Filename:= filename;
  if OPD1.Execute then
  begin
    // Load file
    filename:= OPD1.filename;
    // resset ImgOrig default size and panel size
    ImgOrig.Height:= initImgHeight;
    ImgOrig.Width:= InitImgWidth;
    PanImgOrig.width:= ImgOrig.width+4;
    PanImgOrig.Height:= ImgOrig.Height+4;
    Image2.Width:= ImgWidth;
    Image2.Height:= ImgHeight;
    PanImgRsizd.Width:= Image2.width+4;
    EFileName.Caption:=  OPD1.FileName;
    ImgOrig.Picture.LoadFromFile(OPD1.FileName);
    ratio1:= ImgOrig.Picture.width / ImgOrig.Picture.height;
    ratio2:= ImgWidth / ImgHeight;
    Image2.Height:= round(Image2.width / ratio2);
    PanImgRsizd.Height:= Image2.Height+4;
    if ratio1 > ratio2 then
    begin
      ImgOrig.width:= InitImgWidth;
      ImgOrig.height:= round(ImgOrig.width / ratio1);
      PanImgOrig.Height:= ImgOrig.Height+4;
      Sel.Top:= 0;
      Sel.Height:= ImgOrig.Height;
      Sel.Width:= Round(Sel.height * Ratio2);
      Sel.left:= (ImgOrig.width-Sel.Width) div 2;
      sizratio:= ImgOrig.Picture.Height/ImgOrig.Height;
      lmargin:= Round(Sel.Left * sizratio);
      rmargin:= Round((Sel.Left * sizratio)+(Sel.Width*sizratio));
      tmargin:= 0;
      bmargin:= Round(Sel.Height*sizratio);
    end else
    begin
      ImgOrig.Height:= initImgHeight;
      ImgOrig.width:= round(ImgOrig.height*ratio1);
      PanImgOrig.width:= ImgOrig.Width+4;
      Sel.left:= 0;
      Sel.Width:= ImgOrig.Width;
      Sel.Height:= Round(Sel.Width / Ratio2);
      Sel.Top:= (ImgOrig.Height-Sel.Height) div 2;
      sizratio:= ImgOrig.Picture.Width /ImgOrig.Width;
      lmargin:= 0;
      rmargin:= Round(Sel.Width*sizratio);
      tmargin:= Round(Sel.Top * sizratio);
      bmargin:= Round((Sel.Top * sizratio)+(Sel.Height*sizratio));
    end;
    bmp.SetSize(Round(Sel.Width*sizratio), Round(Sel.Height*sizratio));
    rec1:= Rect(lmargin,tmargin,rmargin, bmargin );
    bmp.Canvas.CopyRect(Rect(0,0, bmp.width, bmp.height), ImgOrig.Picture.Bitmap.Canvas, rec1);
    Image2.Picture.Assign(bmp);
  end else ModalResult:= mrCancel;

end;



procedure TFImgResiz.SelMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if Shift= [ssLeft] then
  begin
    prevx:=x;
    prevy:=y;
  end;

end;

procedure TFImgResiz.SelMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  if Shift= [ssLeft] then
    if ratio1 > ratio2 then
    begin
      if (x<>prevx) then Sel.left:= Sel.left-prevx+x;
      if Sel.left<0 then Sel.left:= 0;
      if Sel.left+Sel.Width> ImgOrig.Width then Sel.Left:= ImgOrig.Width-Sel.Width;
    end else
    begin
      if y <> prevy then sel.top:= Sel.Top-prevy+y;
      if Sel.Top<0 then Sel.top:= 0;
      if Sel.Top+Sel.Height>ImgOrig.Height then Sel.Top:= ImgOrig.Height-Sel.Height;;
    end;
end;

procedure TFImgResiz.SelMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if ratio1 > ratio2 then
  begin
    lmargin:= Round(Sel.Left * sizratio);
    rmargin:= Round((Sel.Left * sizratio)+(Sel.Width*sizratio));
    tmargin:= 0;
    bmargin:= bmp.height;
  end else
  begin
    lmargin:= 0;
    rmargin:= Round(Sel.Width*sizratio);
    tmargin:= Round(Sel.Top * sizratio);
    bmargin:= Round((Sel.Top * sizratio)+(Sel.Height*sizratio));
  end;
  rec1:= Rect(lmargin,tmargin,rmargin, bmargin);
  bmp.Canvas.CopyRect(Rect(0,0, bmp.width, bmp.height), ImgOrig.Picture.Bitmap.Canvas, rec1);
  Image2.Picture.Assign(bmp);

end;



end.

