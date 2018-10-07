Unit mainapp;

{$MODE objfpc}{$H+}

Interface

Uses
  Classes, SysUtils, simpleipc, FileUtil, Forms, Controls, Graphics, Dialogs,
  StdCtrls, LCLType, ExtCtrls, Menus, Buttons, cef3types, cef3lib, cef3intf,
  cef3lcl, cef3context, cef3gui, LazUTF8, LazFileUtils, RTTICtrls, strutils; // custom render process handler

Type

  { Tmainform }

  Tmainform = class(TForm)
    Button1: TButton;
    Chromium: TChromium;
    Edit1: TEdit;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    Panel4: TPanel;
    Panel5: TPanel;
    PopupMenu1: TPopupMenu;
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    SpeedButton3: TSpeedButton;
    procedure ChromiumAddressChange(Sender: TObject;
      const Browser: ICefBrowser; const Frame: ICefFrame; const url: ustring);
    procedure ChromiumBeforeContextMenu(Sender: TObject;
      const Browser: ICefBrowser; const Frame: ICefFrame;
      const params: ICefContextMenuParams; const model: ICefMenuModel);
    procedure ChromiumConsoleMessage(Sender: TObject;
      const Browser: ICefBrowser; const message, Source: ustring;
      line: Integer; out Result: Boolean);
    procedure ChromiumContextMenuCommand(Sender: TObject;
      const Browser: ICefBrowser; const Frame: ICefFrame;
      const params: ICefContextMenuParams; commandId: Integer;
      eventFlags: TCefEventFlags; out Result: Boolean);
    procedure ChromiumJsdialog(Sender: TObject; const Browser: ICefBrowser;
      const originUrl: ustring; dialogType: TCefJsDialogType;
      const messageText, defaultPromptText: ustring; callback: ICefJsDialogCallback;
      out suppressMessage: Boolean; out Result: Boolean);
    procedure ChromiumLoadEnd(Sender: TObject; const Browser: ICefBrowser;
      const Frame: ICefFrame; httpStatusCode: Integer);
    procedure ChromiumProcessMessageReceived(Sender: TObject;
      const Browser: ICefBrowser; sourceProcess: TCefProcessId;
      const message: ICefProcessMessage; out Result: Boolean);
    procedure ChromiumTakeFocus(Sender: TObject; const Browser: ICefBrowser;
      next_: Boolean);
    procedure FormChangeBounds(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure FormCreate(Sender : TObject);
    procedure FormResize(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormWindowStateChange(Sender: TObject);
    procedure MenuItem1Click(Sender: TObject);
    procedure MenuItem2Click(Sender: TObject);
    procedure Panel1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Panel1MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer
      );
    procedure Panel1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure PopupMenu1Popup(Sender: TObject);
    procedure SpeedButton1ChangeBounds(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
    procedure SpeedButton3Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure Setappid(id:integer);
    procedure alt1click();
    procedure alt2click();
    procedure Loadurl(url:string);
    procedure runescapeinfo(isrun,focus:boolean;lastactive,px,py,pw,ph:integer);
  private
    { private declarations }
    mousex,mousey, formx, formy, sl,sh,sw,appid: integer;
    m , minimised,aceptdata: boolean;
    furl: string;
  public
    { public declarations }
    captureinterval : String;
  end;

Var
  mainform : Tmainform;

Implementation
Uses main,alt1overlay;

{$R *.lfm}
var
  Path: ustring;
{ Tmainform }


 procedure Tmainform.Setappid(id:integer);
 begin
  appid:=id;
  writeln(appid);
 end;

 procedure Tmainform.alt1click();
 begin
 Chromium.Browser.GetMainFrame.ExecuteJavaScript('alt1onrightclick('+chr(39) +')none'+chr(39)+');','none',0);
 writeln('keypress: alt1');
 end;

 procedure Tmainform.alt2click();
 begin
 writeln('keypress: alt1');
 end;

 procedure Tmainform.Loadurl(url: string);
 begin
   furl:=url ;
   Chromium.Load(url);
 end;

  procedure Tmainform.runescapeinfo(isrun, focus: boolean; lastactive, px, py,
   pw, ph: integer);
 var
   str: string;
 begin
   if aceptdata then
   begin
   str:= 'alt1.rsX = '+inttostr(px)+';alt1.rsY = '+inttostr(py)+';alt1.rsWidth = '+inttostr(pw)+'; alt1.rsHeight = '+inttostr(ph)+';';
     if focus then
     str := str +'alt1.rsActive = true;'
     else
     str := str +'alt1.rsActive = false;';
     if isrun then
     str := str +'alt1.rsLinked = true;'
     else
     str := str +'alt1.rsLinked = false;';
     str := str +'alt1.rsLastActive = '+ inttostr(lastactive)+';';
     Chromium.Browser.GetMainFrame.ExecuteJavaScript(str,'none',0);
   end;
 end;

procedure Tmainform.ChromiumBeforeContextMenu(Sender: TObject;
  const Browser: ICefBrowser; const Frame: ICefFrame;
  const params: ICefContextMenuParams; const model: ICefMenuModel);
begin
  model.AddItem(7241221,'inspecionar elemento');
  model.AddItem(666,'reload');
end;

procedure Tmainform.ChromiumAddressChange(Sender: TObject;
  const Browser: ICefBrowser; const Frame: ICefFrame; const url: ustring);
begin
  edit1.Text:=url;
end;

procedure Tmainform.ChromiumConsoleMessage(Sender: TObject;
  const Browser: ICefBrowser; const message, Source: ustring; line: Integer;
  out Result: Boolean);
begin

end;


procedure Tmainform.ChromiumContextMenuCommand(Sender: TObject;
  const Browser: ICefBrowser; const Frame: ICefFrame;
  const params: ICefContextMenuParams; commandId: Integer;
  eventFlags: TCefEventFlags; out Result: Boolean);
var
mousePoint: TCefPoint;
mouse: pCefPoint;
client: ICefClient;
setting: TCefBrowserSettings;
 inspectElementAt: PCefPoint;
 Info: TCefWindowInfo;

begin
  result := false;
  if (commandId = 666) then
   begin
    Chromium.Browser.ReloadIgnoreCache;
    result := true;
   end;
  if (commandId = 7241221) then
   begin
    mouse := new(pCefPoint);
    mouse^.x := params.XCoord;
    mouse^.y := params.YCoord;
    FillChar(info, SizeOf(info), 0);
    info.parent_window := 0;
    info.x := Integer(50);
    info.y := Integer(50);
    info.width := Integer(1000);
    info.height := Integer(600);
    client := nil;
    FillChar(setting, SizeOf(setting), 0);
    setting.size := SizeOf(setting);
    Chromium.Browser.GetHost.ShowDevTools(Info, client , setting, mouse );
    result := true;
   end;
end;

procedure Tmainform.ChromiumJsdialog(Sender: TObject; const Browser: ICefBrowser;
  const originUrl: ustring; dialogType: TCefJsDialogType;
  const messageText, defaultPromptText: ustring; callback: ICefJsDialogCallback;
  out suppressMessage: Boolean; out Result: Boolean);
var
  Params: array of string;
  i : integer;
begin
  If dialogType = JSDIALOGTYPE_ALERT then
  begin
  SetLength(Params, 2);
  for i := 1 to 2 do
  Params[i-1] := ExtractWord(i , messageText,[':']);
     if Params[0] = '1'then
     Overlay.overLaySetGroup(Params[1])
     else if Params[0] = '2' then
     Overlay.overLayClearGroup(Params[1])
     else if Params[0] = '3' then
     Overlay.overLayLine(Params[1])
     else if Params[0] = '4' then
     Overlay.overLayText(Params[1]);
    callback.Cont(True, '');
    Result := True;
  end
  Else
  begin
    suppressMessage := False;
    Result := False;
  end;
end;

procedure Tmainform.ChromiumLoadEnd(Sender: TObject;
  const Browser: ICefBrowser; const Frame: ICefFrame; httpStatusCode: Integer);
begin
   aceptdata := true;
   Chromium.Browser.GetMainFrame.ExecuteJavaScript('checkonalt1 = true;','none',0);
end;

procedure Tmainform.ChromiumProcessMessageReceived(Sender: TObject;
  const Browser: ICefBrowser; sourceProcess: TCefProcessId;
  const message: ICefProcessMessage; out Result: Boolean);
var
  Params: array of string;
  i : integer;
begin
  SetLength(Params, 2);
  Params[0] := ExtractWord(1 , message.GetName,['=']);
  Params[1] := ExtractWord(2 , message.GetName,['=']);
     if Params[0] = '1'then
     begin
     Overlay.overLaySetGroup(Params[1]);
       Result := True;
     end
     else
     if Params[0] = '2' then
     begin
     Overlay.overLayClearGroup(Params[1]) ;
      Result := True;
     end
     else if Params[0] = '3' then
     begin
     Overlay.overLayLine(Params[1]);
      Result := True;
     end
     else if Params[0] = '4' then
     begin
     Overlay.overLayText(Params[1]);
       Result := True;
     end
     else if Params[0] = '5' then
     begin
     Overlay.overLayRect(Params[1]);
       Result := True;
     end
     else if Params[0] = '6' then
     begin
     Overlay.overLayFreezeGroup(Params[1]);
       Result := True;
     end
     else if Params[0] = '7' then
     begin
     Overlay.overLayContinueGroup(Params[1]);
     Result := True;
     end;
end;

procedure Tmainform.ChromiumTakeFocus(Sender: TObject;
  const Browser: ICefBrowser; next_: Boolean);
begin

end;

procedure Tmainform.FormChangeBounds(Sender: TObject);
begin
  if not (appid = -1) then
  Chromium.updateposition()
  else
  Chromium.updateposition()
end;

procedure Tmainform.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  // Chromium.Free;
end;

procedure Tmainform.FormCloseQuery(Sender: TObject; var CanClose: boolean);
begin
     Chromium.Browser.Host.CloseBrowser(false);
end;

procedure Tmainform.FormCreate(Sender: TObject);
begin
  appid :=-1;
  minimised:= false;
  aceptdata:= false;
end;

procedure Tmainform.FormResize(Sender: TObject);
begin

end;

procedure Tmainform.FormShow(Sender: TObject);
begin

end;

procedure Tmainform.FormWindowStateChange(Sender: TObject);
begin
  WriteLn(appid);
end;

procedure Tmainform.MenuItem1Click(Sender: TObject);
begin
  if (Overlay.Visible) then
  begin
  Overlay.Visible:=false;
  MenuItem1.Caption:= 'Enable overlay';
  end
  else
  begin
  Overlay.Visible:= true;
  MenuItem1.Caption:= 'Disable overlay';
  end
end;

procedure Tmainform.MenuItem2Click(Sender: TObject);
begin
  if (Panel5.Visible) then
  begin
  Panel5.Visible:=false;
  MenuItem2.Caption:= 'Show Adressbar';
  end
  else
  begin
  Panel5.Visible:= true;
  MenuItem2.Caption:= 'Hide Adressbar';
  end
end;

procedure Tmainform.Panel1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
 m := true;
 mousex := Mouse.CursorPos.X;
 mousey := Mouse.CursorPos.Y;
 formy := Top;
 formx := Left;
 WriteLn(appid);
end;

procedure Tmainform.Panel1MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
     if m then
  begin
  Top:=formy + (Mouse.CursorPos.Y - mousey);
  Left:=formx + (Mouse.CursorPos.X - mousex);
  end;
end;

procedure Tmainform.Panel1MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
 m := false;
end;

procedure Tmainform.PopupMenu1Popup(Sender: TObject);
begin
   if (Overlay.Visible) then
   MenuItem1.Caption:= 'Disable overlay'
  else
   MenuItem1.Caption:= 'Enable overlay';
end;

procedure Tmainform.SpeedButton1ChangeBounds(Sender: TObject);
begin

end;

procedure Tmainform.SpeedButton1Click(Sender: TObject);
begin
 PopupMenu1.PopUp;
end;

procedure Tmainform.SpeedButton2Click(Sender: TObject);
begin
 if not minimised then
 begin
  sh := height;
  sl := left;
  sw := width;
  width := 55;
  height := 17;
  left := sl + sw - 55;
  minimised:= true;
 end
 else
 begin
   height := sh;
   width := sw;
   left := sl;
   minimised:= false;
 end;
end;

procedure Tmainform.SpeedButton3Click(Sender: TObject);
begin
if not (appid = -1) then
 begin
 apps[appid].posleft:= left;
 apps[appid].postop:= top;
 apps[appid].defaultHeight:= Height;
 apps[appid].defaultWidth:= Width;
 apps[appid].form:= nil;
 if activeapp = appid then
 activeapp:= -1;
 Free;
 end
 else
 begin
 mainform.close;
 end;
end;

procedure Tmainform.Timer1Timer(Sender: TObject);
begin

end;

 Initialization
  Path := GetCurrentDirUTF8 + PathDelim;
  CefResourcesDirPath := Path ;
  CefLocalesDirPath := Path + 'locales';
  CefCachePath:= Path + 'cache';
  CefBrowserSubprocessPath := Path + 'subproces'{$IFDEF WINDOWS}+'.exe'{$ENDIF};
  CefInitialize;

end.

