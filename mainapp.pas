(*
 *                      Alt1 Toolkit Linux
 *
 * This Source Code Form is subject to the terms of the GNU General Public License v3.0.
 *
 * Author:     dev.nandofw@gmail.com
 * Repository: https://github.com/nandofw/Linux-Alt1-Toolkit
 *
 *
 * Based on 'Alt1 Toolkit' by Skyllbert
 * Site: https://runeapps.org
 *
 *)


Unit mainapp;

{$MODE objfpc}{$H+}

Interface

Uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs,
  StdCtrls, LCLType, ExtCtrls, Menus, Buttons, cef3types, cef3lib, cef3intf,
  cef3lcl, cef3ref, LazUTF8, LazFileUtils, RTTICtrls, BGRABitmap,settings,x; // custom render process handler

Type

  { Tmainform }

  Tmainform = class(TForm)
    Button1: TButton;
    Chromium: TChromium;
    Edit1: TEdit;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    Panel4: TPanel;
    Panel5: TPanel;
    PopupMenu1: TPopupMenu;
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    SpeedButton3: TSpeedButton;
    procedure Button1Click(Sender: TObject);
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
    procedure MenuItem3Click(Sender: TObject);
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
    procedure Setappid(id:integer);
    procedure alt1click();
    procedure alt2click();
    procedure Loadurl(url:string);
    procedure runescapeinfo(isrun:boolean;activewin:twindow;px,py:integer);
    procedure setrswindow(rsw:twindow);
    procedure changerswindow(rsw:twindow);
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
  lastactive : integer;
  rswin : twindow;
  rsinfo: Trsinfo;
Implementation
Uses main,alt1overlay;

{$R *.lfm}
var
  Path: ustring;
{ Tmainform }


 procedure Tmainform.Setappid(id:integer);
 begin
  appid:=id;
  //writeln(appid);
 end;

 procedure Tmainform.alt1click();
 begin
 Chromium.Browser.GetMainFrame.ExecuteJavaScript('alt1onrightclick('+chr(39) +')none'+chr(39)+');','none',0);
 //writeln('keypress: alt1');
 end;

 procedure Tmainform.alt2click();
 begin
 //writeln('keypress: alt1');
 end;

 procedure Tmainform.Loadurl(url: string);
 begin
   furl:=url ;
   Chromium.Load(url);
 end;

  procedure Tmainform.runescapeinfo(isrun:boolean;activewin:twindow;px,py:integer);
 var
   str: string;
   msg : ICefProcessMessage;
   info : Trsinfo;
 begin
   if aceptdata then
   begin
   str:= '';
     if rswin = activewin then
     begin
     lastactive := 0;
     str := str +'alt1.rsActive = true;';
     end
     else
     begin
     str := str +'alt1.rsActive = false;';
     inc(lastactive, 1000);
     end;
     if rswin <> 0 then
     str := str +'alt1.rsLinked = true;'
     else
     str := str +'alt1.rsLinked = false;';
     str := str +'alt1.rsLastActive = '+ inttostr(lastactive)+';';
     Chromium.Browser.GetMainFrame.ExecuteJavaScript(str,'none',0);
   end;
   info := form1.getrsinfo(rswin);
   if ((not(info.key = rsinfo.key) or not(info.x = rsinfo.x) or not(info.y = rsinfo.y)) and (info.key <> 0)) then //if rs has moved or resized send new settings
   begin
    msg := TCefProcessMessageRef.New('newsettings');
    msg.ArgumentList.Setint(0,rswin);
    msg.ArgumentList.Setint(1,info.key);
    msg.ArgumentList.Setint(2,info.w);
    msg.ArgumentList.Setint(3,info.h);
    msg.ArgumentList.Setint(4,info.x);
    msg.ArgumentList.Setint(5,info.y);
    Chromium.Browser.SendProcessMessage( PID_RENDERER ,msg); //send new capture settings
    rsinfo := info;
   end;
 end;

  procedure Tmainform.setrswindow(rsw: twindow);
  begin
    rswin:=rsw;
    Form1.inccount(rsw);
  end;

  procedure Tmainform.changerswindow(rsw: twindow);
  var
      msg : ICefProcessMessage;
      info :Trsinfo;
  begin
    if not(rswin = rsw) then //windos capture changed tell render process
    begin
    info:= form1.getrsinfo(rsw);
    msg := TCefProcessMessageRef.New('newsettings');
    msg.ArgumentList.Setint(0,rsw);
    msg.ArgumentList.Setint(1,info.key);
    msg.ArgumentList.Setint(2,info.w);
    msg.ArgumentList.Setint(3,info.h);
    msg.ArgumentList.Setint(4,info.x);
    msg.ArgumentList.Setint(5,info.y);
    form1.deccount(rswin);
    Form1.inccount(rsw);
    Chromium.Browser.SendProcessMessage( PID_RENDERER ,msg); //send new capture settings
    rswin:=rsw;
    rsinfo := info;
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

procedure Tmainform.Button1Click(Sender: TObject);
begin
  Chromium.Load(edit1.Text);
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
mouse: pCefPoint;
client: ICefClient;
setting: TCefBrowserSettings;
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
begin
  If dialogType = JSDIALOGTYPE_ALERT then
  begin
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
  arg : iceflistValue;
  msg : ICefProcessMessage;
  x:integer;
  info : Trsinfo;
begin
  arg :=  message.GetArgumentList;
case message.name of
    'line':
    begin
    Overlay.overLayLine(arg.GetInt(0),arg.GetInt(1),arg.GetInt(2),arg.GetInt(3),arg.GetInt(4),arg.GetInt(5),arg.GetInt(6));
    Result := True;
    end ;
    'text':
    begin
    Overlay.overLayText(arg.GetString(0),arg.GetInt(1),arg.GetInt(2),arg.GetInt(3),arg.GetInt(4),arg.GetInt(5));
    Result := True;
    end ;
    'rect':
    begin
    Overlay.overLayRect(arg.GetInt(0),arg.GetInt(1),arg.GetInt(2),arg.GetInt(3),arg.GetInt(4),arg.GetInt(5),arg.GetInt(6));
    Result := True;
    end;
    'FreezeGroup':
    begin
    Overlay.overLayFreezeGroup(arg.GetString(0));
    Result := True;
    end ;
    'ContinueGroup':
    begin
    Overlay.overLayContinueGroup(arg.GetString(0));
    Result := True;
    end;
     'ClearGroup':
    begin
    Overlay.overLayClearGroup(arg.GetString(0));
    Result := True;
    end;
      'SetGroup':
    begin
    Overlay.overLaySetGroup(arg.GetString(0));
    Result := True;
    end;
    'RefreshGroup':
    begin
    Overlay.overLayRefreshGroup(arg.GetString(0));
    Result := True;
    end;
      'connect':
    begin
    msg := TCefProcessMessageRef.New('settings');
    info:= form1.getrsinfo(rswin);
    msg.ArgumentList.Setint(0,rswin);
    msg.ArgumentList.Setint(1,info.key);
    msg.ArgumentList.Setint(2,info.w);
    msg.ArgumentList.Setint(3,info.h);
    msg.ArgumentList.Setint(4,info.x);
    msg.ArgumentList.Setint(5,info.y);
    Form1.inccount(rswin);
    rsinfo := info;
    Browser.SendProcessMessage( PID_RENDERER ,msg);
    Result := True;
    end;
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
 // WriteLn(appid);
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

procedure Tmainform.MenuItem3Click(Sender: TObject);
begin
 form1.show;
end;

procedure Tmainform.Panel1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
 m := true;
 mousex := Mouse.CursorPos.X;
 mousey := Mouse.CursorPos.Y;
 formy := Top;
 formx := Left;
 //WriteLn(appid);
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
var
  ap :Papp;
begin
if not (appid = -1) then
 begin
  form1.deccount(rswin);
  ap:=alt1app.Findapps(appid);
  Form1.ListBox2.Items.Delete(Form1.ListBox2.Items.IndexOfObject(TObject(ap)));
   if activeapp = appid then
 activeapp:= -1;
  ap^.frm.Free;
  Dispose(ap);
 end
 else
 begin
 mainform.close;
 end;
end;

 Initialization
  Path := GetCurrentDirUTF8 + PathDelim;
  CefResourcesDirPath := Path ;
  CefLocalesDirPath := Path + 'locales';
  CefCachePath:= Path + 'cache';
  CefBrowserSubprocessPath := Path + 'subproces';
  CefInitialize;

end.

