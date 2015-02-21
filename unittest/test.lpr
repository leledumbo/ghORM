program test;

{$mode objfpc}{$H+}

uses
  Interfaces, Forms, GuiTestRunner,
  sysutils,
  ghSQL, ghSQLdbLib, ghORM,
  TCUsersAndRoles, usersandroles;

const
  DbFileName = 'app.db';

procedure DeleteDbFile; inline;
begin
  if FileExists(DbFileName) then DeleteFile(DbFileName);
end;

var
  AConn: TghSQLConnector;
begin
  DeleteDbFile;
  AConn := TghSQLConnector.Create(TghSQLite3Lib);
  AConn.Database := DbFileName;
  AConn.Connect;

  AConn.Script.LoadFromFile('test.sql');
  AConn.IsBatch := true;
  AConn.Execute;

  SetConn(AConn);
  try
    Application.Initialize;
    Application.CreateForm(TGuiTestRunner, TestRunner);
    Application.Run;
  finally
    Conn.Free;
    DeleteDbFile;
  end;
end.

