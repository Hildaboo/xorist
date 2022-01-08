unit Md5;

interface

uses
  Classes;

type
  //Use for getting result evaluation hashsum
  TMD5Digest = record
    case Boolean of
      False: (A, B, C, D: Integer);
      True: (V: array[0..15] of Byte);
  end;

// Evaluate hashsum
function MD5String(const S: string): TMD5Digest;
function MD5File(const FileName: string): TMD5Digest;
function MD5Stream(const Stream: TStream): TMD5Digest;
function MD5Buffer(const Buffer; Size: Integer): TMD5Digest;
// Converting
function MD5DigestToStr(const Digest: TMD5Digest): string;
function StrToMD5Digest(const Hash: string): TMD5Digest;
// Compare two hashsum
function MD5DigestEquals(const D1, D2: TMD5Digest): Boolean;

implementation

uses
  SysUtils;

type
  PArray4Cardinal = ^TArray4Cardinal;
  TArray4Cardinal = array[0..3] of Cardinal;
  TArray2Cardinal = array[0..1] of Cardinal;
  TArray64Byte = array[0..63] of Byte;

  TMD5Context = record
    State: TArray4Cardinal;
    Count: TArray2Cardinal;
    Buffer: TArray64Byte;
  end;

const
  Padding: TArray64Byte =
    ($80, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
       0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
       0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
       0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
       
  S11 = 7;
  S12 = 12;
  S13 = 17;
  S14 = 22;
  S21 = 5;
  S22 = 9;
  S23 = 14;
  S24 = 20;
  S31 = 4;
  S32 = 11;
  S33 = 16;
  S34 = 23;
  S41 = 6;
  S42 = 10;
  S43 = 15;
  S44 = 21;

function RotateLeft(X, N: Cardinal): Cardinal;
begin
  Result := (X shl N) or (X shr (32 - N));
end;

procedure FF(var A: Cardinal; B, C, D, X, S, Ac: Cardinal);
begin
  A := RotateLeft(B and C or not B and D + A + X + Ac, S) + B;
end;

procedure GG(var A: Cardinal; B, C, D, X, S, Ac: Cardinal);
begin
  A := RotateLeft(B and D or C and not D + A + X + Ac, S) + B;
end;

procedure HH(var A: Cardinal; B, C, D, X, S, Ac: Cardinal);
begin
  A := RotateLeft(B xor C xor D + A + X + Ac, S) + B;
end;

procedure II(var A: Cardinal; B, C, D, X, S, Ac: Cardinal);
begin
  A := RotateLeft(B or not D xor C + A + X + Ac, S) + B;
end;

procedure Transform(State: PArray4Cardinal; Buffer: Pointer);
var
  A, B, C, D: Cardinal;
  X: array[0..15] of Cardinal;
begin
  A := State[0];
  B := State[1];
  C := State[2];
  D := State[3];
  Move(Buffer^, X, 64);
  FF(A, B, C, D, X[0], S11, $D76AA478);
  FF(D, A, B, C, X[1], S12, $E8C7B756);
  FF(C, D, A, B, X[2], S13, $242070DB);
  FF(B, C, D, A, X[3], S14, $C1BDCEEE);
  FF(A, B, C, D, X[4], S11, $F57C0FAF);
  FF(D, A, B, C, X[5], S12, $4787C62A);
  FF(C, D, A, B, X[6], S13, $A8304613);
  FF(B, C, D, A, X[7], S14, $FD469501);
  FF(A, B, C, D, X[8], S11, $698098D8);
  FF(D, A, B, C, X[9], S12, $8B44F7AF);
  FF(C, D, A, B, X[10], S13, $FFFF5BB1);
  FF(B, C, D, A, X[11], S14, $895CD7BE);
  FF(A, B, C, D, X[12], S11, $6B901122);
  FF(D, A, B, C, X[13], S12, $FD987193);
  FF(C, D, A, B, X[14], S13, $A679438E);
  FF(B, C, D, A, X[15], S14, $49B40821);
  GG(A, B, C, D, X[1], S21, $F61E2562);
  GG(D, A, B, C, X[6], S22, $C040B340);
  GG(C, D, A, B, X[11], S23, $265E5A51);
  GG(B, C, D, A, X[0], S24, $E9B6C7AA);
  GG(A, B, C, D, X[5], S21, $D62F105D);
  GG(D, A, B, C, X[10], S22, $2441453);
  GG(C, D, A, B, X[15], S23, $D8A1E681);
  GG(B, C, D, A, X[4], S24, $E7D3FBC8);
  GG(A, B, C, D, X[9], S21, $21E1CDE6);
  GG(D, A, B, C, X[14], S22, $C33707D6);
  GG(C, D, A, B, X[3], S23, $F4D50D87);
  GG(B, C, D, A, X[8], S24, $455A14ED);
  GG(A, B, C, D, X[13], S21, $A9E3E905);
  GG(D, A, B, C, X[2], S22, $FCEFA3F8);
  GG(C, D, A, B, X[7], S23, $676F02D9);
  GG(B, C, D, A, X[12], S24, $8D2A4C8A);
  HH(A, B, C, D, X[5], S31, $FFFA3942);
  HH(D, A, B, C, X[8], S32, $8771F681);
  HH(C, D, A, B, X[11], S33, $6D9D6122);
  HH(B, C, D, A, X[14], S34, $FDE5380C);
  HH(A, B, C, D, X[1], S31, $A4BEEA44);
  HH(D, A, B, C, X[4], S32, $4BDECFA9);
  HH(C, D, A, B, X[7], S33, $F6BB4B60);
  HH(B, C, D, A, X[10], S34, $BEBFBC70);
  HH(A, B, C, D, X[13], S31, $289B7EC6);
  HH(D, A, B, C, X[0], S32, $EAA127FA);
  HH(C, D, A, B, X[3], S33, $D4EF3085);
  HH(B, C, D, A, X[6], S34, $4881D05);
  HH(A, B, C, D, X[9], S31, $D9D4D039);
  HH(D, A, B, C, X[12], S32, $E6DB99E5);
  HH(C, D, A, B, X[15], S33, $1FA27CF8);
  HH(B, C, D, A, X[2], S34, $C4AC5665);
  II(A, B, C, D, X[0], S41, $F4292244);
  II(D, A, B, C, X[7], S42, $432AFF97);
  II(C, D, A, B, X[14], S43, $AB9423A7);
  II(B, C, D, A, X[5], S44, $FC93A039);
  II(A, B, C, D, X[12], S41, $655B59C3);
  II(D, A, B, C, X[3], S42, $8F0CCC92);
  II(C, D, A, B, X[10], S43, $FFEFF47D);
  II(B, C, D, A, X[1], S44, $85845DD1);
  II(A, B, C, D, X[8], S41, $6FA87E4F);
  II(D, A, B, C, X[15], S42, $FE2CE6E0);
  II(C, D, A, B, X[6], S43, $A3014314);
  II(B, C, D, A, X[13], S44, $4E0811A1);
  II(A, B, C, D, X[4], S41, $F7537E82);
  II(D, A, B, C, X[11], S42, $BD3AF235);
  II(C, D, A, B, X[2], S43, $2AD7D2BB);
  II(B, C, D, A, X[9], S44, $EB86D391);
  Inc(State[0], A);
  Inc(State[1], B);
  Inc(State[2], C);
  Inc(State[3], D);
end;

procedure Init(var Context: TMD5Context);
begin
  FillChar(Context, SizeOf(Context), Byte(0));
  Context.State[0] := $67452301;
  Context.State[1] := $EFCDAB89;
  Context.State[2] := $98BADCFE;
  Context.State[3] := $10325476;
end;

procedure Update(var Context: TMD5Context; Input: PByteArray;
  InputLen: Cardinal);
var
  i, Index, PartLen: Cardinal;
begin
  Index := Context.Count[0] shr 3 and $3F;
  Inc(Context.Count[0], InputLen shl 3);
  if Context.Count[0] < InputLen shl 3 then
    Inc(Context.Count[1]);
  Inc(Context.Count[1], InputLen shr 29);
  PartLen := 64 - Index;
  if InputLen >= PartLen then
  begin
    Move(Input^, Context.Buffer[Index], PartLen);
    Transform(@Context.State, @Context.Buffer);
    i := PartLen;
    while i + 63 < InputLen do
    begin
      Transform(@Context.State, @Input[i]);
      Inc(i, 64);
    end;
    Index := 0;
  end
  else
    i := 0;
  Move(Input[i], Context.Buffer[Index], InputLen - i);
end;

procedure Final(var Digest: TMD5Digest; var Context: TMD5Context);
var
  Bits: array[0..7] of Byte;
  Index, PadLen: Cardinal;
begin
  Move(Context.Count, Bits, SizeOf(TArray2Cardinal));
  Index := Context.Count[0] shr 3 and $3F;
  if Index < 56 then
    PadLen := 56 - Index
  else
    PadLen := 120 - Index;
  Update(Context, @Padding, PadLen);
  Update(Context, @Bits, SizeOf(Bits));
  Move(Context.State, Digest, SizeOf(TArray4Cardinal));
end;

function MD5DigestToStr(const Digest: TMD5Digest): string;
var
  i: Integer;
begin
  Result := '';
  for i := 0 to 15 do
    Result := Result + IntToHex(Digest.V[i], 2);
  Result := LowerCase(Result);
end;

function StrToMD5Digest(const Hash: string): TMD5Digest;

  function HexCharToByte(C: Char): Byte;
  begin
    Result := 0;
    case C of
      '0'..'9': Result := Ord(C) - 48;
      'a'..'f': Result := Ord(C) - 87;
    end;
  end;

var
  LCHash: string;
  i: Byte;
begin
  FillChar(Result, 16, Byte(0));
  LCHash := LowerCase(Trim(Hash));
  if Length(LCHash) <> 32 then
    Exit;
  for i := 0 to 15 do
    Result.V[i] := HexCharToByte(LCHash[i * 2 + 1]) shl 4 +
      HexCharToByte(LCHash[i * 2 + 2]);
end;

function MD5String(const S: string): TMD5Digest;
begin
  Result := MD5Buffer(PChar(S)^, Length(S));
end;

function MD5File(const FileName: string): TMD5Digest;
var
  F: TFileStream;
begin
  F := TFileStream.Create(FileName, fmOpenRead);
  try
    Result := MD5Stream(F);
  finally
    F.Free;
  end;
end;

function MD5Stream(const Stream: TStream): TMD5Digest;
var
  Context: TMD5Context;
  Buffer: array[0..4095] of Byte;
  Size, ReadBytes, TotalBytes, SavePos: Integer;
begin
  Init(Context);
  Size := Stream.Size;
  SavePos := Stream.Position;
  TotalBytes := 0;
  try
    Stream.Seek(0, soFromBeginning);
    repeat
      ReadBytes := Stream.Read(Buffer, SizeOf(Buffer));
      Inc(TotalBytes, ReadBytes);
      Update(Context, @Buffer, ReadBytes);
    until (ReadBytes = 0) or (TotalBytes = Size);
  finally
    Stream.Seek(SavePos, soFromBeginning);
  end;
  Final(Result, Context);
end;

function MD5Buffer(const Buffer; Size: Integer): TMD5Digest;
var
  Context: TMD5Context;
begin
  Init(Context);
  Update(Context, @Buffer, Size);
  Final(Result, Context);
end;

function MD5DigestEquals(const D1, D2: TMD5Digest): Boolean;
begin
  Result := CompareMem(@D1, @D2, SizeOf(TMD5Digest));
end;

end.