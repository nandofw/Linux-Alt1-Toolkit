unit liboverlay;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils,x,xlib,xshape,xfixes,forms,LCLType,xutil,Cairo,CairoXlib;


function XIOErrorHandler(display: PDisplay): Integer; cdecl;
function XErrorHandler(display: PDisplay; event: PXErrorEvent): Integer; cdecl;
function libinitoverlay(w,h:integer):Boolean;
procedure liboverlayfree();
procedure liboverlayline(col1,x1,y1,x2,y2,w:integer);
procedure liboverLayrectangle(col1,x,y,w,h,wi:integer);
procedure liboverLayTextOut(col,x,y,w:integer;txt:string);
procedure liboverlayupdate();
procedure liboverlayevent();
procedure liboverlayclear();

var
  dpy : PDisplay;
  g_win: TWindow;
  black,red,white:TXColor;
  g_screen,g_disp_width,g_disp_height:integer;
  g_bmp,g_shape: TPixmap;
  sevb,serb:integer;
  gc,maskgc,maskgcback:TGC;
  event : TXEvent;
   gcv:TXGCValues;
     atr: TXSetWindowAttributes;
     font: PXFontStruct;
     cr : pcairo_t;
     surf : pcairo_surface_t;
implementation

function XErrorHandler(display: PDisplay; event: PXErrorEvent): Integer; cdecl;
  Var
    error_msg: array[0..100] of Char;
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

function libinitoverlay(w,h:integer): Boolean;
var
  mask:Integer;
  bgcolor:TXColor;
  deep :integer;
  xgcv: TXGCValues;
  visual : PVisual ;
  gnome, net_wm, tipe,gnome_layer,net_wm_state, net_wm_top: TAtom;
  root,root1: TWindow;
  nitems, bytesafter,s: LongInt;
  args : PChar;
  format:Integer;
  xev: TXClientMessageEvent;
  e : TXEvent;
  event_basep, error_basep : integer;
  ss :Bool;
  region:TXserverRegion;
  vinfo:TXVisualInfo;
  col : TXColor;

begin
  dpy := XOpenDisplay(nil);
  if Assigned(dpy) then
  begin
  g_screen := XDefaultScreen(dpy);
  g_disp_width := w;//XDisplayWidth(dpy,g_screen);
  g_disp_height :=h;//XDisplayHeight(dpy,g_screen);
   XMatchVisualInfo(dpy, DefaultScreen(dpy), 32, TrueColor, @vinfo);
   deep:= vinfo.depth;
   atr.override_redirect:=1;
   atr.colormap:=XCreateColormap(dpy,DefaultRootWindow(dpy),vinfo.visual,AllocNone);
   atr.background_pixmap:=None;
   atr.border_pixel:=0;
   atr.event_mask:= ExposureMask or KeyPressMask;
   mask := CWOverrideRedirect or CWBackPixmap or CWBorderPixel or CWColormap or CWEventMask;

   g_win:= XCreateWindow(dpy,DefaultRootWindow(dpy),0,0,g_disp_width,g_disp_height,0,deep,1,vinfo.visual,
   mask,@atr);
   XStoreName(dpy,g_win,'Overlay');
   g_shape := XCreatePixmap(dpy,g_win,g_disp_width,g_disp_height,deep);
   xgcv.graphics_exposures:=0;
   gc:= XCreateGC(dpy,g_win,GCGraphicsExposures,@xgcv);
   surf := cairo_xlib_surface_create(dpy,g_shape,vinfo.visual,g_disp_width,g_disp_height);
   cr:= cairo_create(surf);
   cairo_select_font_face (cr,'FreeSans', CAIRO_FONT_SLANT_NORMAL, CAIRO_FONT_WEIGHT_BOLD);
   XSetForeground(dpy,gc,0);
   region:= XFixesCreateRegion(dpy,nil,0);
   XFixesSetWindowShapeRegion(dpy,g_win,2,0,0,region);
   XFixesDestroyRegion(dpy,region);
   XFillRectangle(dpy,g_shape,gc,0,0,g_disp_width,g_disp_height);
   XCopyArea(dpy,g_shape,g_win,gc,0,0,g_disp_width,g_disp_height,0,0);

   XSelectInput(dpy,g_win,ExposureMask);
   XMapWindow(dpy,g_win);
   XFlush(dpy);
   Result := True;
  end
  else
  begin
  Result:= False;
  WriteLn('Error: Cannot open Display');
  end;
end;

procedure liboverlayfree();
begin
  XFreeGC(dpy,gc);
  XFreePixmap(dpy,g_shape);
  XDestroyWindow(dpy,g_win);
  XCloseDisplay(dpy);
end;

procedure liboverlayline(col1, x1, y1, x2, y2, w: integer);
var
    col:TXColor;
begin
   col.red:= ((col1 >> 16) and 255)*255;
   col.green:=((col1 >> 8) and 255)*255;
   col.blue:=(col1  and 255)*255;
   XAllocColor(dpy,atr.colormap,@col);
   gcv.foreground:= col.pixel;
   XChangeGC(dpy,gc,GCForeground,@gcv);
   XSetLineAttributes(dpy,gc,w,0,0,0);
   XDrawLine(dpy,g_shape,gc,x1,y1,x2,y2);
end;

procedure liboverLayrectangle(col1, x, y, w, h, wi: integer);
var
    col:TXColor;
begin
   col.red:= ((col1 >> 16) and 255)*255;
   col.green:=((col1 >> 8) and 255)*255;
   col.blue:=(col1  and 255)*255;
   XAllocColor(dpy,atr.colormap,@col);
   gcv.foreground:= col.pixel;
   XChangeGC(dpy,gc,GCForeground,@gcv);
   XSetLineAttributes(dpy,gc,wi,0,0,0);
   XDrawRectangle(dpy,g_shape,gc,x,y,w,h);
end;

procedure liboverLayTextOut(col, x, y, w: integer; txt: string);
var
    col1:TXColor;
begin
   cairo_set_font_size(cr,w);
   cairo_set_source_rgba(cr,((col >> 16) and 255),((col >> 8) and 255),(col and 255),255);
   cairo_move_to(cr,x,y+w);
   cairo_show_text(cr,pchar(txt));
end;

procedure liboverlayupdate();
begin
 XCopyArea(dpy,g_shape,g_win,gc,0,0,g_disp_width,g_disp_height,0,0);
end;

procedure liboverlayevent();
begin
  while (XPending(dpy) > 0)  do
  begin
  XNextEvent(dpy,@event);
  WriteLn(event._type);
  if (event._type = Expose) then
  begin
  XCopyArea(dpy,g_shape,g_win,gc,event.xexpose.x,event.xexpose.y,event.xexpose.width,event.xexpose.height,event.xexpose.x,event.xexpose.y);
  end;
  end;
end;

procedure liboverlayclear();
begin
  XSetForeground(dpy,gc,0);
  XFillRectangle(dpy,g_shape,gc,0,0,g_disp_width,g_disp_height);
end;

   function XIOErrorHandler(display: PDisplay): Integer; cdecl;
  begin
  {$IFDEF DEBUG}  WriteLn('XIOErrorHandler');   {$ENDIF}
    Result := 0;
  end;
{ TForm1 }
 function createxcolor(r,g,b:integer):TXColor;
 var
 xcolor: TXColor;
 begin
    xcolor.red:= (r * $ffff) div $ff;
    xcolor.green:= (g * $ffff) div $ff;
    xcolor.red:= (b * $ffff) div $ff;
    xcolor.flags:= DoRed or DoGreen or DoBlue;
    if (XAllocColor(@dpy,DefaultColormap(@dpy,g_screen),@xcolor)=0) then WriteLn('error') else
    Result := xcolor;
 end;



end.

