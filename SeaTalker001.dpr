program SeaTalker001;

uses
  Forms,
  SeatalkerUnit in 'SeatalkerUnit.pas' {SeatalkerForm};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TSeatalkerForm, SeatalkerForm);
  Application.Run;
end.
