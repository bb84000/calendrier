program calendrier;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, calendrier1, calsettings, ImgResiz, lazbbaboutupdate;

{$R *.res}

begin
  RequireDerivedFormResource:=True;
  Application.Scaled:=True;
  Application.Initialize;
  Application.CreateForm(TFCalendrier, FCalendrier);
  Application.CreateForm(TAboutBox, AboutBox);
  Application.CreateForm(TPrefs, Prefs);
  Application.CreateForm(TFImgResiz, FImgResiz);
  Application.Run;
end.

