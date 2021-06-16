//any test code
unit DTestCode;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Xml.XMLDoc, Xml.XMLIntf;

  function sortStringList(pSDelimiterText :String) :TStringList;

implementation

function sortStringList(pSDelimiterText :String) :TStringList;
var
  slStrList :TStringList;
  i :Integer;
begin
  //에버헬스 홈페이지 인입 리스트 정렬
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
