unit container;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs;

type

  { Talt1container }

  Talt1container = class(TForm)
    procedure FormShow(Sender: TObject);
  private

  public

  end;

var
  alt1container: Talt1container;

implementation

{$R *.lfm}

{ Talt1container }

procedure Talt1container.FormShow(Sender: TObject);
begin
 alt1container.hide;
end;

end.

