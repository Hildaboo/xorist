unit Resources;

interface

Uses
    windows;

Type

  TResType = MakeIntResource;

  PTFileHeader= ^TFileHeader;
  TFileHeader = Packed record
    DataSize        : DWORD;      // размер данных
    HeaderSize      : DWORD;      // размер этой записи
    ResType         : DWORD;      // нижнее слово = $FFFF => ordinal
    ResId           : DWORD;      // нижнее слово = $FFFF => ordinal
    DataVersion     : DWORD;      // *
    MemoryFlags     : WORD;       // $0030
    LanguageId      : WORD;       // *
    Version         : DWORD;      // *
    Characteristics : DWORD;      // *
  end;

  PResIdHeader= ^TResIdHeader;
  TResIdHeader = Packed record
    DataSize        : DWORD;      // размер данных
    HeaderSize      : DWORD;      // размер этой записи
    ResType         : DWORD;      // нижнее слово = $FFFF => ordinal
    ResId           : DWORD;      // нижнее слово = $FFFF => ordinal
    DataVersion     : DWORD;      // *
    MemoryFlags     : WORD;       // $0030
    LanguageId      : WORD;       // *
    Version         : DWORD;      // *
    Characteristics : DWORD;      // *
  end;

  PResNameHeader= ^TResNameHeader;
  TResNameHeader = Packed record
    DataSize        : DWORD;      // размер данных
    HeaderSize      : DWORD;      // размер этой записи
    ResType         : DWORD;      // нижнее слово = $FFFF => ordinal
    ResName         : array[1..MAX_PATH] of char; // нижнее слово = $FFFF => ordinal
    DataVersion     : DWORD;       // *
    MemoryFlags     : WORD;        // $0030
    LanguageId      : WORD;        // *
    Version         : DWORD;       // *
    Characteristics : DWORD;       // *
  end;

function ResIdCreateFromData(PResData: Pointer; szData: Integer; FileName: String; ResID: WORD; ResType: TResType):Boolean;
function ResNameCreateFromData(PResData: Pointer; szData: Integer; FileName: String; ResName: String; ResType: TResType): Boolean;
function ResIDCreateFromFileData(FileData, FileRes: String; ResID: WORD; ResType: TResType): Boolean;
function ResNameCreateFromFileData(FileData, FileRes, ResName: String; ResType: TResType): Boolean;
function ResUpdateFromData(PData: Pointer; szData: Integer; FileName: String; ResName:dword; ResType: TResType): Boolean;
function ResUpdateFromFileData(FileData: String; FileName, ResName: String; ResType: TResType): Boolean;


var
  ArrayRT: set of Byte; //Resource Type Array;
  GLOBAL_LANG : WORD;

implementation

uses
  Unit1;

{---------------------------- AnsiUpperCase -----------------------------------}
function AnsiUpperCase(const S: string): string;
var
  Len: Integer;
begin
  Len := Length(S);
  SetString(Result, PChar(S), Len);
  if Len > 0 then CharUpperBuff(Pointer(Result), Len);
end;
{------------------------------- StrToUnicode ---------------------------------}
function StrToUnicode(S: String): String;
var i: integer;
begin
  Result:='';
  for i:=1 to Length(S) do Result:=Result+S[i]+#0;
end;
{------------------------------- UnicodeToStr ---------------------------------}
function UnicodeToStr(WS: String): String;
var i: integer;
begin
  for i:=1 to Length(WS) do begin
    if (i mod 2) <> 0 then Result:=Result+WS[i];
  end;
end;
{-------------------------------- FileExists ----------------------------------}
function FileExists(const FileName: string): Boolean;
var
  Code: Integer;
begin
  Code := GetFileAttributes(PChar(FileName));
  Result := (Code <> -1) and (FILE_ATTRIBUTE_DIRECTORY and Code = 0);
end;

{----------------------------- ResIdFileCreate --------------------------------}
function ResIdCreateFromData(PResData: Pointer; szData: Integer;
                   FileName: String; ResID: WORD; ResType: TResType):Boolean;
var hFileOut: THandle;
    FileHeader : TFileHeader;
    cbWritten  : DWORD;
    ResHeader  : TResIdHeader;
begin
  Result:=false;
  If (Not Assigned(PResData)) or (FileName = '') then Exit;
  if Not (Byte(ResType) in ArrayRT) then Exit;

  hFileOut := CreateFile(PChar(FileName),        // name of file
                     GENERIC_WRITE or GENERIC_WRITE,              // access mode
                     0,                            // share mode
                     nil,                        // default security
                     CREATE_ALWAYS,                // create flags
                     FILE_ATTRIBUTE_NORMAL,      // file attributes
                     0);
  if (hFileOut = INVALID_HANDLE_VALUE)
     //or (hFileOut = ERROR_ALREADY_EXISTS)
     Then Exit;
  try
    FillChar(FileHeader, SizeOf(TFileHeader), 0);
    FileHeader.HeaderSize := SizeOf(FileHeader);
    FileHeader.ResId      := $0000FFFF;
    FileHeader.ResType    := $0000FFFF;

    // Write FileHeader Record
    if Not WriteFile(hFileOut, FileHeader,SizeOf(TFileHeader),cbWritten,Nil) then begin
      //RaiseLastOSError;
      Exit;
    end;

    //FillChar(ResHeader,SizeOf(TResIdHeader), 0);
    ResHeader.DataSize    := szData;
    ResHeader.HeaderSize  := SizeOf(TResIdHeader);
    ResHeader.ResType     := $0000FFFF or (WORD(ResType) shl 16);
    ResHeader.ResId       := $0000FFFF or (ResID shl 16);
    ResHeader.MemoryFlags := $0030;
    ResHeader.LanguageId  := GLOBAL_LANG;

    // Write ResHeader
    if Not WriteFile(hFileOut,ResHeader,SizeOf(TResIdHeader),cbWritten,Nil) then begin
      //RaiseLastOSError;
      Exit;
    end;

    // Write ResData
    if Not WriteFile(hFileOut,PResData^,szData,cbWritten,Nil) then begin
      //RaiseLastOSError;
      Exit;
    end;
    result:=true;

  finally
    CloseHandle(hFileOut);
  end;
end;

{----------------------------- ResNameFileCreate ------------------------------}
function ResNameCreateFromData(PResData: Pointer; szData: Integer;
                 FileName: String; ResName: String; ResType: TResType): Boolean;
Var hFileOut   : THandle;
    FileHeader : TFileHeader;
    cbWritten  : DWORD;
    WResName   : string;
    //ResHeader  : TResNameHeader;
    Value      : DWORD;
begin
  Result:=false;
  If (Not Assigned(PResData)) or (FileName = '') or (ResName = '') or (szData = 0) then Exit;
  if Not (Byte(ResType) in ArrayRT) then Exit;

  hFileOut := CreateFile(PChar(FileName),           // name of file
                     GENERIC_READ or GENERIC_WRITE, // access mode
                     0,                             // share mode
                     nil,                           // default security
                     CREATE_ALWAYS,                 // create flags
                     FILE_ATTRIBUTE_NORMAL,         // file attributes
                     0);
  if hFileOut = INVALID_HANDLE_VALUE Then Exit;
  try
    ResName  := AnsiUpperCase(ResName);
    WResName := StrToUnicode(ResName);

    FillChar(FileHeader, SizeOf(TFileHeader), 0);
    FileHeader.HeaderSize := SizeOf(FileHeader);
    FileHeader.ResId      := $0000FFFF;
    FileHeader.ResType    := $0000FFFF;

    // Write FileHeader Record
    WriteFile(hFileOut, FileHeader,SizeOf(FileHeader),cbWritten,Nil);

    {
    FillChar(ResHeader,SizeOf(TResNameHeader), 0);
    ResHeader.DataSize    := szData;
    ResHeader.HeaderSize  := SizeOf(TResNameHeader);
    ResHeader.ResType     := $0000FFFF or (WORD(ResType) shl 16);
    ResHeader.MemoryFlags := $0030;
    ResHeader.LanguageId  := CP_ACP;
    move(WResName[1],ResHeader.ResName,Length(WResName));
    //Write ResHeader
    WriteFile(hFileOut,ResHeader,SizeOf(TResNameHeader),cbWritten,Nil);
    }

    // [Write Resource Header]
    // Write DataSize
    WriteFile(hFileOut,szData,SizeOf(Integer),cbWritten,Nil);
    // Write HeaderSize
    Value:=(SizeOf(DWORD)*6)+(SizeOf(WORD)*2)+Length(WResName);
    WriteFile(hFileOut,Value,SizeOf(DWORD),cbWritten,Nil);
    //.. Write ResType
    Value := $0000FFFF or (DWORD(RT_RCDATA) shl 16);
    WriteFile(hFileOut,Value,SizeOf(DWORD),cbWritten,Nil);
    //.. Write ResName
    WriteFile(hFileOut,WResName[1],Length(WResName),cbWritten,Nil);
    Value := 0;      //.. Write DataVersion
    WriteFile(hFileOut,Value,SizeOf(DWORD),cbWritten,Nil);
    Value := $0030;    //.. Write MemoryFlags
    WriteFile(hFileOut,WORD(Value),SizeOf(WORD),cbWritten,Nil);
    Value := GLOBAL_LANG; //.. Write LanguageId
    WriteFile(hFileOut,WORD(Value),SizeOf(WORD),cbWritten,Nil);
    Value := 0;      //.. Write Version
    WriteFile(hFileOut,Value,SizeOf(DWORD),cbWritten,Nil);
    Value := 0;      //.. Write Characteristics
    WriteFile(hFileOut,Value,SizeOf(DWORD),cbWritten,Nil);

    // Write ResData
    WriteFile(hFileOut,PResData^,szData,cbWritten,Nil);
    Result:=true;
  finally
    CloseHandle(hFileOut);
  end;
end;

{---------------------------- ResIDCreateFromFileData -------------------------}
function ResIDCreateFromFileData(FileData, FileRes: String; ResID: WORD; ResType: TResType): Boolean;
var
  hFileData  : THandle;
  szData     : Integer;
  PData      : Pointer;
  OfByteRead : Cardinal;
begin
  Result:=False;
  PData:=nil;
  if (Not FileExists(FileData)) or (Not (Byte(ResType) in ArrayRT)) then Exit;

  hFileData := CreateFile(PChar(FileData),GENERIC_READ,FILE_SHARE_READ,nil,OPEN_EXISTING,0,0);
  if hFileData = INVALID_HANDLE_VALUE then begin
    //RaiseLastOSError;
    Exit;
  end;
  try
    szData := GetFileSize(hFileData,Nil);
    if szData = 0 Then Exit;
    GetMem(PData,szData);
    if Not ReadFile(hFileData,PData^,szData,OfByteRead,Nil) then begin
      //RaiseLastOSError;
      Exit;
    end;
    if OfByteRead = 0 Then Exit;

    Result:=ResIdCreateFromData(PData,szData,FileRes,ResID,ResType);

    Result:=True;
  finally
    FreeMem(PData);
    CloseHandle(hFileData);
  end;
end;

{--------------------------- ResNameCreateFromFileData ------------------------}
function ResNameCreateFromFileData(FileData, FileRes, ResName: String; ResType: TResType): Boolean;
var
  hFileData  : THandle;
  szData     : Integer;
  PData      : Pointer;
  OfByteRead : Cardinal;
begin
  Result:=False;
  PData:=nil;
  if (Not FileExists(FileData)) or (Not (Byte(ResType) in ArrayRT)) then Exit;

  hFileData := CreateFile(PChar(FileData),GENERIC_READ,FILE_SHARE_READ,nil,OPEN_EXISTING,0,0);
  if hFileData = INVALID_HANDLE_VALUE then begin
    //RaiseLastOSError;
    Exit;
  end;
  try
    szData := GetFileSize(hFileData,Nil);
    if szData = 0 Then Exit;
    GetMem(PData,szData);
    if Not ReadFile(hFileData,PData^,szData,OfByteRead,Nil) then begin
      //RaiseLastOSError;
      Exit;
    end;
    if OfByteRead = 0 Then Exit;

    Result:=ResNameCreateFromData(PData,szData,FileRes,ResName,ResType);

    Result:=True;
  finally
    FreeMem(PData);
    CloseHandle(hFileData);
  end;
end;

{-------------------------------- ResUpdateFromData ---------------------------}
function ResUpdateFromData(PData: Pointer; szData: Integer; FileName: String; ResName:dword; ResType: TResType): Boolean;
var hUpdate: THandle;
begin
  Result:=false;
  if (Not Assigned(PData)) or (szData=0) or 
    (Not(Byte(ResType) in ArrayRT)) or (Not FileExists(FileName)) then Exit;

  hUpdate := BeginUpdateResource(PChar(FileName),false);
  if hUpdate = 0 then begin
      //RaiseLastOSError;
    Exit;
  end;

  if Not UpdateResource(hUpdate,ResType,pchar(ResName),GLOBAL_LANG,PData,szData) then begin
      //RaiseLastOSError;
    Exit;
  end;

  if Not EndUpdateResource(hUpdate,false) then begin
      //RaiseLastOSError;
    Exit;
  end;
  result:=true;
end;

{--------------------------------- ResUpdateFromFileData ----------------------}
function ResUpdateFromFileData(FileData: String; FileName, ResName: String; ResType: TResType): Boolean;
var
  hFile   : Thandle;
  hUpdate : THandle;
  szData  : Integer;
  PBuffer : Pointer;
  BytesRead: Cardinal;
begin
  Result:=false;
  PBuffer:=nil;
  if (Not FileExists(FileData)) or (Not FileExists(FileName) or
     (ResName = '') or (Not (Byte(ResType) in ArrayRT))) then Exit;

  hFile := CreateFile(PChar(FileData),GENERIC_READ,FILE_SHARE_READ,nil,OPEN_EXISTING,0,0);
  if hFile = INVALID_HANDLE_VALUE then begin
    //RaiseLastOSError;
    Exit;
  end;

  try
    szData:=GetFileSize(hFile,Nil);
    if szData = 0 then Exit;

    GetMem(PBuffer,szData);

    if Not ReadFile(hFile,PBuffer^,szData,BytesRead,nil) then begin
      //RaiseLastOSError;
      Exit;
    end;
    if BytesRead = 0 then Exit;

    hUpdate := BeginUpdateResource(PChar(FileName),false);
    if hUpdate = 0 Then begin
      //RaiseLastOSError;
      Exit;
    end;

    ResName:=AnsiUpperCase(ResName);
    if Not UpdateResource(hUpdate,ResType,PChar(ResName),
                          GLOBAL_LANG,PBuffer,szData) then begin
      //RaiseLastOSError;
      Exit;
    end;

    if Not EndUpdateResource(hUpdate,false) Then begin
      //RaiseLastOSError;
      Exit;
    end;

    Result:=True;
  finally
    FreeMem(PBuffer);
    CloseHandle(hFile);
  end;
end;


Initialization

ArrayRT := [1..22];
GLOBAL_LANG := LANG_NEUTRAL;

end.