//Useful functions and test codes on pascal(Delphi)
//made by MCH
//ver 1.0

unit DUsfUnit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Printers, PrintUtils;

var
  str :String;

  procedure setStr(pStr :String);

  ///<summary>프린터 용지 설정 가져오기</summary>
  function getPaperSize() :Integer;
  ///<summary>프린터 용지 설정하기</summary>
  /// <param name="pSize">
  /// DMPAPER_A3      = 8;      { A3 297 x 420 mm                     }
  /// DMPAPER_A4      = 9;      { A4 210 x 297 mm                     }
  /// DMPAPER_A4SMALL = 10;     { A4 Small 210 x 297 mm               }
  /// DMPAPER_A5      = 11;     { A5 148 x 210 mm                     }
  /// DMPAPER_B4      = 12;     { B4 (JIS) 250 x 354                  }
  /// DMPAPER_B5      = 13;     { B5 (JIS) 182 x 257 mm               }
  /// </param>
  procedure setPaperSize(pSize :Integer);
  function getPrinterInfo() :TStringList;

implementation

procedure setStr(pStr :String);
begin
  str := pStr;
end;

function getPaperSize() :Integer;
var
  ADevMode :PDevMode;
  hDMode :THandle;
  Device, Driver, Port :array[0..255] of Char;
begin
  Printer.GetPrinter(Device, Driver, Port, hDMode);
  ADevMode := GlobalLock(hDMode);
  GlobalUnlock(hDMode);
  result := ADevMode.dmPaperSize;
end;

procedure setPaperSize(pSize :Integer);
var
  ADevMode :PDevMode;
  hDMode :THandle;
  Device, Driver, Port :array[0..255] of Char;
begin
  Printer.GetPrinter(Device, Driver, Port, hDMode);
  ADevMode := GlobalLock(hDMode);
  ADevMode.dmPaperSize := pSize;
  GlobalLock(hDMode);
  Printer.SetPrinter(Device, Driver, Port, hDMode);
end;

function getPrinterInfo() :TStringList;
var
  ADevMode :PDevMode;
  hDMode :THandle;
  Device, Driver, Port :array[0..255] of Char;
  slStrList :TStringList;
begin
  Printer.GetPrinter(Device, Driver, Port, hDMode);
  ADevMode := GlobalLock(hDMode);
  GlobalUnlock(hDMode);

  slStrList := TStringList.Create;

  slStrList.Add(IntToStr(ADevMode.dmPaperSize));
  slStrList.Add(IntToStr(ADevMode.dmTTOption));
  slStrList.Add(ADevMode.dmDeviceName);
  result := slStrList;
end;

end.
