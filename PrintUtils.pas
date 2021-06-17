{
PrintUtils:
This unit collects a number of printer-related helper routines.
Author: Dr. Peter Below
Version 1.0 created 26.11.2001
Current revision: 1.01
Last modified: 03.12.2001
}

{$BOOLEVAL OFF} {Unit depends on shortcut boolean evaluation}
unit PrintUtils;

interface

uses
  Windows, Classes;

type
  TPaperName = array[0..63] of Char;
  TPaperInfo = packed record
    papername: TPapername; { display name of the paper }
    paperID: Word; { DMPAPER_* ID }
    papersize: TPoint; { Size in 0.1 mm }
  end;
  TPaperInfos = array of TPaperInfo;
  TPaperSizes = array of TPoint;
  TPageInfo = record
    width, height: Integer; { physical width and height, in dots }
    offsetX, offsetY: Integer; { nonprintable margin, in dots }
    resX, resY: Integer; { logical resolution, dots per inch }
  end;

  {Return the names, IDs, and sizes for all paper formats supported by a printer. Index is the index of the printer in the Printers array, or -1 if the default printer should be examined.}
  procedure GetPaperInfo(var infos: TPaperInfos; index: Integer = -1);
  {Return the names and IDs for all bins supported by a printer. The IDs are returned in the
  strings Objects property. Index is the index of the printer in the Printers array, or -1 if the default printer should be examined.}
  procedure GetBinnames(sl: TStrings; index: Integer = -1);
  {Return the names and IDs for all paper formats supported by a printer. The IDs are returned in the strings Objects property. Index is the index of the printer in the Printers array, or -1 if the default printer should be examined.}
  procedure GetPapernames(sl: TStrings; index: Integer = -1);
  {Return page information for the selected printer.}
  procedure GetPageinfo(var info: TPageInfo; index: Integer = -1);
  {Convert inches to mm}
  function InchToMM(const value: Double): Double;
  {Convert mm to inches}
  function MMToInch(const value: Double): Double;
  {Select a printer bin. The parameter is the DMBIN_* index to use. The current printer is always used.}
  procedure SelectPrinterBin(binID: SmallInt);
  {Select a standard paper size. The parameter is the DMPAPER_* index to use. The current printer
  is always used.}
  procedure SelectPaper(paperID: SmallInt);
  {Reload a printers DEVMODE record.}
  procedure ResetPrinter;

implementation

uses
  WinSpool, Sysutils, Printers;

procedure GetBinnames(sl: TStrings; index: Integer);
type
  TBinName = array[0..23] of Char;
  TBinNameArray = array[1..High(Integer) div Sizeof(TBinName)] of TBinName;
  PBinnameArray = ^TBinNameArray;
  TBinArray = array[1..High(Integer) div Sizeof(Word)] of Word;
  PBinArray = ^TBinArray;
var
  Device, Driver, Port: array[0..255] of Char;
  hDevMode: THandle;
  i, numBinNames, numBins, temp: Integer;
  pBinNames: PBinnameArray;
  pBins: PBinArray;
begin
  Assert(Assigned(sl));
  Printer.PrinterIndex := index;
  Printer.GetPrinter(Device, Driver, Port, hDevmode);
  numBinNames := WinSpool.DeviceCapabilities(Device, Port, DC_BINNAMES, nil, nil);
  numBins := WinSpool.DeviceCapabilities(Device, Port, DC_BINS, nil, nil);
  if numBins <> numBinNames then
  begin
    raise Exception.Create('DeviceCapabilities reports different number of bins and ' +  'bin names!');
  end;
  if numBinNames > 0 then
  begin
    GetMem(pBinNames, numBinNames * Sizeof(TBinname));
    GetMem(pBins, numBins * Sizeof(Word));
    try
      WinSpool.DeviceCapabilities(Device, Port, DC_BINNAMES, Pchar(pBinNames), nil);
      WinSpool.DeviceCapabilities(Device, Port, DC_BINS, Pchar(pBins), nil);
      sl.clear;
      for i := 1 to numBinNames do
      begin
        temp := pBins^[i];
        sl.addObject(pBinNames^[i], TObject(temp));
      end;
    finally
      FreeMem(pBinNames);
      if pBins <> nil then
        FreeMem(pBins);
    end;
  end;
end;

procedure GetPapernames(sl: TStrings; index: Integer);
type
  TPaperNameArray = array[1..High(Integer) div Sizeof(TPaperName)] of TPaperName;
  PPapernameArray = ^TPaperNameArray;
  TPaperArray = array[1..High(Integer) div Sizeof(Word)] of Word;
  PPaperArray = ^TPaperArray;
var
  Device, Driver, Port: array[0..255] of Char;
  hDevMode: THandle;
  i, numPaperNames, numPapers, temp: Integer;
  pPaperNames: PPapernameArray;
  pPapers: PPaperArray;
begin
  Assert(Assigned(sl));
  Printer.PrinterIndex := index;
  Printer.GetPrinter(Device, Driver, Port, hDevmode);
  numPaperNames := WinSpool.DeviceCapabilities(Device, Port, DC_PAPERNAMES, nil, nil);
  numPapers := WinSpool.DeviceCapabilities(Device, Port, DC_PAPERS, nil, nil);
  if numPapers <> numPaperNames then
  begin
    raise Exception.Create('DeviceCapabilities reports different number of papers and '+ ' paper names!');
  end;
  if numPaperNames > 0 then
  begin
    GetMem(pPaperNames, numPaperNames * Sizeof(TPapername));
    GetMem(pPapers, numPapers * Sizeof(Word));
    try
      WinSpool.DeviceCapabilities(Device, Port, DC_PAPERNAMES, Pchar(pPaperNames),
        nil);
      WinSpool.DeviceCapabilities(Device, Port, DC_PAPERS, Pchar(pPapers), nil);
      sl.clear;
      for i := 1 to numPaperNames do
      begin
        temp := pPapers^[i];
        sl.addObject(pPaperNames^[i], TObject(temp));
      end;
    finally
      FreeMem(pPaperNames);
      if pPapers <> nil then
        FreeMem(pPapers);
    end;
  end;
end;

procedure GetPapersizes(var sizes: TPaperSizes; index: Integer);
var
  Device, Driver, Port: array[0..255] of Char;
  hDevMode: THandle;
  numPapers: Integer;
begin
  Printer.PrinterIndex := index;
  Printer.GetPrinter(Device, Driver, Port, hDevmode);
  numPapers := WinSpool.DeviceCapabilities(Device, Port, DC_PAPERS, nil, nil);
  SetLength(sizes, numPapers);
  if numPapers > 0 then
    WinSpool.DeviceCapabilities(Device, Port, DC_PAPERSIZE, PChar(@sizes[0]), nil);
end;

procedure GetPaperInfo(var infos: TPaperInfos; index: Integer);
var
  sizes: TPaperSizes;
  sl: TStringlist;
  i: Integer;
begin
  sl := Tstringlist.Create;
  try
    GetPaperNames(sl, index);
    GetPaperSizes(sizes, index);
    Assert(sl.count = Length(sizes));
    SetLength(infos, sl.count);
    for i := 0 to sl.count - 1 do
    begin
      StrPLCopy(infos[i].papername, sl[i], Sizeof(TPapername) - 1);
      infos[i].paperID := LoWord(Longword(sl.Objects[i]));
      infos[i].papersize := sizes[i];
    end;
  finally
    sl.Free;
  end;
end;

procedure GetPageinfo(var info: TPageInfo; index: Integer = -1);
begin
  if index > -1 then
    Printer.PrinterIndex := index;
  with Printer do
  begin
    info.resX := GetDeviceCaps(handle, LOGPIXELSX);
    info.resY := GetDeviceCaps(handle, LOGPIXELSY);
    info.offsetX := GetDeviceCaps(handle, PHYSICALOFFSETX);
    info.offsetY := GetDeviceCaps(handle, PHYSICALOFFSETY);
    info.width := GetDeviceCaps(handle, PHYSICALWIDTH);
    info.height := GetDeviceCaps(handle, PHYSICALHEIGHT);
  end;
end;

const
  mmPerInch = 25.4;

function InchToMM(const value: Double): Double;
begin
  Result := value * mmPerInch;
end;

function MMToInch(const value: Double): Double;
begin
  Result := value / mmPerInch;
end;

procedure SelectPrinterBin(binID: SmallInt);
var
  Device, Driver, Port: array[0..127] of char;
  hDeviceMode: THandle;
  pDevMode: PDeviceMode;
begin
  with Printer do
  begin
    GetPrinter(Device, Driver, Port, hDeviceMode);
    pDevMode := GlobalLock(hDevicemode);
    if pDevMode <> nil then
    try
      with pDevMode^ do
      begin
        dmFields := dmFields or DM_DEFAULTSOURCE;
        dmDefaultSource := binID;
      end;
    finally
      GlobalUnlock(hDevicemode);
    end;
  end;
end;

procedure SelectPaper(paperID: SmallInt);
var
  Device, Driver, Port: array[0..127] of char;
  hDeviceMode: THandle;
  pDevMode: PDeviceMode;
begin
  with Printer do
  begin
    GetPrinter(Device, Driver, Port, hDeviceMode);
    pDevMode := GlobalLock(hDevicemode);
    if pDevMode <> nil then
    try
      with pDevMode^ do
      begin
        dmFields := dmFields or DM_PAPERSIZE;
        dmPapersize := paperID;
      end;
    finally
      GlobalUnlock(hDevicemode);
    end;
  end;
end;

procedure ResetPrinter;
var
  Device, Driver, Port: array[0..80] of Char;
  DevMode: THandle;
begin
  Printer.GetPrinter(Device, Driver, Port, DevMode);
  Printer.SetPrinter(Device, Driver, Port, 0)
end;

end.
