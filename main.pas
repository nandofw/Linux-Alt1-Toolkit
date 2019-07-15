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



unit main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  Menus, StdCtrls, fpjson, jsonparser, fpjsonrtti, simpleipc, process, StrUtils,
  lcltype, AsyncProcess, mainapp,settings,x;

type

  { Talt1app }

  Papp = ^Tapp;
  Tapp = record
    Id : integer;
    frm: Tmainform;
  end;

  Talt1app = class(TForm)
    Alt1: TTrayIcon;
    Memo1: TMemo;
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
    function Findapps(id : integer):Papp;
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
  appid:integer;
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

 function Talt1app.Findapps(id : integer):Papp;
   var
  i: Integer;
  ap : Papp;
  begin
  Result := nil;
  for i := 0 to form1.ListBox2.Count do
  begin
    ap := Papp(form1.ListBox2.Items.Objects[i]);
      begin
        if ap^.Id = id then
          begin
            Result := ap;
            Exit;
          end;
      end;
  end;
  end;


procedure Talt1app.Timer3Timer(Sender: TObject);
var
m:tpoint;
activewin: TWindow;
i: Integer;
ap : Papp;
begin
  if Form1.ListBox1.Count > 0 then  //runescape is running
  isrun:=True
  else
  isrun:= False;
  activewin:= Form1.getfocuswindow();
  m:= Mouse.CursorPos;
  for i := 0 to form1.ListBox2.Count-1 do
  begin
    ap := Papp(form1.ListBox2.Items.Objects[i]);
    ap^.frm.runescapeinfo(isrun,activewin,m.x,m.y);
  end;
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
  ap : Papp;
begin

  id := (Sender as TmenuItem).Caption;
  if id = 'Close Alt1' then
  begin
  saveapp();
  Form1.FormClose2();
  alt1app.close ;
  end
  else
  if id = 'Settings' then
  begin
  Form1.Show;
  end
  else
  begin
   x:= Findapps(id);
   if not (x = -1) then
   begin
       if not Assigned(apps[x].form) then
       begin
       new(ap);
       inc(appid);
       ap^.Id:=appid;
       ap^.frm := TMainform.Create(nil);
      // apps[x].form :=  TMainform.Create(nil);
       ap^.frm.setrswindow(form1.getrsid());
       ap^.frm.Setappid(appid); //unique value
       ap^.frm.Top:=apps[x].postop;
       ap^.frm.Left:=apps[x].posleft;
       ap^.frm.Height:=apps[x].defaultHeight;
       ap^.frm.Width:=apps[x].defaultWidth;
       ap^.frm.Caption:=apps[x].appname;
       sleep(50);
       ap^.frm.Loadurl(apps[x].url);
       activeapp:= x;
       Form1.ListBox2.AddItem(apps[x].appname,TObject(ap));
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
  appid:=100;
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
  NewItem.Caption := 'Settings';
  NewItem.OnClick := @mainmenuclick;
  mainmenu.Items.Add(Newitem);
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
  Params : string;
  x : integer;
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
begin
   SimpleIPCServer1.PeekMessage(1,true);
end;

end.
