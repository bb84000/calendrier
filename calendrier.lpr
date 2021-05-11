program calendrier;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, printer4lazarus, calendrier1, calsettings, ImgResiz, lazbbaboutupdate,
  towns1, printcal;

{$R *.res}

begin
  RequireDerivedFormResource:=True;
  Application.Scaled:=True;
  Application.Initialize;
  Application.CreateForm(TFCalendrier, FCalendrier);
  Application.CreateForm(TPrefs, Prefs);
  Application.CreateForm(TAboutBox, AboutBox);
  Application.CreateForm(TFImgResiz, FImgResiz);
  Application.CreateForm(TFTowns, FTowns);
  Application.CreateForm(TFPrintCal, FPrintCal);
  Application.Run;
end.

