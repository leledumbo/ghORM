program ghormunittest;

{$mode objfpc}{$H+}

uses
  Interfaces, Forms, GuiTestRunner, testcasesimple, models, gh_orm;

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TGuiTestRunner, TestRunner);
  Application.Run;
end.

