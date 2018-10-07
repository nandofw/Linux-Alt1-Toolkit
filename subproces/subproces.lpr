Program subprocess;

{$mode objfpc}{$H+}

Uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
   Interfaces, cef3lib, cef3types, cef3api, cef3own, cef3intf, Handler, Alt1,SysUtils;

Var
  Args : TCefMainArgs;
  app : ICefApp;
  t,x : integer;

begin
  CefLoadLibrary;
  app := TInternalApp.Create;
  t:=0;
  for x:=1 to argc do
   begin
   if(comparetext(argv[x-1], pchar('--type=renderer')) = 0 )then
      t:=1
      else
         if(comparetext(argv[x-1], pchar('--type=gpu-process')) = 0 )then
         t:=2
         else
             if(comparetext(argv[x-1], pchar('--type=zygote')) = 0 )then
             t:=3;

   end ;
  WriteLn('render type:= '+ inttostr(t));
  if (t = 1) then
  begin
  CefRenderProcessHandler := TCustomRenderProcessHandler.Create;
  WriteLn('CustomRenderProcessHandler.Create');
  end;

  {$IFDEF WINDOWS}
  Args.instance := HINSTANCE();

  Halt(cef_execute_process(@Args, CefGetData(app), nil));
  {$ELSE}
  Args.argc := argc;
  Args.argv := argv;

  Halt(cef_execute_process(@Args, CefGetData(app), nil));
  {$ENDIF}
end.

