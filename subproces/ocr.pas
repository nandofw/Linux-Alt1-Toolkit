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



unit Ocr;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils,BGRABitmap, BGRABitmapTypes, Grids,Graphics;

type
//Pocrfont = ^Tocrfont;
Tocrfont = record
char : String;
Width: integer;
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

Tfontcolor = record
r:integer;
g:integer;
b:integer;
r1:integer;
g1:integer;
b1:integer;
end;

Tarrayinteger = array of integer;

//zfunction Readline2(fontname: string; rgb,posx,posy:integer;mybit:TPicture):String;
function Readline(fontname: string; r,g,b:integer; bmp:TBGRAbitmap):String;  // used in xptracker
function Readchat(fontname: string; bmp:TBGRAbitmap):String;  // used to read the chat or others
function Readchatline(fontname: string; r,g,b,r1,g1,b1:integer; bmp:TBGRAbitmap;var pos,score,px: integer):String;  // used in xptracker
Procedure addfont(fontname, filename:string;size,maxdif,espace:integer;shadow:boolean);
Procedure addfontcolor(filename:string);
//function getnextline(bmp:TBGRABitmap; x,r,g,b:integer):integer;

var
font : array of ocrfont;
fontcolor : array of Tfontcolor;


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
    font[z].font[zz].Width:= strtoint(strgrid.Rows[x].ValueFromIndex[1]);
    font[z].font[zz].pixelcount:=strtoint(strgrid.Rows[x].ValueFromIndex[2]);
    font[z].font[zz].pixels:= strtoarray(strgrid.Rows[x].ValueFromIndex[3]);
 end;
 strgrid.Free;
end;


Procedure addfontcolor(filename:string);
var
StrGrid: TStringGrid;
x,z,zz:integer;
begin
 Strgrid := TStringGrid.create(nil);
 strgrid.LoadFromCSVFile(filename,',');
 for x:=1 to strgrid.RowCount-1 do
 begin
    zz := High(fontcolor)+1;
    setlength(fontcolor, zz+1);
    fontcolor[zz].r:= strtoint(strgrid.Rows[x].ValueFromIndex[0]);
    fontcolor[zz].g:=strtoint(strgrid.Rows[x].ValueFromIndex[1]);
    fontcolor[zz].b:= strtoint(strgrid.Rows[x].ValueFromIndex[2]);
    fontcolor[zz].r1:= strtoint(strgrid.Rows[x].ValueFromIndex[3]);
    fontcolor[zz].g1:=strtoint(strgrid.Rows[x].ValueFromIndex[4]);
    fontcolor[zz].b1:= strtoint(strgrid.Rows[x].ValueFromIndex[5]);
 end;
 strgrid.Free;
end;

function bestchar(x1,y1:integer; buff1: Tarrayinteger; bmp:TBGRABitmap;r,g,b:integer; shadow:boolean):integer;
var
diff,x,tt,n,b1,b2,pc: integer;
aux:string;
Line: tBGRAPixel;
begin
n:=0;
tt:=0;
diff:=0;
pc:=1;
b1:= length(buff1);
while (tt < b1) do
begin
 Line  :=bmp.GetPixel(buff1[tt]+y1,buff1[tt+1]+x1);
 diff := diff+ abs(buff1[tt+2]-(abs(line.red-r)+abs(line.blue-b)+abs(line.green-g)));
 inc(pc);
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
result := diff div pc;
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
 end else
 begin
 datastr:='font not found'
 end;
 result := datastr;
end;

function Readchatline(fontname: string; r, g, b,r1,g1,b1: integer; bmp: TBGRAbitmap;var pos,score,px: integer): String;
var
fontid,z,x,x1,x2,x3,y1,y2,pixelcount,lasty,n,nf,cc,best,ss,tt,maxdif,size,esp,m,count:integer;
found,first,shadow:boolean;
datastr:string;
line : tBGRAPixel;
datast: string;
datass: array of integer;
begin
count:=0 ;
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
 m := 2;
 z:=0;
 first := false;
 size:= font[fontid].size;
 esp:= font[fontid].espace;
 shadow := font[fontid].shadow;
 maxdif := font[fontid].maxdif div 3;
x1 := m+size;
x2 := m ;
lasty := pos; //added
z := pos;
y1 := z;
y2 := z;
while z < bmp.Width-1 do
 begin
 found:=false;
 for x := m-1 to m+size do
          begin
          Line  :=bmp.GetPixel(z,x);
          if ((abs(line.red -r)< maxdif) and (abs(line.green-g)< maxdif) and (abs(line.blue-b) < maxdif))then
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
  pixelcount := ((x2-x1)*(y2-y1));
  n:=0;
  best := 80;
  datast:='';
  for nf:=0 to length(font[fontid].font)-1 do
           begin
           if pixelcount = font[fontid].font[nf].pixelcount then
           begin
           cc := bestchar(x1,y1,font[fontid].font[nf].pixels, bmp,r1,g1,b1,shadow);
           if (cc < best) then
           begin
           best:=cc;
           n:=1;
           datast := font[fontid].font[nf].char;
           end;
           end;
           end;
  if not(n=0) then
  begin
  if not(datastr = '')then
  begin
  if (abs(lasty-y1) > esp) then
  datastr:= datastr+' ';
  end
  else
  begin
  px := y1;
  end;
  lasty:=y2 ;
  datastr:= datastr + datast;
  score := score + best;
  inc(count);
  end;
  first:=false;
  x1 := m+size;
  x2 := m ;
  end;
 if (abs(z-lasty) > 15) or (abs(y2-y1) > 9) then
 begin
 result := datastr;
 score := trunc(score / count);
 pos := lasty;
 exit;
 end;
 inc(z);
 end;
end;
pos := lasty;
score := trunc(score / count) ;
result := datastr;
end;

function validtimestamp(str:string):string;
const
  n = ['0'..'9','-',':',' ','[',']'];
var
x,z:integer; v:boolean;
begin
v:=true;
z := Length(str);
for x:=1 to z do
if not(str[x] in n )then v:=false;
 if(v)then
  result := StringReplace(str,' ', '', [rfReplaceAll])
 else
  result := str;
end;

function Readchat(fontname: string; bmp:TBGRAbitmap):String;
var
r,g,b,r1,g1,b1,r2,g2,b2 : integer; //defined in font colors
m,ts,x1,x2,nf,fc,gg,cc,ini,fin:integer;
str,aux1,aux2,aux3:string;
badscore: boolean;
begin
m := 1;
str:='';
aux1:='';
aux2:='';
aux3:='';
fc := High(fontcolor)+1; //font color count
while m < bmp.Width-1 do
 begin
 ts:=0;
 ini := 400;
 x2 := bmp.Width;
 badscore:= true;
 nf := 0;
 while nf < fc do
  begin
  r:= fontcolor[nf].r;
  g:= fontcolor[nf].g;
  b:= fontcolor[nf].b;
  r2:= fontcolor[nf].r1;
  g2:= fontcolor[nf].g1;
  b2:= fontcolor[nf].b1;
  x1 := bmp.Width;
  gg:= m-1;
  cc:= 0;//
  aux1:= Readchatline(fontname,r,g,b,r2,g2,b2,bmp,gg,cc,x1);
  if not (aux1 = '') then
  begin
  if cc <= ini then
  begin
  if x1 <= x2 then
  begin
  x2 := x1;
  ini := cc;
  badscore:=false;
  fin := gg;
  aux2:= aux1;
  r1:=r2;
  g1:=g2;
  b1:=b2;
  if (ini < 10) then
  nf := fc;
  end;
  end;
  end;
  inc(nf);
  end;
 if not (badscore) then
 begin
 str := validtimestamp(str);
 str := str + aux2;
 if aux3 = '' then
 begin
 aux3 := '{"text":"'+aux2+'","color":'+inttostr(((r1<<16)+(g1<<8)+(b1)+0))+',"index":'+inttostr(x2)+'}';
 end
 else
 begin
 aux3 := aux3 + ',{"text":"'+aux2+'","color":'+inttostr(((r1<<16)+(g1<<8)+(b1)+0))+',"index":'+inttostr(x2)+'}';
 end ;
 aux2 := '';
 m := fin;
 end
 else
 begin
 m:= m +10;
 end;
 inc(m);
 end;
//WriteLn('text: '+ str);
result := '{"fragments":['+aux3+'],"text":"'+str+'"}'
end;

end.

