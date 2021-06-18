//any test code
unit DTestCode;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Xml.XMLDoc, Xml.XMLIntf, Vcl.StdCtrls, PrintUtils;

type
  TDynArrChar = array of Char;

  function sortStringList(pSDelimiterText :String) :TStringList;
  function getNextSeqAlpha(pCharArr :TDynArrChar) :TDynArrChar; //A,B ... AA,AB,AC..

implementation

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

  if isIncLength then      //�ڸ��� �����ؾ� �ϴ� ���
  begin
    i := Length(pCharArr);
    SetLength(pCharArr, i+1);

    pCharArr[i-1] := 'A';
  end;

  result := pCharArr;
end;

function sortStringList(pSDelimiterText :String) :TStringList;
var
  slStrList :TStringList;
  i :Integer;
begin
  //�����ｺ Ȩ������ ���� ����Ʈ ����
  //C:9235@0|B:9149@30000|A:9146@0|B:9147@20000|
  try
    slStrList := TStringList.Create;
    slStrList.Delimiter := '|';
    slStrList.DelimitedText := pSDelimiterText;

    for i := 0 to slStrList.Count-1 do
    begin
      //showmessage(slStrList[i]);
      if Trim(slStrList[i]) = '' then
      begin
        slStrList.Delete(i);
        Continue;
      end;
    end;
  finally
    FreeAndNil(slStrList);
  end;
end;

end.
