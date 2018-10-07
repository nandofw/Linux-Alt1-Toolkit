unit main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  Menus, StdCtrls, fpjson, jsonparser, fpjsonrtti, simpleipc, process, StrUtils,
  lcltype, AsyncProcess, xlib, mainapp;

type

  { Talt1app }

  Talt1app = class(TForm)
    Alt1: TTrayIcon;
    AsyncProcess1: TAsyncProcess;
    Memo1: TMemo;
    Process1: TProcess;
    SimpleIPCServer1: TSimpleIPCServer;
    Timer1: TTimer;
    Timer2: TTimer;
    Timer3: TTimer;
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: char);
    procedure keyboardTimer(Sender: TObject);
    procedure mainmenuclick(Sender: TObject);
    procedure loadconfig();
    procedure FormShow(Sender: TObject);
    procedure SimpleIPCServer1Message(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure Timer2Timer(Sender: TObject);
    function Findapps(str: string):integer;
    procedure Timer3Timer(Sender: TObject);
  private

  public

  end;
    Tcustomapphanler = record
    url , appname , showurl: string;
    minWidth , minHeight , maxWidth , maxHeight, defaultWidth , defaultHeight, postop , posleft: integer;
    form : Tmainform;
    end;
var
  alt1app: Talt1app;
  apps : array of Tcustomapphanler;
  mainmenu : TpopupMenu;
  alt1isvisible: boolean;
  activeapp,lastactive: integer;
  px,py,pw,ph,mx,my:integer;
  isrun: boolean;
implementation

{$R *.lfm}

{ Talt1app }
  function Talt1app.Findapps(str: string):integer;
  var
  i: Integer;
  begin
  Result := -1;
   for i := Low(apps) to High(apps) do
  begin
    if (apps[i].appname = str) then
      begin
        Result := i;
        Exit;
      end;
  end;
  end;

procedure Talt1app.Timer3Timer(Sender: TObject);
var
x,z: integer;
str,id: string;
StringList: TStringList;
focus : boolean;
m:tpoint;
begin
  lastactive := lastactive + 1000;
  focus := false;
  StringList := TStringList.Create;
                                 //check if RuneScape is running
  Process1.Executable:= 'xwininfo';
  Process1.Parameters.Clear;
  Process1.Parameters.Add('-name');
  Process1.Parameters.Add('RuneScape');
  Process1.Active:=true;
  StringList.LoadFromStream(Process1.Output);
  Process1.Active:=false;
 // str:= StringList.Strings[0];
  x := StringList.Count;//pos('error', str);
  if x <> 0 then
  begin
  isrun:=true;                                           //Get the active window id
  Process1.Executable:='xprop';
  Process1.Parameters.Clear;
  Process1.Parameters.Add('-root');
  Process1.Parameters.Add('32x');
  Process1.Parameters.Add(char(39)+'\t$0'+char(39));
  Process1.Parameters.Add('_NET_ACTIVE_WINDOW');
  Process1.Active:=true;
  Process1.Parameters.Clear;
  StringList.LoadFromStream(Process1.Output);
  Process1.Active:=false;
  str:= StringList.Strings[0];
  //_NET_ACTIVE_WINDOW(WINDOW)'	0x4c00066'
  x:= pos('0x', str) ;
  id := copy(str,x,length(str)-x);
                                             //Get the active window Name
  Process1.Executable:='xprop';
  Process1.Parameters.Clear;
  Process1.Parameters.Add('-id');
  Process1.Parameters.Add(id);
  Process1.Parameters.Add('_NET_WM_NAME');
  Process1.Active:=true;
  StringList.Clear;
  StringList.LoadFromStream(Process1.Output);
  Process1.Active:=false;
  str:= StringList.Strings[0];
  x:= pos('"', str) ;
  str := copy(str,x+1,length(str)-x-1);
  if str = 'RuneScape' then  //Runescape is active
   begin
 // Absolute upper-left X:  41  3
//  Absolute upper-left Y:  24   4
 // Width: 1399              7
 // Height: 876              8
  Process1.Executable:= 'xwininfo';
  Process1.Parameters.Clear;
  Process1.Parameters.Add('-id');
  Process1.Parameters.Add(id);
  Process1.Active:=true;
  StringList.Clear;
  StringList.LoadFromStream(Process1.Output);
  Process1.Active:=false;
  str:= StringList.Strings[3];
  x:= pos(':', str) ;
  str := copy(str,x+1,length(str));
  px := strtoint(StringReplace(str, ' ', '', [rfReplaceAll]));
  str:= StringList.Strings[4];
  x:= pos(':', str) ;
  str := copy(str,x+1,length(str));
  py := strtoint(StringReplace(str, ' ', '', [rfReplaceAll]));
    str:= StringList.Strings[7];
  x:= pos(':', str) ;
  str := copy(str,x+1,length(str));
  pw := strtoint(StringReplace(str, ' ', '', [rfReplaceAll]));
  str:= StringList.Strings[8];
  x:= pos(':', str) ;
  str := copy(str,x+1,length(str));
  ph := strtoint(StringReplace(str, ' ', '', [rfReplaceAll]));
  m:= Mouse.CursorPos;
  if not((mx =m.x) and (my = m.y)) then
   begin
  lastactive := 0;
  mx:=m.x;
  my:=m.y;
   end;
  focus:= true;
  end;
  end
  else
  begin
  isrun:=false;
  end;
   x:= Length(apps);
  for z:= 0 to x-1 do
  begin
  if Assigned(apps[z].form) then
   apps[z].form.runescapeinfo(isrun,focus,lastactive,px,py,pw,ph);
  end;
  StringList.Free;
end;

  function saveapp():boolean;
  var
  x ,z: integer;
  file_str: TMemoryStream;
  str: string;
begin
  file_str := TMemoryStream.Create;
  try
  str := '{"bookmarks":[';
  x:= Length(apps);
  for z:= 0 to x-1 do
  begin
   str := str + '{"appName":"'+apps[z].appname+'"'+
   ',"absoluteUrl":"' + apps[z].url+'"'+
   ',"showAddress":"'+ apps[z].showurl+'"'+
   ',"defaultHeight":'+ inttostr(apps[z].defaultHeight)+
   ',"defaultWidth":'+inttostr(apps[z].defaultWidth)+
   ',"minWidth":'+ inttostr(apps[z].minWidth)+
   ',"minHeight":'+inttostr(apps[z].minHeight)+
   ',"maxWidth":'+ inttostr(apps[z].maxWidth )+
   ',"maxHeight":'+ inttostr(apps[z].maxHeight)+
   ',"postop":'+ inttostr(apps[z].postop )+
   ',"posleft":'+ inttostr(apps[z].posleft)+'}';
   if not (z = x-1) then
   str := str +',';
  end;
  str := str +']}';
  file_str.Write(str[1], length(str));
  file_str.SaveToFile('./Apps.json');
  finally
  file_str.Free;
  end;
  Result := true;
  end;

procedure Talt1app.mainmenuclick(Sender: TObject);
var
  id : string ;
  x :integer;
begin

  id := (Sender as TmenuItem).Caption;
  if id = 'Close Alt1' then
  begin
  saveapp();
  alt1app.close ;
  end
  else
  begin
   x:= Findapps(id);
   if not (x = -1) then
   begin
       if not Assigned(apps[x].form) then
       begin
       apps[x].form :=  TMainform.Create(nil);
       apps[x].form.Setappid(x);
       apps[x].form.Top:=apps[x].postop;
       apps[x].form.Left:=apps[x].posleft;
       apps[x].form.Height:=apps[x].defaultHeight;
       apps[x].form.Width:=apps[x].defaultWidth;
       apps[x].form.Caption:=apps[x].appname;
       sleep(50);
       apps[x].form.Loadurl(apps[x].url);
       activeapp:= x;
       end
       else
       begin
        if not apps[x].form.Visible then
        begin
        apps[x].form.Show;
        end
       end
   end;
  end;
 end;

procedure Talt1app.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin

end;

procedure Talt1app.FormCreate(Sender: TObject);
begin
  activeapp := -1;
  lastactive := 0;
  px:= 0;
  py:= 0;
  pw:= Screen.Width;
  ph:= Screen.Height;
  isrun:=false;
  mx:=Mouse.CursorPos.x;
  my:=Mouse.CursorPos.y;
end;

procedure Talt1app.FormKeyPress(Sender: TObject; var Key: char);
begin

end;

procedure Talt1app.keyboardTimer(Sender: TObject);
begin

end;

procedure Talt1app.loadconfig();
var
  x ,z: integer;
  NewItem : TMenuItem;
  Parser:TJSONParser;
  Arr:TJSONArray;
  Obj, SubObj:TJSONObject;
  file_str: TMemoryStream;
  json_str: TJSONDeStreamer;
  json_dat: TJSONStringType;

begin
  file_str := TMemoryStream.Create;
  json_str := TJSONDeStreamer.Create(nil);
   try
   file_str.LoadFromFile('./Apps.json');
   setLength(json_dat, file_str.Size);
   file_str.Read(json_dat[1], length(json_dat));
   json_str.JSONToObject(json_dat, self);
   finally
   file_str.Free;
   json_str.Free;
   end;
  Parser:= TJSONParser.Create(json_dat);
  Obj := Parser.Parse as TJSONObject;
  Arr := Obj.Arrays['bookmarks']  ;
  x:=arr.count;
  SetLength(apps,x) ;
   //create the main apphandler
  for z:= x-1 downto 0 do
  begin
  SubObj := Arr.Objects[z];
  apps[z].appname:=SubObj.Strings['appName'];
  apps[z].url:=SubObj.Strings['absoluteUrl'];
  apps[z].showurl:=SubObj.Strings['showAddress'];
  apps[z].defaultHeight:=SubObj.Integers['defaultHeight'];
  apps[z].defaultWidth:=SubObj.Integers['defaultWidth'];
  apps[z].minWidth:=SubObj.Integers['minWidth'];
  apps[z].minHeight:=SubObj.Integers['minHeight'];
  apps[z].maxWidth:=SubObj.Integers['maxWidth'];
  apps[z].maxHeight:=SubObj.Integers['maxHeight'];
  apps[z].posleft:=SubObj.Integers['posleft'];
  apps[z].postop:=SubObj.Integers['postop'];
  apps[z].form:= nil;

  end;
  //create toolbar menu
  mainmenu := TpopupMenu.Create(Self);
  for x:=0 to  Length(apps)-1 do
  begin
  NewItem := TMenuItem.Create(Self);
  NewItem.Caption := apps[x].appname;
  NewItem.OnClick := @mainmenuclick;
  mainmenu.Items.Add(Newitem);
  end;
  NewItem := TMenuItem.Create(Self);
  NewItem.Caption := 'Close Alt1';
  NewItem.OnClick := @mainmenuclick;
  mainmenu.Items.Add(Newitem);
  alt1.PopUpMenu:= mainmenu;

end;

procedure Talt1app.FormShow(Sender: TObject);
begin
 alt1app.hide;
 loadconfig();
 SimpleIPCServer1.Global:=true;
 SimpleIPCServer1.ServerID:='Alt1app';
 SimpleIPCServer1.StartServer(true);
 timer2.enabled:=true;
end;

procedure Talt1app.SimpleIPCServer1Message(Sender: TObject);
var
  ParamsArray: array of String;
  str,str2,Params : string;
  x ,z: integer;
   Count, i: Integer;
begin
  count := SimpleIPCServer1.MsgType;
  SetLength(ParamsArray, Count);
  Params:= SimpleIPCServer1.StringMessage;
  for i := 1 to Count do
  ParamsArray[i-1] := ExtractWord(i, Params, [',']);
  if (ParamsArray[0] = 'close') then
  begin
  writeln('close '+ParamsArray[1]) ;
  if not (ParamsArray[1] = '') then
  begin
   x := strtoint(ParamsArray[1])  ;
  if activeapp = x then
  activeapp:= -1;
  apps[activeapp].form.Close;
 // apps[activeapp].form.Destroy;
  apps[activeapp].form:= nil;
   end
  end
  else
  if (ParamsArray[0] = 'key') then
  begin
  writeln('keypress: '+ParamsArray[1]);
  writeln('app: '+inttostr(activeapp));
  if not (activeapp = -1) then
  begin
      if ParamsArray[1] = 'alt1' then
      begin
         apps[activeapp].form.alt1click();
      end
      else
      if ParamsArray[1] = 'alt2' then
      begin
         apps[activeapp].form.alt2click();
      end;
  end ;
  end;
end;

procedure Talt1app.Timer1Timer(Sender: TObject);
begin
  timer1.Enabled:=false;
  loadconfig();
  Alt1.Visible:=true;
  mainform.Width:= mainform.Width +1;
end;

procedure Talt1app.Timer2Timer(Sender: TObject);
var
  x:integer;
  str: string;
begin
   SimpleIPCServer1.PeekMessage(1,true);
end;

end.
