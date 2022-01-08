program Builder;

uses
  Forms,
  Unit1 in 'Unit1.pas' {Form1},
  Md5 in 'Md5.pas',
  RESOURCES in 'RESOURCES.PAS';

{$R *.res}

begin
  Application.Initialize;
  Application.Title := 'Encoder Builder';
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
