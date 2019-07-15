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
  unit Alt1;

{$mode objfpc}{$H+}

interface

uses
  Classes, LCLType,  LCLIntf, SysUtils, ExtCtrls, BGRABitmap, BGRABitmapTypes,Base64,Graphics,ocr,StdCtrls,ipc,xshm,x,xlib;
type

{ Talt1 }

Talt1 = Class
Private
   //appname:string;
   FscreenX:integer;
   FscreenY:integer;
   FscreenWidth:integer;
   FscreenHeight:integer;
   FrsWidth:integer;
   FrsHeight:integer;
   Frsx:integer;
   Frsy:integer;
   FbindrsX:integer;
   FbindrsY:integer;
   FbindrsWhidth:integer;
   FbindrsHeight:integer;
   FcaptureInterval:integer;
   FcaptureMethod:string;
   FpermissionGameState:boolean;
   FpermissionInstalled:boolean;
   FpermissionOverlay:boolean;
   FpermissionPixel:boolean;
   Ftimer : integer;
   fkey:integer;
              //capture vars
   fcapture:integer;// 0 desktop, 1 xshm

   protected
   Procedure initilize();
   Procedure capturescreen(Sender: TObject);

   Public
   constructor Create; overload;
   destructor Destroy; override;
   Procedure bindregion(X,Y,Width,Height:integer);
   Function bindgetregion(X,Y,Width,Height:integer):string;
   Function getRegion(X,Y,Width,Height:integer):string;
   Function bindReadColorString(font:string;rgb,posx,posy:integer):string;
   Function bindReadStringEx(x,y: integer;str:string):string;
   procedure connectimg(window,key, width, height,x,y:integer);
   procedure reconnectimg(window,key, width, height,x,y:integer);

   property screenX: integer read FscreenX write FscreenX;
   property screenY: integer read FscreenY write FscreenY;
   property screenWidth: integer read FscreenWidth write FscreenWidth;
   property screenHeight: integer read FscreenHeight write FscreenHeight;
   property rsWidth: integer read FrsWidth write FrsWidth;
   property rsHeight: integer read FrsHeight write FrsHeight;
   property rsx: integer read FrsX write FrsX;
   property rsy: integer read FrsY write FrsY;

   property bindrsX: integer read FbindrsX write FbindrsX;
   property bindrsY: integer read FbindrsY write FbindrsY;
   property bindrsWidth: integer read FbindrsWhidth write FbindrsWhidth;
   property bindrsHeight: integer read FbindrsHeight write FbindrsHeight;
   property captureMethod: string read FcaptureMethod write FcaptureMethod;
   property captureInterval: integer read FcaptureInterval write FcaptureInterval default 500;
   property permissionGameState: boolean read FpermissionGameState write FpermissionGameState default true;
   property permissionInstalled: boolean read FpermissionInstalled write FpermissionInstalled default true;
   property permissionOverlay: boolean read FpermissionOverlay write FpermissionOverlay default true;
   property permissionPixel: boolean read FpermissionPixel write FpermissionPixel default true;
   end;
function XIOErrorHandler(display: PDisplay): Integer; cdecl;
function XErrorHandler(display: PDisplay; event: PXErrorEvent): Integer; cdecl;
var
  bmp : TBGRABitmap;
  MyBitmap: TPicture;
  img : PXImage;
  finfo : TXShmSegmentInfo;
  dpy : PDisplay;
Implementation



function XErrorHandler(display: PDisplay; event: PXErrorEvent): Integer; cdecl;
  Var
    error_msg: array[0..100] of Char;
  begin
    WriteLn('X error received: ');
    WriteLn(' type:         ', event^._type);
    WriteLn(' serial:       ', event^.serial);
    WriteLn(' error code:   ', event^.error_code);
    WriteLn(' request code: ', event^.request_code);
    WriteLn(' minor code:   ', event^.minor_code);
    XGetErrorText(display, event^.error_code, @error_msg, Length(error_msg));
    WriteLn(PChar(@error_msg));
    Result := 0;
  end;
   function XIOErrorHandler(display: PDisplay): Integer; cdecl;
  begin
    WriteLn('XIOErrorHandler');
    Result := 0;
  end;


constructor Talt1.Create;
begin
WriteLn('create alt1');
initilize();
end;

destructor Talt1.Destroy;
begin
//WriteLn('destroy alt1');
shmdt( finfo.shmaddr );
//XShmDetach(dpy,@finfo);
//XCloseDisplay(dpy);
//XFree(img);
bmp.Free;
free;
//WriteLn('alt1 destroy');
end;

procedure Talt1.initilize();
begin
Ftimer := 0;
//WriteLn('init');
ocr.addfont('clue','./clue.cvs',15,130,3,false);
ocr.addfont('xp','./xp.cvs',15,150,4,true);
ocr.addfont('chat','./chat.cvs',12,160,3,false);
ocr.addfontcolor('./colors.cvs');
//dpy:= XOpenDisplay(nil);
//WriteLn('init end');
end;

procedure Talt1.connectimg(window, key, width, height,x,y:integer);
var
  win_info : TXWindowAttributes;
begin
 fkey:=key;
 FrsWidth:=width;
 FrsHeight:=height;
 frsx:= x;
 frsy:= y;
 fcapture:= 1;
 finfo.shmid:= fkey;//shmget(IPC_PRIVATE, img^.bytes_per_line * h, $17f7);
 finfo.shmaddr:= shmat(finfo.shmid,nil,0);
 finfo.readOnly:= 0;
end;

procedure Talt1.reconnectimg(window, key, width, height, x, y: integer);
var
  win_info : TXWindowAttributes;
begin
 shmdt( finfo.shmaddr );
 fkey:=key;
 FrsWidth:=width;
 FrsHeight:=height;
 frsx:= x;
 frsy:= y;
 fcapture:= 1;
 finfo.shmid:= fkey;//shmget(IPC_PRIVATE, img^.bytes_per_line * h, $17f7);
 finfo.shmaddr:= shmat(finfo.shmid,nil,0);
 finfo.readOnly:= 0;
end;

procedure Talt1.capturescreen(Sender: TObject);
var
  ScreenDC: HDC;
  x ,y : integer;
  ch : ^char;
  Line: PBGRAPixel;
begin
if fcapture = 0 then
begin
 if not  Assigned(MyBitmap) then
 MyBitmap := TPicture.Create;
 ScreenDC := GetDC(0);
 MyBitmap.Bitmap.LoadFromDevice(ScreenDC);
 if not Assigned(bmp) then
 begin
 bmp := TBGRABitmap.Create(Mybitmap.Bitmap.Width,Mybitmap.Bitmap.Height) ;
 end;
 bmp.Bitmap.Canvas.CopyRect(rect(0,0,Mybitmap.Bitmap.Width,Mybitmap.Bitmap.Height),Mybitmap.Bitmap.Canvas, rect(0,0,Mybitmap.Bitmap.Width,Mybitmap.Bitmap.Height));
 ReleaseDC(0, ScreenDC);
end;
if fcapture = 1 then
begin
 //WriteLn('load img from memory');
  if not Assigned(bmp) then
  begin
  //WriteLn('create bitmap');
  bmp := TBGRABitmap.Create(FrsWidth,FrsHeight);
  end;
  if (bmp.Width <> FrsWidth) or (bmp.Height <> FrsHeight) then
  begin
  // WriteLn('recreate bitmap');
   bmp.Free;
   bmp := TBGRABitmap.Create(FrsWidth,FrsHeight);
  end;
  // WriteLn('load data bitmap');
  line := bmp.data;
  x:= bmp.NbPixels-1;
  ch := finfo.shmaddr;
  // WriteLn(x);
  // WriteLn(inttohex(integer(ch),6));
       for y:=x downto 0 do
    begin
        line^.blue:= byte(ch^);//(pixel and bluemask);
        line^.green:= byte(ch[1]);//(pixel and greenmask) >> 8;
        line^.red:= byte(ch[2]);//(pixel and redmask) >> 16;
       inc(ch,4);
       inc(line);
    end ;
      // WriteLn('done load');
end;
end;

procedure Talt1.bindregion(X,Y,Width,Height:integer);
begin
bindrsX:=X;
bindrsY:=Y;
bindrsWidth:=Width;
bindrsHeight:=Height;
end;

function Talt1.getRegion(X, Y, Width, Height: integer): string;
var
  str:  string;
  memstream: TMemoryStream;
  BytesRead:int64;
  m,z:integer;
  Line: tBGRAPixel;
begin
if datetimetotimestamp(now).Time > Ftimer then
 begin
 ftimer := datetimetotimestamp(now).Time+1000;
 capturescreen(Nil);
 end;
 //bmp.Bitmap.SaveToFile('./teste/alt1teste.bmp');
 memstream := TMemoryStream.create;
 for z:=Y to Y+Height-1 do
 begin
   for m:=X to X+Width-1  do
   begin
    Line:= bmp.GetPixel(m,z);
    memstream.WriteByte(line.blue);
    memstream.WriteByte(line.green);
    memstream.WriteByte(line.red );
    memstream.WriteByte(255);
  end;
  end;
  str := memstream.ToString;
  SetLength(str, memstream.size);
  memstream.position := 0;
  BytesRead := memstream.Read(str[1], memstream.size);
  SetLength(str, BytesRead);
  memstream.Free;
  Result := EncodeStringBase64(str);
end;

function Talt1.bindgetregion(X, Y, Width, Height: integer): string;
var
  str:  string;
  memstream: TMemoryStream;
  BytesRead:int64;
  m,z:integer;
  Line: tBGRAPixel;
  x1,y1: integer;
begin
if datetimetotimestamp(now).Time > Ftimer then
 begin
 ftimer := datetimetotimestamp(now).Time+1000;
 capturescreen(Nil);
 end;
//bmp.Bitmap.SaveToFile('./teste/alt1test.bmp');
 memstream := TMemoryStream.create;
 x1 := x + bindrsX;
 y1 := y + bindrsY;
 for z:=y1 to y1+Height-1 do
 begin
 for m:=x1 to x1+Width-1  do
   begin
    Line:= bmp.GetPixel(m,z);
    memstream.WriteByte(line.blue);
    memstream.WriteByte(line.green);
    memstream.WriteByte(line.red );
    memstream.WriteByte(255);
  end;
  end;
  str := memstream.ToString;
  SetLength(str, memstream.size);
  memstream.position := 0;
  BytesRead := memstream.Read(str[1], memstream.size);
  SetLength(str, BytesRead);
  memstream.Free;
  Result := EncodeStringBase64(str);
end;

function copybmp(x,y,w,h:integer):TBGRABitmap;   //canvasbgra not work, copy pixel per pixel
var
  px,py:integer;
  mybit: TBGRABitmap;
  line:TBGRAPixel;
begin
 MyBit := TBGRABitmap.Create(w,h) ;
 Mybit.CanvasBGRA.Brush.Color:=clRed;
 for px:= 0 to w-1 do
   begin
   for py:=0 to h-1 do
     begin
     line := bmp.GetPixel(px+x,py+y);
     mybit.SetPixel(px,py,line);
     end;
   end;
 //mybit.SaveToFile('./teste/temp'+inttostr(y)+'.bmp');
 Result:= mybit;
end;

function Talt1.bindReadColorString(font: string; rgb, posx, posy: integer
  ): string;
var
r,g,b:integer;
mybit : TBGRAbitmap;
str : string;
begin
if datetimetotimestamp(now).Time > Ftimer then
 begin
 ftimer := datetimetotimestamp(now).Time+1000;
 capturescreen(Nil);
 end;
 b:= rgb and 255;
 g:= rgb>>8 and 255;
 r:= rgb>>16 and 255;
//mybit:= TBGRABitmap.Create(380,20);
//mybit.CanvasBGRA.CopyRect(rect(0,0,380,20),bmp, rect(posx-200,posy-10,posx+380-200,posy+20-10));
//mybit.SaveToFile('./teste/temp'+inttostr(posy)+'.bmp');
mybit := copybmp(posx-200,posy-10,380,20);
str := Ocr.Readline('clue',r,g,b,mybit);
mybit.Free;
result := str;
end;

function Talt1.bindReadStringEx(x, y: integer; str: string): string;
var
mybit : TBGRAbitmap;
str2 : string;
x1,y1,w,h: integer;
begin
if datetimetotimestamp(now).Time > Ftimer then
 begin
 ftimer := datetimetotimestamp(now).Time+500;
 capturescreen(Nil);
 end;
  x1 := x + bindrsX;
  y1 := y + bindrsY-10;
  w:= bindrsWidth;
  h:= 15;
 // MyBit := TBGRABitmap.Create(w,h) ;
  //Mybit.CanvasBGRA.CopyRect(rect(0,0,w,h),bmp, rect(x1,y1,w+x1,h+y1));
  mybit:= copybmp(x1,y1,w,h);
  if (str = '{"fontname":"chat","colors":[-1]}') then
  begin
  str2 := ocr.Readline('xp',213,212,212,Mybit);
  Mybit.Free;
  if length(str2) = 0 then
  str2 := '0' ;
  str2:= '{"fragments":[{"text":"'+str2+'","color":16777215,"index":0}],"text":"'+str2+'"}' ;
  //WriteLn(str2);
  result := str2;
  end
  else
  begin
  str2 := ocr.Readchat('chat',Mybit);
  //WriteLn(str2);
  Mybit.Free;
  result := str2;
  end;
end;


end.
