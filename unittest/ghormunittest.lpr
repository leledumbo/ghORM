program ghormunittest;

{$mode objfpc}{$H+}

uses
  Interfaces, Forms, GuiTestRunner, testcasesimple, models,ghORM;

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TGuiTestRunner, TestRunner);
  Application.Run;
end.

