unit settings;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ComCtrls,
  ExtCtrls, StdCtrls, CheckLst, x,xlib,LCLType, xshm,ipc,BGRABitmap, BGRABitmapTypes,alt1overlay,xshape;

type

  { TForm1 }
       Trsinfo = record
    x,y,w,h,key:integer
    end;


  TForm1 = class(TForm)
    CheckListBox1: TCheckListBox;
    Image1: TImage;
    Image2: TImage;
    Label1: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    ListBox1: TListBox;
    ListBox2: TListBox;
    ListBox3: TListBox;
    PageControl1: TPageControl;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    TabSheet3: TTabSheet;
    TabSheet4: TTabSheet;
    Timer1: TTimer;
    capturetimer: TTimer;
    procedure capturetimerTimer(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Label9Click(Sender: TObject);
    procedure ListBox1Click(Sender: TObject);
    procedure ListBox1DblClick(Sender: TObject);
    procedure ListBox1SelectionChange(Sender: TObject; User: boolean);
    procedure ListBox2SelectionChange(Sender: TObject; User: boolean);
    procedure ListBox3Click(Sender: TObject);
    procedure ListBox3DblClick(Sender: TObject);
    procedure ListBox3SelectionChange(Sender: TObject; User: boolean);
    procedure Timer1Timer(Sender: TObject);
    procedure FormClose2();
  private

  public
     function getrsid():integer;
     function getrskey(id:integer):integer;
     function getrsinfo(id:integer):Trsinfo;
     function getfocuswindow():TWindow;
     procedure inccount(id:integer);
     procedure deccount(id:integer);
  end;

    Trswindow = record
    id,width,height,count,key,x,y:integer ;
    img : PXImage;
    state: integer;
    info:TXShmSegmentInfo;
    end;



  function XIOErrorHandler(display: PDisplay): Integer; cdecl;
  function XErrorHandler(display: PDisplay; event: PXErrorEvent): Integer; cdecl;

var
  Form1: TForm1;

  rscapture : array[0..10] of Trswindow;
  rsid : array[0..20] of integer;
  dpy: PDisplay;
  defid,visid:integer;
  bmp : TBGRABitmap;
  vis: boolean;
  win : TWindow;
implementation
 Uses   main;
{$R *.lfm}

{ TForm1 }


function XErrorHandler(display: PDisplay; event: PXErrorEvent): Integer; cdecl;

    {$IFDEF DEBUG} Var  error_msg: array[0..100] of Char;  {$ENDIF}
  begin
    {$IFDEF DEBUG}
    WriteLn('X error received: ');
    WriteLn(' type:         ', event^._type);
    WriteLn(' serial:       ', event^.serial);
    WriteLn(' error code:   ', event^.error_code);
    WriteLn(' request code: ', event^.request_code);
    WriteLn(' minor code:   ', event^.minor_code);
    XGetErrorText(display, event^.error_code, @error_msg, Length(error_msg));
    WriteLn(PChar(@error_msg));
    {$ENDIF}
    Result := 0;
  end;
   function XIOErrorHandler(display: PDisplay): Integer; cdecl;
  begin
   // WriteLn('XIOErrorHandler');
    Result := 0;
  end;

   function TForm1.getrsid():integer;
   begin
       Result:=defid;
   end;

   function TForm1.getrskey(id:integer):integer;
   var
     x:integer;
   begin
       if id = 0 then
       Result:=0
       else
       begin
       result := 0;
        for x:=0 to 9 do
        begin
        if rscapture[x].id = id then
        begin
         result := rscapture[x].key;
         exit;
         end
        end;
       end;
   end;

   function TForm1.getrsinfo(id: integer): Trsinfo;
   var
     x:integer;
   begin
        result.key:=0;
        result.x := 0;
        result.y := 0;
        result.w := 0;
        result.h:= 0;
       if id <> 0 then
       begin
        for x:=0 to 9 do
        begin
        if rscapture[x].id = id then
        begin
        result.key:=rscapture[x].key;
        result.x := rscapture[x].x;
        result.y := rscapture[x].y;
        result.w := rscapture[x].width;
        result.h:= rscapture[x].height;
         exit;
         end
        end;
       end;
   end;

   function TForm1.getfocuswindow(): TWindow;
   var x:integer;
   begin
     XGetInputFocus(dpy,@win,@x);// get id off window focus
     result:=win;
   end;

  procedure TForm1.inccount(id:integer);
     var
     x:integer;
   begin
       if id = 0 then
       exit
       else
       begin
       for x:=0 to 9 do
       begin
       if rscapture[x].id = id then
       begin
        inc(rscapture[x].count);
        exit;
        end
       end;
       end;
   end;

  procedure TForm1.deccount(id: integer);
     var
     x:integer;
   begin
       if id = 0 then
       exit
       else
       begin
       for x:=0 to 9 do
       begin
       if rscapture[x].id = id then
       begin
        dec(rscapture[x].count);
        exit;
        end
       end;
       end;
   end;

procedure TForm1.ListBox1SelectionChange(Sender: TObject; User: boolean);
var
  x:integer;
begin
  if (ListBox1.ItemIndex >= 0)then
  begin
  x:=ListBox1.ItemIndex;
  visid := rsid[x];
  end;
  end;

procedure TForm1.ListBox2SelectionChange(Sender: TObject; User: boolean);
begin
  ListBox3.Items := ListBox1.Items;
end;

procedure TForm1.ListBox3Click(Sender: TObject);
var
  x,id:integer;
begin
  if (ListBox3.ItemIndex >= 0)then
  begin
  id := rsid[ListBox3.ItemIndex];
  for x:=0 to 9 do
  begin
  if id = rscapture[x].id then
  begin
  Overlay.overLayRect(255<<16,rscapture[x].x,rscapture[x].y,rscapture[x].width-1,rscapture[x].height-1,1000,1);
  end;
  end;
  end;

end;

procedure TForm1.ListBox3DblClick(Sender: TObject);
var
  ap: Papp;
begin
  if ListBox2.Count > 0 then
  begin
  ap := Papp(ListBox2.Items.Objects[listbox2.ItemIndex]);
  ap^.frm.changerswindow(rsid[listbox3.ItemIndex]);
  end;
end;

procedure TForm1.ListBox3SelectionChange(Sender: TObject; User: boolean);
var
  x,z:integer;
begin
  if (ListBox3.ItemIndex >= 0)then
  begin
  x:=ListBox3.ItemIndex;
  visid := rsid[x];
  z:=0;
  for x:=0 to 9 do
  begin
  if visid = rscapture[x].id then
  begin
  z:=1;
  Overlay.overLayRect(255<<16,rscapture[x].x,rscapture[x].y,rscapture[x].width,rscapture[x].height,1000,1);
  end;
  end;
  if z = 0 then
  begin
  for x:=0 to 9 do
  if (0 = rscapture[x].id)and (z = 0) then
  begin
  rscapture[x].id := visid;
  z:=1;
  end;
  end;
  end;
end;

procedure TForm1.Timer1Timer(Sender: TObject);
var
    scren : Twindow;
    x :integer;
procedure testcode(dpy: Pdisplay; sc: Twindow);
var
     sc1,sc2:Twindow;
     a,x,z ,pos:integer;
     sc3 : pwindow;
     win_name: pchar;
     info : TXWindowAttributes;
     s : TStatus;
     found : Boolean;
begin
   s:= XQueryTree(dpy,sc,@sc1,@sc2,@sc3,@a);
   if s > 0 then
   begin
   if (a > 0) then
  begin
  for x:= 0 to a-1 do
  begin
  s:= XFetchName(dpy, sc3[x], @win_name);
  if s > 0 then
  begin
  s := XGetWindowAttributes(dpy,sc3[x],@info);
  if (info.map_state = IsViewable) then
  begin
  if s > 0 then
  begin
  if (CompareStr(StrPas(win_name), 'RuneScape' )= 0) and not((info.width= 738)and( info.height = 526))then
  begin
  pos :=ListBox1.Count;
  rsid[pos]:= sc3[x] ;
  ListBox1.AddItem(StrPas(win_name),nil);
  // redirect window to offscreen to capture when the window is covered by anoter window or is minimised. Some WM not redirect by default
  // pd: Some WM unmap the window in minimised status, in this case is imposible to capture the window
  XCompositeRedirectWindow(dpy,sc3[x],0);
  //add to capture list
  found := false;
  for z:=0 to 9 do
  begin
  if sc3[x] = rscapture[z].id then
  found := true
  end;
  if  not found then
  begin
  for z:=0 to 9 do
  if (rscapture[z].id = 0)and not(found) then
  begin
  rscapture[z].id := sc3[x];
  found :=true;
  end;
  end;
  end;
  end;
  end;
  end;
  testcode(dpy, sc3[x]);
  end;
  end;
 end;
end;

begin
  scren := XDefaultRootWindow(dpy);
  ListBox1.Clear;
  testcode(dpy, scren);
  if (ListBox1.Count > 0) and (visid = 0) then
  begin
  ListBox1.ItemIndex:=0;
  defid := rsid[0];
  visid := rsid[0];
  end;
  if ListBox1.Count = 0 then
  begin
  defid :=0; //no runescape found set default rs to 0
  visid:= 0;
  end;
  if (ListBox1.Count > 0) and (visid <> 0) then
  begin
  if (PageControl1.ActivePageIndex = 0)then
  begin
  for x := 0 to ListBox1.Count -1 do
  begin
  if rsid[x] = visid then
  ListBox1.ItemIndex:=x;
  end;
  end;
  if (PageControl1.ActivePageIndex = 1) and (ListBox2.ItemIndex >= 0) then
  begin
  ListBox3.Items := ListBox1.Items;
  for x := 0 to ListBox3.Count do
  begin
  if rsid[x] = visid then
  ListBox3.ItemIndex:=x;
  end;
  end;
  end;
end;

procedure TForm1.FormShow(Sender: TObject);
begin
  vis:=true;
end;

procedure TForm1.Label9Click(Sender: TObject);
begin

end;

procedure TForm1.ListBox1Click(Sender: TObject);
var
  x,id:integer;
begin
  if (ListBox1.ItemIndex >= 0)then
  begin
  id := rsid[ListBox1.ItemIndex];
  for x:=0 to 9 do
  begin
  if id = rscapture[x].id then
  begin
  Overlay.overLayRect(255<<16,rscapture[x].x,rscapture[x].y,rscapture[x].width-2,rscapture[x].height-1,1000,1);
  end;
  end;
  end;
end;

procedure TForm1.ListBox1DblClick(Sender: TObject) ;
var
    x:integer;
begin
 if (ListBox1.ItemIndex >= 0)then
  begin
  x:=ListBox1.ItemIndex;
  defid := rsid[x];
  end;
end;

procedure TForm1.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  vis:=false;
end;

procedure TForm1.FormClose2();
var
     x:integer;
begin
  for x:=0 to 9 do
  begin
    if not( rscapture[x].id = 0) then
    begin
    rscapture[x].id:=0; //remove invalid window id, runescape has ben closed
    XFree(rscapture[x].img);
    rscapture[x].img:=nil;
    shmdt(rscapture[x].info.shmaddr);
    shmctl(rscapture[x].info.shmid,IPC_RMID,nil);
    rscapture[x].info.shmaddr:=nil;
    rscapture[x].info.shmid:=0;
    rscapture[x].count:=0;
    rscapture[x].key:=0;
   end
    end;
  XCloseDisplay(dpy);
end;

procedure TForm1.capturetimerTimer(Sender: TObject);
var
     absx, absy,x,y,w,h,z,error: integer;
     window ,dummywin: TWindow;
     scren : integer;
     ch : ^char;
   Line: PBGRAPixel;
    win_info : TXWindowAttributes;
begin

  for x:=0 to 9 do
  begin
   if ((rscapture[x].count > 0) or (visid = rscapture[x].id)) and (rscapture[x].id > 0) then
   begin
              //capture the window screen
   window :=  rscapture[x].id;
   scren := XDefaultScreen(dpy);
   error := XGetWindowAttributes(dpy, window, @win_info );
   if error > 0 then
   begin
      //no error continue
   w := win_info.width;
   h:= win_info.height;
   XTranslateCoordinates(dpy,window, RootWindow(dpy, scren) , 0 ,0 ,@absx , @absy , @dummywin);
   rscapture[x].x := absx;
   rscapture[x].y := absy;
   rscapture[x].width:=w;
   rscapture[x].height:=h;
   if(rscapture[x].img = nil )then
   begin
       //create ximage
   rscapture[x].img := XShmCreateImage(dpy,win_info.visual,24,ZPixmap,nil,@rscapture[x].info,w,h);
   rscapture[x].info.shmid:= shmget(IPC_PRIVATE, rscapture[x].img^.bytes_per_line * h, $17f6);
   rscapture[x].info.shmaddr:= shmat(rscapture[x].info.shmid,rscapture[x].img^.data,0);
   rscapture[x].img^.data:= rscapture[x].info.shmaddr;
   rscapture[x].key:= rscapture[x].info.shmid;
   rscapture[x].info.readOnly:= 0;
   XShmAttach(dpy, @rscapture[x].info);
   end;
     //check if window has resised
   if (w <> rscapture[x].img^.width) or (h <> rscapture[x].img^.height) then
   begin
           //destroy all
   XFree(rscapture[x].img);
   rscapture[x].img:=nil;
   shmdt(rscapture[x].info.shmaddr);
   shmctl(rscapture[x].info.shmid,IPC_RMID,nil);
   rscapture[x].info.shmaddr:=nil;
   rscapture[x].info.shmid:=0;
   rscapture[x].key:=0;
          //remake
   rscapture[x].img := XShmCreateImage(dpy,win_info.visual,24,ZPixmap,nil,@rscapture[x].info,w,h);
   rscapture[x].info.shmid:= shmget(IPC_PRIVATE, rscapture[x].img^.bytes_per_line * h, $3b6);
   rscapture[x].info.shmaddr:= shmat(rscapture[x].info.shmid,rscapture[x].img^.data,0);
   rscapture[x].img^.data:= rscapture[x].info.shmaddr;
   rscapture[x].key:= rscapture[x].info.shmid;
   rscapture[x].info.readOnly:= 0;
   XShmAttach(dpy, @rscapture[x].info);
   end ;
   error := XShmGetImage(dpy,window,rscapture[x].img,0,0,AllPlanes); //capture the window
   if error > 0 then
   begin
   if(vis) and ( PageControl1.ActivePageIndex = 0) and (visid = rscapture[x].id) then
   begin
   if bmp = nil then
   bmp := TBGRABitmap.Create(w,h)
   else
   if (bmp.Width <> w) or (bmp.Height <> h) then
   begin
   bmp.Free;
   bmp := TBGRABitmap.Create(w,h);
   end;
   line := bmp.data;
   ch := @rscapture[x].img^.data[0];
   z:= bmp.NbPixels-1;
   // while y < x do
     for y:=z downto 0 do
    begin
        line^.blue:= byte(ch^);//(pixel and bluemask);
        line^.green:= byte(ch[1]);//(pixel and greenmask) >> 8;
        line^.red:= byte(ch[2]);//(pixel and redmask) >> 16;
       inc(ch,4);
       inc(line);
    end ;
   Image1.Picture.Bitmap.Assign(bmp);
   end else
   if not (ListBox3.ItemIndex = -1 ) then
      if(vis) and ( PageControl1.ActivePageIndex = 1 ) and (rscapture[ListBox3.ItemIndex].id = rscapture[x].id) then
   begin
   if bmp = nil then
   bmp := TBGRABitmap.Create(w,h)
   else
   if (bmp.Width <> w) or (bmp.Height <> h) then
   begin
   bmp.Free;
   bmp := TBGRABitmap.Create(w,h);
   end;
   line := bmp.data;
   ch := @rscapture[x].img^.data[0];
   z:= bmp.NbPixels-1;
   // while y < x do
     for y:=z downto 0 do
    begin
        line^.blue:= byte(ch^);//(pixel and bluemask);
        line^.green:= byte(ch[1]);//(pixel and greenmask) >> 8;
        line^.red:= byte(ch[2]);//(pixel and redmask) >> 16;
       inc(ch,4);
       inc(line);
    end ;
   Image2.Picture.Bitmap.Assign(bmp);
   end;



   end;
   end
   else
   begin
   //changeid(rscapture[x].id,id); //change
   rscapture[x].id:=0; //remove invalid window id, runescape has ben closed
   XFree(rscapture[x].img);
   rscapture[x].img:=nil;
   shmdt(rscapture[x].info.shmaddr);
   shmctl(rscapture[x].info.shmid,IPC_RMID,nil);
   rscapture[x].info.shmaddr:=nil;
   rscapture[x].info.shmid:=0;
   rscapture[x].count:=0;
   rscapture[x].key:=0;
   end;
   if error = 0 then  // others errors
   begin
   WriteLn('Error....');
   end;
   end;
  end;
end;

procedure TForm1.FormCreate(Sender: TObject);
var
    x:integer;
begin
 XSetErrorHandler(@XErrorHandler);
 XSetIOErrorHandler(@XIOErrorHandler);
 dpy:= XOpenDisplay(nil);
 defid:=0;
 visid:=0;
 visible:=false;
 for x:=0 to 9 do
  begin
  rscapture[x].id := 0;
  rscapture[x].count :=0;
  end;
 Timer1Timer(Sender);
end;

end.

