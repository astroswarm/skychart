program sortbsc;

uses
  Forms,
  sortbsc1 in 'sortbsc1.pas' {Form1};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
