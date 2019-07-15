unit xshape;

{$mode objfpc}{$H+}

interface

uses
   x, xlib, ctypes;

{$ifndef os2}
  {$LinkLib c}
  {$LinkLib X11}
const
  libxshape='x11';
{$else}
const
  libxshape='x11';
{$endif}
const
ShapeSet = 0;
ShapeUnion = 1;
ShapeIntersect = 2;
ShapeSubtract =3;
ShapeInvert = 4;
ShapeBounding =	0;
ShapeClip = 1 ;
ShapeInput = 2;
ShapeNotifyMask	= 1 shl 0;
ShapeNotify = 0;
ShapeNumberEvents = (ShapeNotify + 1) ;


function XShapeQueryExtension(dpy:PDisplay; event_basep:Plongint; error_basep:Plongint):TBoolResult;cdecl;external  libxshape;
procedure XShapeCombineMask( Display:PDisplay; Window:TWindow;dest_kind, x_off, y_off:cint; src: TPixmap; op:cint);cdecl;external  libxshape;

               //composite functions
procedure XCompositeRedirectWindow (dpy:PDisplay; win: twindow; update:integer);cdecl;external libxshape;
procedure XCompositeUnredirectWindow (dpy:PDisplay; win: twindow; update:integer);cdecl;external libxshape;

implementation

end.

