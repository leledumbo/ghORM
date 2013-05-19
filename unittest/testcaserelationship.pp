unit testcaserelationship;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, fpcunit, testutils, testregistry;

type

  TRelationshipTestCase = class(TTestCase)
  protected
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestHookUp;
  end;

implementation

uses
  gh_SQL, gh_SQLdbLib, gh_orm, models;

const
  DBFileName = 'test.db';
  ScriptName = 'test.sql';

procedure TRelationshipTestCase.TestHookUp;
begin
  Fail('Write your own test');
end;

procedure TRelationshipTestCase.SetUp;
begin
  SetConnection(TghSQLite3Lib,DBFileName);
  with TghSQLClient.Create(GetConnection) do
    try
      Clear;
      IsBatch := true;
      Script.LoadFromFile(ScriptName);
      Execute;
    finally
      Free;
    end;
  TUser.ConnectMN(TRole);
  TRole.ConnectMN(TUser);
end;

procedure TRelationshipTestCase.TearDown;
var
  t: TghSQLTable;
begin
  t := GetConnection.Tables['user'].Open;
  while not t.EOF do begin
    t.Delete;
    t.Next;
  end;
  t.Commit;
  DeleteFile(DBFileName);
end;

initialization
  RegisterTest(TRelationshipTestCase);

end.

