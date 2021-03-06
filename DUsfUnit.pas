//Useful functions and test codes on pascal(Delphi)
//made by MCH
//ver 1.0

unit DUsfUnit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Printers, PrintUtils;

type
  TDynArrChar = array of Char;  //동적 배열을 매개변수로 전달 시 사용

  TIndexList = class(TStringList)
    public
      //function indexOf(
      ///<summary> TStringList Type으로 indexex 리턴 </summary>
      function indexOfList(sKey :String) :TStringList; overload;
  end;

  ///<summary>알파벳 타입 시퀀스 가져오기 eg.)A,B ... AA,AB,AC..</summary>
  function getNextSeqAlpha(pCharArr :TDynArrChar) :TDynArrChar;

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

  function RightStr(const Str: String; Size: Word): String;
  function LeftStr(const Str: String; Size: Word): String;
  function MidStr(Const Str: String; Size: Word): String;


implementation

function RightStr(const Str: String; Size: Word): String;
var
  len: Byte;
begin
  len := Length(Str);
  if Size > len then
    Size := len;
  RightStr := Copy(Str,len-Size+1,Size)
end;

function LeftStr(const Str: String; Size: Word): String;
begin
  LeftStr := Copy(Str,1,Size)
end;

function MidStr(Const Str: String; Size: Word): String;
var
  len: Byte;
begin
  len := Length(Str);
  if Size > len then
    Size := len;
  MidStr := Copy(Str,((len - Size) div 2)+1,Size)
end;

function getNextSeqAlpha(pCharArr :TDynArrChar) :TDynArrChar;
var
  i :Integer;
  isIncLength :Boolean;
begin
  isIncLength := False;
  for i := Length(pCharArr)-2 downto 0 do
  begin
    if UpperCase(pCharArr[i]) = 'Z' then
    begin
      pCharArr[i] := 'A';
      isIncLength := True;
      Continue;
    end;

    isIncLength := False;

    pCharArr[i] := Char(Integer(pCharArr[i])+1);
    break;
  end;

  if isIncLength then      //자리수 증가해야 하는 경우
  begin
    i := Length(pCharArr);
    SetLength(pCharArr, i+1);

    pCharArr[i-1] := 'A';
  end;

  result := pCharArr;

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

{ TIndexList }

function TIndexList.indexOfList(sKey: String): TStringList;
var
  i :Integer;
begin
  Result := TStringList.Create;
  for i := 0 to GetCount - 1 do
  begin
    if CompareStrings(Get(i), sKey) = 0 then
      Result.Add(IntToStr(i));
  end;
end;

end.
