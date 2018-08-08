unit Ocr;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils,BGRABitmap, BGRABitmapTypes, Grids,Graphics;

type
//Pocrfont = ^Tocrfont;
Tocrfont = record
char : String;
pixelcount : integer;
pixels : array of integer;
end;

ocrfont = record
name : string;
size : integer;
font : array of tocrfont;
end;
Tarrayinteger = array of integer;

function Readline(fontname: string; rgb,posx,posy:integer;mybit:TPicture):String;
Procedure addfont(fontname, filename:string; size:integer);

var
font : array of ocrfont;



implementation


function strtoarray(str:string): Tarrayinteger;
var
buff1 : array of integer;
tt,n : integer;
aux: string;
begin
 n:=0;
 aux:='';
 for tt:=1 to length(str) do
          begin
          if str[tt] = ',' then
          begin
          setlength(buff1,n+1);
          buff1[n]:=strtoint(aux);
          aux :='';
          inc(n);
          end
          else
          begin
          aux := aux + copy(str,tt,1);
          end
          end;
 result := buff1;
end;

Procedure addfont(fontname,filename:string; size:integer);
var
StrGrid: TStringGrid;
x,z,zz:integer;
begin
 z:=  length(font) ;
 setlength(font, z+1);
 font[z].name:= fontname;
 font[z].size:=size;
 Strgrid := TStringGrid.create(nil);
 strgrid.LoadFromCSVFile(filename,',');
 for x:=1 to strgrid.RowCount-1 do
 begin
    zz := length(font[z].font);
    setlength(font[z].font, zz+1);
    font[z].font[zz].char:= strgrid.Rows[x].ValueFromIndex[0];
    font[z].font[zz].pixelcount:=strtoint(strgrid.Rows[x].ValueFromIndex[2]);
    font[z].font[zz].pixels:= strtoarray(strgrid.Rows[x].ValueFromIndex[3]);
 end;
 strgrid.Free;
end;

function bestchar(x1,y1:integer; buff1: Tarrayinteger; bmp:TBGRABitmap;r,g,b:integer):integer;
var
diff,tt,b1: integer;
Line: tBGRAPixel;
begin
tt:=0;
diff:=0;
b1:= length(buff1)-1;
while (tt < b1) do
begin
 Line  :=bmp.GetPixel(buff1[tt]+y1,buff1[tt+1]+x1);
 diff := diff+ abs(buff1[tt+2]-(abs(line.red-r)+abs(line.blue-b)+abs(line.green-g)));
 tt:=tt+3;
end;
result := diff;
end;

function getnextline(bmp:TBGRABitmap; x,r,g,b:integer):integer;
var
found:boolean;
m,z:integer;
Line: tBGRAPixel;
begin
found := false;
m:=x;
while m < bmp.Height-1  do
begin
z:=0;
while z < bmp.Width-1 do
 begin
   Line  :=bmp.GetPixel(z,m);
   if (abs(line.red -r)+abs(line.green-g)+abs(line.blue-b)< 100)then
   begin
   found := true;
   break;
   end ;
   inc(z);
   end;
if(found)then
break;
inc(m)
end;
 result := m;
end;

function Readline(fontname: string; rgb,posx,posy:integer;mybit:TPicture):String;
var
fontid,z,x,x1,x2,y1,y2,pixelcount,lasty,n,nf,cc,best,ss,tt,cwt:integer;
r,g,b,m:integer;
found,first:boolean;
datastr:string;
line : tBGRAPixel;
datast: array of string;
datass: array of integer;
bmp : TBGRAbitmap;
begin
b:= rgb and 255;
g:= rgb>>8 and 255;
r:= rgb>>16 and 255;
lasty:=0;
datastr:='';
bmp:= TBGRABitmap.Create(380,20);
bmp.Bitmap.Canvas.CopyRect(rect(0,0,380,20),Mybit.Bitmap.canvas, rect(posx-200,posy-10,posx+380-200,posy+20-10));
z := -1;
 for z:=0 to length(font) -1 do
 begin
 if font[z].name = fontname then
 fontid := z;
 end ;
 if not(z = -1 ) then
 begin
 cwt:= font[fontid].size;
 z:=0;
 m:=getnextline(bmp,0,r,g,b);
 first := false;
 x1 := m+cwt;
 x2 := m ;
 while z < bmp.Width-1 do
  begin
  found:=false;
  for x := m-1 to m+cwt do
           begin
           Line  :=bmp.GetPixel(z,x);
           if ((abs(line.red -r)+abs(line.green-g)+abs(line.blue-b))< 100)then
              begin
              found := true;
              if x1 > x then
              x1:= x;
              if x2 < x then
              x2 := x;
              end;
           end;
  if (found) and not(first) then
  begin
  first := true;
  y1:= z;
  end ;
  if (not(found) and first) then
  begin
  y2:=z;
  first := false;
  pixelcount:= (y2-y1)*(x2-x1);
  if (abs(lasty-y1) > 3) and not(datastr ='') then
  datastr:= datastr+' ';
  lasty:=y2 ;
  n:=0;
  for nf:=0 to length(font[fontid].font)-1 do
           begin
           if pixelcount = font[fontid].font[nf].pixelcount then
           begin
           cc := bestchar(x1,y1,font[fontid].font[nf].pixels, bmp,r,g,b);
           if (cc < 300) then
           begin
           setlength(datast,n+1);
           setlength(datass,n+1);
           datast[n]:= font[fontid].font[nf].char;
           datass[n]:=cc;
           inc(n);
           end;
           end;
           end;
  if not(n=0) then
  begin
  best:=300;
  ss:=-1;
  for tt:= 0 to n-1 do
           begin
           if datass[tt] < best then
           begin
           best:=datass[tt];
           ss:= tt;
           end;
            end;
  if not(ss = -1) then
  begin
  datastr:= datastr + datast[ss];
  end;
  end;
  first:=false;
  x1 := m+cwt;
  x2 := m ;
  end;
  inc(z)
  end;
  end;
 //bmp.SaveToFile('./teste/ocr.bmp');  //debug
 bmp.Free;
 result := datastr;
end;

end.

