//Useful functions and test codes on pascal(Delphi)
//made by MCH
//ver 1.0

unit DUsfUnit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs;

var
  str :String;

  procedure setStr(pStr :String);

implementation

procedure setStr(pStr :String);
begin
  str := pStr;
end;

end.
