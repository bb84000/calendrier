unit Settings1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls;

type

  { TFSettings }

  TFSettings = class(TForm)
    BtnOK: TButton;
    BtnCancel: TButton;
    PnlStatus: TPanel;
    PnlStatus1: TPanel;
  private

  public

  end;

var
  FSettings: TFSettings;

implementation

{$R *.lfm}

end.

