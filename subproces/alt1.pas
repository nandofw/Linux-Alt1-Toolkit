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
  Classes, LCLType,  LCLIntf, SysUtils, ExtCtrls, BGRABitmap, BGRABitmapTypes,Base64,Graphics,ocr,StdCtrls;
type
Talt1 = Class
Private
   //appname:string;
   FscreenX:integer;
   FscreenY:integer;
   FscreenWidth:integer;
   FscreenHeight:integer;
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
   property screenX: integer read FscreenX write FscreenX;
   property screenY: integer read FscreenY write FscreenY;
   property screenWidth: integer read FscreenWidth write FscreenWidth;
   property screenHeight: integer read FscreenHeight write FscreenHeight;
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

var
  bmp : TBGRABitmap;
  MyBitmap: TPicture;
Implementation

constructor Talt1.Create;
begin
WriteLn('create alt1');
initilize();
end;

destructor Talt1.Destroy;
begin
WriteLn('destroy alt1');
bmp.Free;
free;
end;

Procedure Talt1.initilize();
begin
Ftimer := 0;
if not Assigned(bmp) then
//bmp := TBGRAbitmap.Create;
ocr.addfont('clue','./clue.cvs',15,130,3,false);
ocr.addfont('xp','./xp.cvs',15,150,4,true);
ocr.addfont('chat','./testchat.cvs',15,160,3,false);
ocr.addfontcolor('./colors.cvs');
end;

Procedure Talt1.capturescreen(Sender: TObject);
var

  ScreenDC: HDC;
begin
 if not  Assigned(MyBitmap) then
 MyBitmap := TPicture.Create;
 ScreenDC := GetDC(0);
 MyBitmap.Bitmap.LoadFromDevice(ScreenDC);
 if not Assigned(bmp) then
 begin
 bmp.free;
 bmp := TBGRABitmap.Create(Mybitmap.Bitmap.Width,Mybitmap.Bitmap.Height) ;
 end;
 bmp.Bitmap.Canvas.CopyRect(rect(0,0,Mybitmap.Bitmap.Width,Mybitmap.Bitmap.Height),Mybitmap.Bitmap.Canvas, rect(0,0,Mybitmap.Bitmap.Width,Mybitmap.Bitmap.Height));

 ReleaseDC(0, ScreenDC);
 //mybitmap.free;
end;

procedure Talt1.bindregion(X,Y,Width,Height:integer);
begin
bindrsX:=X;
bindrsY:=Y;
bindrsWidth:=Width;
bindrsHeight:=Height;
end;

Function Talt1.getRegion(X,Y,Width,Height:integer):string;
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

Function Talt1.bindgetregion(X,Y,Width,Height:integer):string;
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

Function Talt1.bindReadColorString(font:string;rgb,posx,posy:integer):string;
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
mybit:= TBGRABitmap.Create(380,20);
mybit.CanvasBGRA.CopyRect(rect(0,0,380,20),bmp, rect(posx-200,posy-10,posx+380-200,posy+20-10));
str := Ocr.Readline('clue',r,g,b,mybit);
mybit.Free;
result := str;
end;

Function Talt1.bindReadStringEx(x,y: integer;str:string):string;
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
  //WriteLn(str);//debug data
  MyBit := TBGRABitmap.Create(w,h) ;
  Mybit.CanvasBGRA.CopyRect(rect(0,0,w,h),bmp, rect(x1,y1,w+x1,h+y1));
 // mybit.SaveToFile('./teste/temp'+inttostr(y)+'.bmp');
  if (str = '{"fontname":"chat","colors":[-1]}') then
  begin
  str2 := ocr.Readline('xp',213,212,212,Mybit);
  Mybit.Free;
  if length(str2) = 0 then
  str2 := '0' ;
  str2:= '{"fragments":[{"text":"'+str2+'","color":16777215,"index":0}],"text":"'+str2+'"}' ;
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
