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
maxdif:integer;
espace: integer;
shadow:boolean;
font : array of tocrfont;
end;
Tarrayinteger = array of integer;

//zfunction Readline2(fontname: string; rgb,posx,posy:integer;mybit:TPicture):String;
function Readline(fontname: string; r,g,b:integer; bmp:TBGRAbitmap):String;  // used in xptracker
Procedure addfont(fontname, filename:string;size,maxdif,espace:integer;shadow:boolean);
//function getnextline(bmp:TBGRABitmap; x,r,g,b:integer):integer;

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

Procedure addfont(fontname, filename:string;size,maxdif,espace:integer;shadow:boolean);
var
StrGrid: TStringGrid;
x,z,zz:integer;
begin
 z:=  length(font) ;
 setlength(font, z+1);
 font[z].name:= fontname;
 font[z].size:=size;
 font[z].maxdif:=maxdif;
 font[z].espace:=espace;
 font[z].shadow:=shadow;
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

function bestchar(x1,y1:integer; buff1: Tarrayinteger; bmp:TBGRABitmap;r,g,b:integer; shadow:boolean):integer;
var
diff,x,tt,n,b1,b2: integer;
aux:string;
Line: tBGRAPixel;
begin
n:=0;
tt:=0;
diff:=0;
b1:= length(buff1);
while (tt < b1) do
begin
 Line  :=bmp.GetPixel(buff1[tt]+y1,buff1[tt+1]+x1);
 diff := diff+ abs(buff1[tt+2]-(abs(line.red-r)+abs(line.blue-b)+abs(line.green-g)));
 if shadow then
 begin
 line := bmp.GetPixel(buff1[tt]+y1+1,buff1[tt+1]+x1+1);
 diff := diff+ abs(buff1[tt+3]-(abs(line.red-r)+abs(line.blue-b)+abs(line.green-g)));
 tt:=tt+4;
 end
 else
 begin
 tt:=tt+3;
 end;
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


function Readline(fontname: string; r,g,b:integer; bmp:TBGRAbitmap):String;
var
fontid,z,x,x1,x2,x3,y1,y2,pixelcount,lasty,n,nf,cc,best,ss,tt,maxdif,size,esp,m:integer;
found,first,shadow:boolean;
datastr:string;
line : tBGRAPixel;
datast: array of string;
datass: array of integer;
begin
lasty:=0;
datastr:='';
z := -1;
 for z:=0 to length(font) -1 do
 begin
 if font[z].name = fontname then
 fontid := z;
 end ;
 if not(z = -1 ) then
 begin
 m := getnextline(bmp,0,r,g,b);
 z:=0;
 first := false;
 size:= font[fontid].size;
 esp:= font[fontid].espace;
 shadow := font[fontid].shadow;
 maxdif := font[fontid].maxdif;
x1 := m+size;
x2 := m ;
while z < bmp.Width-1 do
 begin
 found:=false;
 for x := m-1 to m+12 do
          begin
          Line  :=bmp.GetPixel(z,x);
          if ((abs(line.red -r)+abs(line.green-g)+abs(line.blue-b))< maxdif)then
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
 y2 := z;
 inc(x2);
 first := false;
   //-------------------------
  pixelcount := ((x2-x1))*((y2-y1));
  if not(datastr = '')then
  begin
  if (abs(lasty-y1) > esp) then
  datastr:= datastr+' ';
  end;
  lasty:=y2 ;
  n:=0;
  for nf:=0 to length(font[fontid].font)-1 do
           begin
           if pixelcount = font[fontid].font[nf].pixelcount then
           begin
           cc := bestchar(x1,y1,font[fontid].font[nf].pixels, bmp,r,g,b,shadow);
           if (cc < 250) then
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
  best:=500;
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
   x1 := m+size;
   x2 := m ;
  end;
  inc(z)
  end;
 end;
 result := datastr;
end;

end.

