//any test code
unit DTestCode;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Xml.XMLDoc, Xml.XMLIntf, Vcl.StdCtrls, PrintUtils;

type
  TDynArrChar = array of Char;

  procedure sortStringList(pSDelimiterText :String; var slStrList :TStringList; mmo :TMemo);
  function getNextSeqAlpha(pCharArr :TDynArrChar) :TDynArrChar; //A,B ... AA,AB,AC..

  //TStringList CustomSort 용도로 만든 function
  function StringLengthCompare(List: TStringList; Index1, Index2: Integer): Integer;  //String 길이로 정렬
  function StringValueCompare(List :TStringList; idx1, idx2 :Integer): Integer;  //String Value 정렬

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

  if isIncLength then      //자릿수 증가해야 하는 경우
  begin
    i := Length(pCharArr);
    SetLength(pCharArr, i+1);

    pCharArr[i-1] := 'A';
  end;

  result := pCharArr;
end;

procedure sortStringList(pSDelimiterText :String; var slStrList :TStringList; mmo :TMemo);
var
  i :Integer;
  idx :Integer;
begin
  //에버헬스 홈페이지 인입 리스트 정렬
  //C:9235@0|B:9149@30000|A:9146@0|ADD:9148@30000|B:9147@20000|
  //target : A:9146@0|B:9147@20000|B:9149@30000|C:9235@0|ADD:9148@30000|
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

  slStrList.CustomSort(StringLengthCompare);
  for idx := 0 to slStrList.Count-1 do
  begin
    mmo.Lines.Add(slStrList[idx]);
  end;

  mmo.LInes.Add('===============');

  slStrList.CustomSort(StringValueCompare);
  for idx := 0 to slStrList.Count-1 do
  begin
    mmo.Lines.Add(slStrList[idx]);
  end;


end;

function StringLengthCompare(List: TStringList; Index1, Index2: Integer): Integer;
var
  Len1, Len2: Integer;
  Str1, Str2: String;
begin
  Str1 := Copy(List[Index1], 1, Pos(':', List[Index1])-1);
  Str2 := Copy(List[Index2], 1, Pos(':', List[Index2])-1);

  Len1 := Length(Str1);
  Len2 := Length(Str2);

  if Len1 > Len2 then Result := 1
  else if Len1 < Len2 then Result := -1
  else Result := 0;
end;

function StringValueCompare(List :TStringList; idx1, idx2 :Integer): Integer;
var
  Str1, Str2 :String;
  len1, len2 :Integer;
begin
  Str1 := Copy(List[idx1], 1, Pos(':', List[idx1])-1);
  Str2 := Copy(List[idx2], 1, Pos(':', List[idx2])-1);

  len1 := Length(Str1);
  len2 := Length(Str2);

  if (Str1 > Str2) or (len1 > len2) then
  begin
    Result := 1;                   //전환하겠다.
  end
  else if Str1 = Str2 then
  begin
    Result := 0;                   //전환하지않겠다.
  end
  else
  begin
    Result := -1;                  //넘어가자.
  end;
end;

end.
