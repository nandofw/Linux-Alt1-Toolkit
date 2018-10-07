unit alt1overlay;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  strutils,lcltype;

type

  { TOverlay }

  TOverlay = class(TForm)
    Image1: TImage;
    Timer1: TTimer;
    procedure FormClick(Sender: TObject);
    procedure FormMouseEnter(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Image1MouseEnter(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private

  public
  procedure overLaySetGroup(str:string);
  procedure overLayLine(str:string) ;
  procedure overLayClearGroup(str:string);
  procedure overLayText(str:string);
  procedure overLayRect(str:string);
  procedure overLayContinueGroup(str:string);
  procedure overLayFreezeGroup(str:string);

  protected

  end;
   Toverlaypoints = record
   x,y : integer;
   end;

   { Toverlaydata }

   Toverlaydata = class
    tipo : integer; //1 = line 2 = text 3 ??
    text : string;
    color : string;
    width : integer;
    points : array of Toverlaypoints;
    time : integer; //time out?????
    constructor Create;
    destructor Destroy; override;
   end;

   { Toverlaygroup }

   Toverlaygroup = class{}
     name : string; // group name
     data : array of Toverlaydata;
     frezzed : boolean;
     constructor Create;
     destructor Destroy; override;
     procedure cleardata();
     procedure timeout(id: integer);
   end;

var
  Overlay: TOverlay;
  activeoverlay : integer;
  count,clear:integer;
  datagroup : array[0..11] of Toverlaygroup;
  newdata:boolean;

implementation

{$R *.lfm}

{ Toverlaygroup }

constructor Toverlaygroup.Create;
begin
  self.data := nil;
end;

destructor Toverlaygroup.Destroy;
begin
  inherited Destroy;
end;

procedure Toverlaygroup.cleardata();
var
  x:integer;
begin
  for x:=0 to High(Self.data) do
  self.data[x] := nil;
  SetLength(self.data,0);
  WriteLn(High(self.data));
  self.data := nil;
end;

procedure Toverlaygroup.timeout(id: integer);
var
  x,z:integer;
begin
  z:=High(Self.data);
  for x:=id to z-1 do
  self.data[x] := Self.data[x+1];
  if z = 0 then
  self.cleardata()
  else
  SetLength(Self.data,z);
end;

{ Toverlaydata }

constructor Toverlaydata.Create;
begin

end;

destructor Toverlaydata.Destroy;
begin
  SetLength(self.points,0);
  inherited Destroy;
end;

{ TOverlay }

procedure TOverlay.Timer1Timer(Sender: TObject);
var
  x,z,y: integer;
  bmp : TBitmap;
  bmp2 : TBitmap;
  x1,x2,y1,y2: integer;
begin
  for x := Low(datagroup) to High(datagroup) do
  begin
  if (not (datagroup[x].data = nil)) or (not(datagroup[x].frezzed)) then
  begin
  for z := High(datagroup[x].data) downto Low(datagroup[x].data) do
  begin
   datagroup[x].data[z].time -= 20;
  if datagroup[x].data[z].time <= 0 then
  begin
  datagroup[x].timeout(z);
  newdata:=true;
  end;
  end;
  end;
  end;
  if newdata then
  begin
//  bmp := TBitmap.Create;
  bmp2 := TBitmap.Create;
  bmp2.Monochrome:=true;
  bmp2.PixelFormat:=pf1bit;
  Write(Top);
  Write(' ');
  Write(Left);
  Write(' ');
  Write(Width);
  Write(' ');
  WriteLn(Height);
//  bmp.Width:= Width;
//  bmp.Height:=Height;
  bmp2.Width:= Width;
  bmp2.Height:=Height;
  bmp2.Canvas.Brush.Color:=clBlack;
  bmp2.Canvas.FillRect(0,0,Width,Height);
 // bmp.Canvas.Brush.Color:=clWhite;
 // bmp.Canvas.FillRect(0,0,Width,Height);
  for x :=  low(datagroup) to High(datagroup) do
  begin
  if (not (datagroup[x].data = nil)) or (not(datagroup[x].frezzed)) then
  begin
  for z :=  low(datagroup[x].data) to High(datagroup[x].data) do
  begin
  if datagroup[x].data[z].tipo = 1 then
  begin
  //bmp.Canvas.Pen.Color:=clRed;
  //bmp.Canvas.Pen.Width:=datagroup[x].data[z].width;
  //bmp.Canvas.Line(datagroup[x].data[z].points[0].x,datagroup[x].data[z].points[0].y,datagroup[x].data[z].points[1].x,datagroup[x].data[z].points[1].y);
  bmp2.Canvas.Pen.Color:=clWhite;
  bmp2.Canvas.Pen.Width:=datagroup[x].data[z].width;
  bmp2.Canvas.Line(datagroup[x].data[z].points[0].x,datagroup[x].data[z].points[0].y,datagroup[x].data[z].points[1].x,datagroup[x].data[z].points[1].y);
  end;
   if datagroup[x].data[z].tipo = 2 then
   begin
   //bmp.Canvas.Font.Color:=clWhite;
   //bmp.Canvas.Brush.Style:=bsClear;
   //bmp.Canvas.Font.Size:=datagroup[x].data[z].width;
   //bmp.Canvas.TextOut(datagroup[x].data[z].points[0].x,datagroup[x].data[z].points[0].y,datagroup[x].data[z].text);
   bmp2.Canvas.Font.Color:=clWhite;
   bmp2.Canvas.Brush.Style:=bsClear;
   bmp2.Canvas.Font.Size:=datagroup[x].data[z].width;
   bmp2.Canvas.TextOut(datagroup[x].data[z].points[0].x,datagroup[x].data[z].points[0].y,datagroup[x].data[z].text);
   end;
     if datagroup[x].data[z].tipo = 3 then  //overLayRect
  begin
  x1 := datagroup[x].data[z].points[0].x ;
  x2 := datagroup[x].data[z].points[0].y ;
  y1 := datagroup[x].data[z].points[1].x ;
  y2 := datagroup[x].data[z].points[1].y ;
  bmp2.Canvas.pen.Color:=clWhite;
  bmp2.Canvas.Pen.Width:=1;
  for y:=0 to datagroup[x].data[z].width-1 do
  begin
  bmp2.Canvas.Line(x1,x2+y,x1+y1+1,x2+y);
  bmp2.Canvas.Line(x1+y,x2,x1+y,x2+y2+1);
  bmp2.Canvas.Line(x1+y1,x2+y2-y,x1,x2+y2-y);
  bmp2.Canvas.Line(x1+y1-y,x2+y2,x1+y1-y,x2);
  end;
  end;
  end;
  end;
  end;
   Overlay.SetShape(bmp2);

 // Image1.Picture.Bitmap.Assign(bmp);
 // bmp.Free;
 // bmp2.Canvas.Brush.Color:=clBlack;
 // bmp2.Canvas.FillRect(0,0,Width,Height);
 // bmp2.Canvas.Brush.Color:=clWhite;
 // bmp2.Canvas.FillRect(0,0,1,1);
 // Overlay.SetShapeinput(bmp2);
  bmp2.Free;
  newdata:=false;
  end
end;

procedure TOverlay.FormShow(Sender: TObject);
var
  x,z: integer;
  bmp2 : TBitmap;
begin
  Parent:= nil;
  activeoverlay := 0;
  count:=0;
  bmp2 := TBitmap.Create;
  bmp2.Monochrome:=true;
  bmp2.Width:= Width;
  bmp2.Height:=Height;
  bmp2.Canvas.Brush.Color:=clBlack;
  bmp2.Canvas.FillRect(0,0,Width,Height);
   Overlay.SetShape(bmp2);
  //bmp2.Free;
  for x := Low(datagroup) to High(datagroup) do
  begin
  datagroup[x]:= Toverlaygroup.Create;
  datagroup[x].frezzed:= false;
  end;
  bmp2.Canvas.Brush.Color:=clWhite;
  bmp2.Canvas.FillRect(0,0,1,1);
  //unclicable overlay requiere a modified fpc with include suport for inputshape
  Overlay.SetShapeinput(bmp2);
  bmp2.Free;
end;

procedure TOverlay.Image1MouseEnter(Sender: TObject);
begin

end;

procedure TOverlay.FormMouseEnter(Sender: TObject);
begin

end;

procedure TOverlay.FormClick(Sender: TObject);
begin
  WriteLn('teste')
end;

procedure TOverlay.FormPaint(Sender: TObject);
begin

end;

procedure TOverlay.overLaySetGroup(str: string);
var
  x,z: integer;
  found : boolean;
begin
  WriteLn('set '+str)  ;
  found := false;
 for x := Low(datagroup) to High(datagroup) do
 if datagroup[x].name = str then
 begin
  activeoverlay := x;
  found := true;
 end;
  if not(found) then
  begin
  inc(count);
  if (count >= 9) then count := 0;
  datagroup[count].name:=str;
  activeoverlay := count;
 end;
end;

procedure TOverlay.overLayLine(str: string);
var
  Params: array of string;
  i, x : integer;
begin
 WriteLn(str) ;
  //alt1.overLayLine('red', 2, 10, 10, 100, 100, 1000);
  SetLength(Params, 7);
  for i := 1 to 7 do
  Params[i-1] := ExtractWord(i , str ,[',']);
  x :=  High(datagroup[activeoverlay].data)+1;
  SetLength(datagroup[activeoverlay].data,x+1);
  datagroup[activeoverlay].data[x] := Toverlaydata.Create;
  datagroup[activeoverlay].data[x].color:= Params[0];
  datagroup[activeoverlay].data[x].tipo:= 1;
  datagroup[activeoverlay].data[x].width:=StrToInt(Params[1]);
  SetLength(datagroup[activeoverlay].data[x].points , 2);
  datagroup[activeoverlay].data[x].points[0].x:=strtoint(Params[2])-Left;
  datagroup[activeoverlay].data[x].points[0].y:=strtoint(Params[3])-top;
  datagroup[activeoverlay].data[x].points[1].x:=strtoint(Params[4])-Left;
  datagroup[activeoverlay].data[x].points[1].y:=strtoint(Params[5])-top;
  datagroup[activeoverlay].data[x].time:=strtoint(Params[6]);
  newdata:=true;
end;





procedure TOverlay.overLayClearGroup(str: string);
var
  x : integer;
begin

  for x := Low(datagroup) to High(datagroup) do
  begin
 // WriteLn('cp '+str+' '+datagroup[x].name);
  if (CompareStr(datagroup[x].name, str) = 0) then
  begin
  datagroup[x].cleardata();
  end
  end ;
  Timer1Timer(nil);
end;
  //   if not(clear = -1 ) then
  //begin
  //
  //clear := -1;
  //end;
procedure TOverlay.overLayText(str:string);
var
  Params: array of string;
  i, x : integer;
begin
// alt1.overLayText("" + n, a1lib.mixcolor(255, 255, 255), 20, knot.reader.pos.x + x + 6, knot.reader.pos.y + y, 7000);
  WriteLn(str);
  SetLength(Params, 6);
  for i := 1 to 6 do
  Params[i-1] := ExtractWord(i , str ,[',']);
  x :=  High(datagroup[activeoverlay].data)+1;
  SetLength(datagroup[activeoverlay].data,x+1);
  datagroup[activeoverlay].data[x] := Toverlaydata.Create;
  datagroup[activeoverlay].data[x].text:=Params[0];
  datagroup[activeoverlay].data[x].color:= Params[1]; //text color
  datagroup[activeoverlay].data[x].tipo:= 2;  // type text
  datagroup[activeoverlay].data[x].width:=StrToInt(Params[2]); //text size
  SetLength(datagroup[activeoverlay].data[x].points , 1);
  datagroup[activeoverlay].data[x].points[0].x:=strtoint(Params[3])-Left;
  datagroup[activeoverlay].data[x].points[0].y:=strtoint(Params[4])-top;
  datagroup[activeoverlay].data[x].time:=strtoint(Params[5]);
  newdata:=true;
end;

procedure TOverlay.overLayRect(str: string);
var
  Params: array of string;
  i, x : integer;
begin
  //	alt1.overLayRect('red', x, y, width, height, 2000, 1);
  WriteLn(str);
  SetLength(Params, 7);
  for i := 1 to 7 do
  Params[i-1] := ExtractWord(i , str ,[',']);
  x :=  High(datagroup[activeoverlay].data)+1;
  SetLength(datagroup[activeoverlay].data,x+1);
  datagroup[activeoverlay].data[x] := Toverlaydata.Create;
  datagroup[activeoverlay].data[x].color:= Params[0];
  datagroup[activeoverlay].data[x].tipo:= 3;
  datagroup[activeoverlay].data[x].width:=StrToInt(Params[6]);
  SetLength(datagroup[activeoverlay].data[x].points , 2);
  datagroup[activeoverlay].data[x].points[0].x:=strtoint(Params[1])-Left;
  datagroup[activeoverlay].data[x].points[0].y:=strtoint(Params[2])-top;
  datagroup[activeoverlay].data[x].points[1].x:=strtoint(Params[3]); //width
  datagroup[activeoverlay].data[x].points[1].y:=strtoint(Params[4]); //heigth
  datagroup[activeoverlay].data[x].time:=strtoint(Params[5]);
  newdata:=true;
end;

procedure TOverlay.overLayContinueGroup(str: string);
var
  x : integer;
begin
  for x := Low(datagroup) to High(datagroup) do
  begin
  if (CompareStr(datagroup[x].name, str) = 0) then
  begin
  datagroup[x].frezzed:= false;
  newdata:=true;
  end
  end
end;

procedure TOverlay.overLayFreezeGroup(str: string);
var
  x : integer;
begin
  for x := Low(datagroup) to High(datagroup) do
  begin
  if (CompareStr(datagroup[x].name, str) = 0) then
  begin
  datagroup[x].frezzed:= true;
  newdata:=true;
  end
  end
end;

end.

