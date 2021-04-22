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
    Image1: TImage;
    Image2: TImage;
    OPD1: TOpenPictureDialog;
    PanImgOrig: TPanel;
    PanImgRsizd: TPanel;
    Sel: TShape;
    procedure FormActivate(Sender: TObject);
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
    jpg: TJPEGImage;
    rec: Trect;
    InitImgWidth, initImgHeight: Integer;
    procedure Updatescore;


  public
    ImgWidth, ImgHeight: Integer;
    InitialDir, filename: String;
  end;

var
  FImgResiz: TFImgResiz;

implementation

{$R *.lfm}



{ TFImgResiz }

procedure TFImgResiz.FormActivate(Sender: TObject);
begin

end;

procedure TFImgResiz.FormCreate(Sender: TObject);
begin
  jpg:= TJPEGImage.Create;
  initImgHeight:= Image1.Height;
  InitImgWidth:= Image1.Width;
end;

procedure TFImgResiz.FormDestroy(Sender: TObject);
begin
  if assigned(jpg) then FreeAndNil(jpg);
end;

procedure TFImgResiz.FormShow(Sender: TObject);

begin

  OPD1.InitialDir:= InitialDir;
  OPD1.Filename:= filename;
  if OPD1.Execute then
  begin
    filename:= OPD1.filename;
    Image1.Height:= initImgHeight;
    Image1.Width:= InitImgWidth;
    PanImgOrig.width:= Image1.width+4;
    PanImgOrig.Height:= Image1.Height+4;
    Image2.Width:= ImgWidth;
    Image2.Height:= ImgHeight;
    PanImgRsizd.Width:= Image2.width+4;
    EFileName.Caption:=  OPD1.FileName;
    Image1.Picture.LoadFromFile(OPD1.FileName);
    ratio1:= Image1.Picture.width / Image1.Picture.height;
    ratio2:= ImgWidth / ImgHeight;
    Image2.Height:= round(Image2.width / ratio2);
    PanImgRsizd.Height:= Image2.Height+4;
    if ratio1 > ratio2 then
    begin
      Image1.width:= InitImgWidth;
      Image1.height:= round(Image1.width / ratio1);
      PanImgOrig.Height:= Image1.Height+4;
      Sel.Top:= 0;
      Sel.Height:= Image1.Height;
      Sel.Width:= Round(Sel.height * Ratio2);
      Sel.left:= (Image1.width-Sel.Width) div 2;
      sizratio:= Image1.Picture.Height/Image1.Height;
      lmargin:= Round(Sel.Left * sizratio);
      rmargin:= Round((Sel.Left * sizratio)+(Sel.Width*sizratio));
      tmargin:= 0;
      bmargin:= Round(Sel.Height*sizratio);
    end else
    begin
      Image1.Height:= initImgHeight;
      Image1.width:= round(Image1.height*ratio1);
      PanImgOrig.width:= Image1.Width+4;
      Sel.left:= 0;
      Sel.Width:= Image1.Width;
      Sel.Height:= Round(Sel.Width / Ratio2);
      Sel.Top:= (Image1.Height-Sel.Height) div 2;
      sizratio:= Image1.Picture.Width /Image1.Width;
      lmargin:= 0;
      rmargin:= Round(Sel.Width*sizratio);
      tmargin:= Round(Sel.Top * sizratio);
      bmargin:= Round((Sel.Top * sizratio)+(Sel.Height*sizratio));
    end;
    jpg.SetSize(Round(Sel.Width*sizratio), Round(Sel.Height*sizratio));
    rec1:= Rect(lmargin,tmargin,rmargin, bmargin );
    jpg.Canvas.CopyRect(Rect(0,0, jpg.width, jpg.height), image1.Picture.Bitmap.Canvas, rec1);
    Image2.Picture.Assign(jpg);
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
      if Sel.left+Sel.Width> Image1.Width then Sel.Left:= Image1.Width-Sel.Width;
    end else
    begin
      if y <> prevy then sel.top:= Sel.Top-prevy+y;
      if Sel.Top<0 then Sel.top:= 0;
      if Sel.Top+Sel.Height>Image1.Height then Sel.Top:= Image1.Height-Sel.Height;;
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
    bmargin:= jpg.height;
  end else
  begin
    lmargin:= 0;
    rmargin:= Round(Sel.Width*sizratio);
    tmargin:= Round(Sel.Top * sizratio);
    bmargin:= Round((Sel.Top * sizratio)+(Sel.Height*sizratio));
  end;
  rec1:= Rect(lmargin,tmargin,rmargin, bmargin);
  jpg.Canvas.CopyRect(Rect(0,0, jpg.width, jpg.height), image1.Picture.Bitmap.Canvas, rec1);
  Image2.Picture.Assign(jpg);

end;

Procedure TFImgResiz.Updatescore;
begin
  //lblScore.Caption:='Score:'+ IntToStr(Score);
end;

end.

