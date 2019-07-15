program alt1linux;

{$mode objfpc}{$H+}
{.$DEFINE DEBUG}
uses

  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, runtimetypeinfocontrols, main,mainapp,simpleipc, alt1overlay, settings;

var
 Client: TSimpleIPCClient;

 {$R *.res}
begin

 client := TSimpleIPCClient.Create(nil);
 client.ServerID:='Alt1app';
 if client.ServerRunning then
 begin
 Client.Active:=true;
 Client.SendStringMessage(2,'key,'+argv[1]);
 client.Free;
 Application.ShowMainForm:=false;
 Application.Terminate;
 end
 else
 begin
  client.Free;
  RequireDerivedFormResource:=true;
  Application.Initialize;
  Application.CreateForm(Talt1app, alt1app);
  Application.CreateForm(Tmainform, mainform);
  Application.CreateForm(TOverlay, Overlay);
  Application.CreateForm(TForm1, Form1);
  Application.Run;
  end;
end.

