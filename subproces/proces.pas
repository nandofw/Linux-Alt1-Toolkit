unit proces;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, cef3types, cef3lib, cef3intf, cef3lcl, Handler;

type

  { Tsubprocess }

  Tsubprocess = class(TForm)
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private

  public

  end;

var
  subprocess: Tsubprocess;

implementation

{$R *.lfm}

{ Tsubprocess }

procedure Tsubprocess.FormCreate(Sender: TObject);
begin
    // No subprocess here
  // If you want to use a subprocess, this CefRenderProcessHandler has to be registered in subprocess
  CefRenderProcessHandler := TCustomRenderProcessHandler.Create;
end;

procedure Tsubprocess.FormShow(Sender: TObject);
begin
 subprocess.hide;
end;

end.

