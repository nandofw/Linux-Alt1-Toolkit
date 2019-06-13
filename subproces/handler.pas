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

Unit Handler;

{$MODE objfpc}{$H+}

(*
 * Everything in here is called from a render process, so there is no access to GUI and all the
 * data of the main process.
 *)

Interface

Uses
  Clipbrd, LCLType,  LCLIntf, Classes, SysUtils, Graphics,
  cef3types, cef3intf, cef3ref, cef3own, cef3lib, Dialogs, Base64, BGRABitmap, BGRABitmapTypes, alt1,forms;

Type
  { Custom handler for the render process }

  { TCustomRenderProcessHandler }

  TCustomRenderProcessHandler = class(TCefRenderProcessHandlerOwn)
  protected
    // Test Window Bindings
    procedure OnContextCreated(const browser: ICefBrowser; const frame: ICefFrame; const context: ICefv8Context); override;
    // Test Extension
    procedure OnWebKitInitialized; override;
    procedure OnContextReleased(const browser: ICefBrowser;
      const frame: ICefFrame; const context: ICefV8Context); override;
    procedure OnBrowserCreated(const browser: ICefBrowser); override;
  end;

  TMyHandler = class(TCefv8HandlerOwn)
  protected
  Falt1: Talt1;

  function Execute(const name: ustring; const obj: ICefv8Value;
    const arguments: ICefv8ValueArray; var retval: ICefv8Value;
    var exception: ustring): Boolean; override;

  end;

Implementation

Var
  mystr : String;
  browser1: ICefBrowser;

{ TMyHandler }

function TMyHandler.Execute(const name : ustring; const obj : ICefv8Value;
  const arguments : ICefv8ValueArray; var retval : ICefv8Value;
  var exception : ustring) : Boolean;
var
  message : ICefProcessMessage;
begin

  if not Assigned(Falt1) then
  begin
  Falt1 := Talt1.Create;
 // WriteLn('initialize alt1');
  end;
  // return a value
  if name = 'version'  then
  retval := TCefv8ValueRef.NewString('1.0.0');
  if name = 'Getversion'  then
  begin
  retval := TCefv8ValueRef.NewString('1');
  end
  else if name = 'identifyAppUrl'  then
  begin
   retval := TCefv8ValueRef.NewString('????');
  end;
  if name = 'identifyApp'  then
  begin
   retval := TCefv8ValueRef.NewString('true');
  end
  else if name = 'getRegion'  then  //(x1,y,x2-x1,h);
  begin
  //retval := TCefv8ValueRef.NewString(capturatela(arguments[0].GetIntValue, arguments[1].GetIntValue,arguments[2].GetIntValue,arguments[3].GetIntValue) );
   retval := TCefv8ValueRef.NewString(Falt1.getRegion(arguments[0].GetIntValue, arguments[1].GetIntValue,arguments[2].GetIntValue,arguments[3].GetIntValue));

  end
  else if name = 'permissionPixel'  then  //permiçao para ver a tela
  begin
  retval := TCefv8ValueRef.NewString('true');
  end
  else if name = 'bindRegion'  then  //binda uma regiao da tela
  begin
  Falt1.bindregion(arguments[0].GetIntValue,arguments[1].GetIntValue,arguments[2].GetIntValue,arguments[3].GetIntValue) ;
  retval := TCefv8ValueRef.NewBool(true);
  end
  else if name = 'bindReadStringEx'  then  //permiçao para ver a tela
  begin
  retval := TCefv8ValueRef.NewString(
  Falt1.bindReadStringEx(
  arguments[1].GetIntValue,
  arguments[2].GetIntValue,
  arguments[3].GetStringValue));
  end
  else if name = 'bindGetRegion'  then  //retorna parte da image bindGetRegion(handle,x1,y,x2,h) aparentemente handle = 1
  begin
   //'    return bindGetRegion(handle,alt1.bindrsX + x1, alt1.bindrsY + y, x2, h);'+
  retval := TCefv8ValueRef.NewString(Falt1.bindgetregion(arguments[1].GetIntValue, arguments[2].GetIntValue,arguments[3].GetIntValue,arguments[4].GetIntValue) );
  end;
  if name = 'bindReadColorString'  then  //Retorna o texto contido na image
  begin
  retval := TCefv8ValueRef.NewString(Falt1.bindReadColorString(arguments[1].GetStringValue, arguments[2].GetIntValue,arguments[3].GetIntValue,arguments[4].GetIntValue));
  end
  else if name = 'overLaySetGroup'  then  //Retorna o texto contido na image
  begin
     message := TCefProcessMessageRef.New('SetGroup');
   message.ArgumentList.SetString(0,arguments[0].GetStringValue);
   browser1.SendProcessMessage(PID_BROWSER,message);
  end
  else  if name = 'overLayClearGroup'  then
  begin
  message := TCefProcessMessageRef.New('ClearGroup');
  message.ArgumentList.SetString(0,arguments[0].GetStringValue);
  browser1.SendProcessMessage(PID_BROWSER,message);
  end
  else  if name = 'overLayLine'  then
  begin
   //overLayLine(a,b,c,d,e,f,g)
   message := TCefProcessMessageRef.New('line');
   message.ArgumentList.SetInt(0,arguments[0].GetIntValue);
   message.ArgumentList.SetInt(1,arguments[1].GetIntValue);
   message.ArgumentList.SetInt(2,arguments[2].GetIntValue);
   message.ArgumentList.SetInt(3,arguments[3].GetIntValue);
   message.ArgumentList.SetInt(4,arguments[4].GetIntValue);
   message.ArgumentList.SetInt(5,arguments[5].GetIntValue);
   message.ArgumentList.SetInt(6,arguments[6].GetIntValue);
   browser1.SendProcessMessage(PID_BROWSER,message);
  end
  else  if name = 'overLayText'  then
  begin
   //overLayText(a,b,c,d,e,f)
   // overLayText(String str, Int32 color, Int32 size, Int32 x, Int32 y, Int32 time)
   message := TCefProcessMessageRef.New('text');
   message.ArgumentList.SetString(0,arguments[0].GetStringValue);
   message.ArgumentList.SetInt(1,arguments[1].GetIntValue);
   message.ArgumentList.SetInt(2,arguments[2].GetIntValue);
   message.ArgumentList.SetInt(3,arguments[3].GetIntValue);
   message.ArgumentList.SetInt(4,arguments[4].GetIntValue);
   message.ArgumentList.SetInt(5,arguments[5].GetIntValue);
   browser1.SendProcessMessage(PID_BROWSER,message);
  end
  else  if name = 'overLayRect'  then
  begin
   //overLayRect(a,b,c,d,e,f,g)
   // overLayRect(Int32 color, Int32 x, Int32 y, Int32 w, Int32 h, Int32 time, Int32 lineWidth)
   message := TCefProcessMessageRef.New('rect');
   message.ArgumentList.SetInt(0,arguments[0].GetIntValue);
   message.ArgumentList.SetInt(1,arguments[1].GetIntValue);
   message.ArgumentList.SetInt(2,arguments[2].GetIntValue);
   message.ArgumentList.SetInt(3,arguments[3].GetIntValue);
   message.ArgumentList.SetInt(4,arguments[4].GetIntValue);
   message.ArgumentList.SetInt(5,arguments[5].GetIntValue);
   message.ArgumentList.SetInt(6,arguments[6].GetIntValue);
   browser1.SendProcessMessage(PID_BROWSER,message);
  end
  else  if name = 'overLayFreezeGroup'  then
  begin
   message := TCefProcessMessageRef.New('FreezeGroup');
   message.ArgumentList.SetString(0,arguments[0].GetStringValue);
   browser1.SendProcessMessage(PID_BROWSER,message);
  end
  else  if name = 'overLayContinueGroup'  then
  begin
   message := TCefProcessMessageRef.New('ContinueGroup');
   message.ArgumentList.SetString(0,arguments[0].GetStringValue);
   browser1.SendProcessMessage(PID_BROWSER,message)
  end
  else if name = 'GetbindrsX' then
  begin
  retval:= TCefv8ValueRef.NewInt(falt1.bindrsX);
  end
  else if name = 'SetbindrsX' then
  begin
  falt1.bindrsX := arguments[0].GetIntValue;
  retval := TCefv8ValueRef.NewBool(true);
  end
  else if name = 'GetbindrsWidth' then
  begin
  retval:= TCefv8ValueRef.NewInt(falt1.bindrsWidth);
  end
  else if name = 'SetbindrsHeigh' then
  begin
  falt1.bindrsHeight := arguments[0].GetIntValue;
  retval := TCefv8ValueRef.NewBool(true);
  end;

  //ShowMessage('teste alt1:' + name);
  Result := True;
end;

{ TCustomRenderProcessHandler }

procedure TCustomRenderProcessHandler.OnContextCreated(const browser : ICefBrowser;
  const frame : ICefFrame; const context : ICefv8Context);
Var
  myWin : ICefv8Value;
  args  : ICefv8ValueArray;
begin

end;

procedure TCustomRenderProcessHandler.OnWebKitInitialized;
begin
end;

procedure TCustomRenderProcessHandler.OnContextReleased(
  const browser: ICefBrowser; const frame: ICefFrame;
  const context: ICefV8Context);
begin

end;

procedure TCustomRenderProcessHandler.OnBrowserCreated(
  const browser: ICefBrowser);
Var
  Code: ustring;
begin
 // WriteLn('initialize render');
  browser1:= browser;
  Code :=
  'var alt1;'+
  'if (!alt1)'+
  '  alt1 = {};'+
  '(function() {'+
  ' alt1.screenX = 0;'+
  ' alt1.screenY = 0;'+
  ' alt1.screenWidth = '+ inttostr(Screen.Width)+';'+
  ' alt1.screenHeight = '+inttostr(Screen.Height)+';'+
 // ' alt1.screenWidth = 1440;'+
  //' alt1.screenHeight = 900;'+
  ' alt1.permissionGameState= true ;'+
  ' alt1.permissionInstalled= true ;'+
  ' alt1.permissionOverlay= true ;'+
  ' alt1.permissionPixel= true ;'+
  ' alt1.version= "1.2.6" ;'+
  ' alt1.versionint= 1002006 ;'+
  ' alt1.xpCounterFound= false ;'+
  ' alt1.rsLastActive= 0 ;'+
  ' alt1.rsLinked= true ;'+
  ' alt1.rsActive = true;'+
  ' alt1.rsScaling= 1  ;'+
  ' alt1.rsX= 0 ;'+
  ' alt1.rsY= 0 ;'+
  ' alt1.rsWidth= 1440 ;'+
  ' alt1.rsHeight=900;'+
  //' alt1.bindrsX = {}; (function(){'+
  //' alt1.bindrsX.__defineGetter__(''bind_rsX'',function(){native function GetbindrsX();return GetbindrsX();});'+
  //' alt1.bindrsX.__defineSetter__(''bind_rsX'',function(b){native function SetbindrsX();if(b) SetbindrsX(b);});'+
  //' });'+
  //' alt1.bindrsY = {}; (function(){'+
  //' alt1.bindrsY.__defineGetter__(''bind_rsY'',function(){native function GetbindrsY();return GetbindrsY();});'+
  //' alt1.bindrsY.__defineSetter__(''bind_rsY'',function(b){native function SetbindrsY();if(b) SetbindrsY(b);});'+
  //' });'+
  //' alt1.bindrsWidth = {}; (function(){'+
  //' alt1.bindrsWidth.__defineGetter__(''bindrs_Width'',function(){native function GetbindrsWidth();return GetbindrsWidth();});'+
  //' alt1.bindrsWidth.__defineSetter__(''bindrs_Width'',function(b){native function SetbindrsWidth();if(b) SetbindrsWidth(b);});'+
  //' });'+
  //' alt1.bindrsHeigh = {}; (function(){'+
  //' alt1.bindrsHeigh.__defineGetter__(''bindrs_Heigh'',function(){native function GetbindrsHeigh();return GetbindrsHeigh();});'+
  //' alt1.bindrsHeigh.__defineSetter__(''bindrs_Heigh'',function(b){native function SetbindrsHeigh();if(b) SetbindrsHeigh(b);});'+
  //' });'+
  ' alt1.skinName= "default" ;'+
  ' alt1.maxtransfer= 10000000 ;'+
  ' alt1.mousePosition= 21430520 ;'+
  ' alt1.captureInterval= 1000 ;'+
  ' alt1.captureMethod= "Desktop" ;'+
  ' alt1.compatEnabled= true ;'+
  '  alt1.identifyAppUrl = function identifyAppUrl(url) {'+
  '    native function identifyAppUrl(url);'+
  '    if(url) return identifyAppUrl(url);'+
  '  };'+
  '  alt1.identifyApp=  function identifyApp(jsonstr) {'+
  '    native function identifyApp(jsonstr);'+
  '    return identifyApp(jsonstr);'+
  '  };'+
  '  alt1.getRegion= function getRegion(x1,y,x2,h){'+
  '    native function getRegion(x1,y,x2,h);'+
  '    return getRegion(x1,y,x2,h);'+
  '  };'+
  '  alt1.bindRegion=function bindRegion(x, y, w, h) {'+
  '    native function bindRegion(x, y, w, h);'+
  '    return bindRegion( x, y, w, h);'+
  '  };'+
  '  alt1.bindGetRegion= function bindGetRegion(handle,x1,y,x2,h) {'+
  '    native function bindGetRegion(handle,x1,y,x2,h);'+
  '    return bindGetRegion(handle, x1, y, x2, h);'+
  '  };'+
  '  alt1.bindReadStringEx= function bindReadStringEx(a,b,c,d) {'+
  '   native function  bindReadStringEx(a,b,c,d);'+
  '   return  bindReadStringEx(a,b,c,d);'+
  '  };'+
  '  alt1.bindReadColorString= function bindReadColorString(handle,str,color,x,y) {'+
  '    native function bindReadColorString(handle,str,color,x,y);'+
  '    return bindReadColorString(handle,str,color,x,y);'+
  '  };'+


             //overlay functions

  '  alt1.overLaySetGroup= function overLaySetGroup(x) {'+
  '  native function overLaySetGroup(x);'+
  '  overLaySetGroup(x);'+
  '  };'+
  '  alt1.overLayClearGroup= function overLayClearGroup(x) {'+
  '  native function overLayClearGroup(x);'+
  '  overLayClearGroup(x);'+
  '  };'+
  '  alt1.overLayLine= function overLayLine(a,b,c,d,e,f,g) {'+
  '  native function overLayLine(a,b,c,d,e,f,g);'+
  '  overLayLine(a,b,c,d,e,f,g);'+
  '  };'+
    '  alt1.overLayRect= function overLayRect(a,b,c,d,e,f,g) {'+
  '  native function overLayRect(a,b,c,d,e,f,g);'+
  '  overLayRect(a,b,c,d,e,f,g);'+
  '  };'+
  '  alt1.overLayText= function overLayText(a,b,c,d,e,f) {'+
  '  native function overLayText(a,b,c,d,e,f);'+
  '  overLayText(a,b,c,d,e,f);'+
  '  };'+
  '  alt1.overLayFreezeGroup= function overLayFreezeGroup(str) {'+
  '  native function overLayFreezeGroup(str);'+
  '  overLayFreezeGroup(str);'+
  '  };'+
  '  alt1.overLayContinueGroup= function overLayContinueGroup(str) {'+
  '  native function overLayContinueGroup(str);'+
  '  overLayContinueGroup(str);'+
  '  };'+
  '  alt1.addOCRFont= function addOCRFont(str1 , str2) {'+
  //'  alert(str1 + str2);'+    not implemented
  '  };'+
  '  alt1.overLayRefreshGroup = function overLayRefreshGroup (str) {'+
  '  native function overLayRefreshGroup(str);'+
  '  overLayRefreshGroup(str);'+
  '  };'+
  '  alt1.overLayImage = function overLayImage(x, y, z, a, s) {'+
  //'  alert(x, y, z, a, s);'+  not implemented
  '  };'+
  '})();';

  CefRegisterExtension('example/v8', Code, TMyHandler.Create as ICefv8Handler);

end;

end.
