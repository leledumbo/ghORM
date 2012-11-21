unit testcasesimple;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, fpcunit, testutils, testregistry;

type

  { TSimpleTestCase }

  TSimpleTestCase = class(TTestCase)
  protected
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure InsertNewLoadExisting;
    procedure LoadNotExisting;
    procedure Reset;
  end;

implementation

uses
  gh_SQL, gh_SQLdbLib, gh_orm, models;

var
  gid: Integer;

procedure TSimpleTestCase.InsertNewLoadExisting;
var
  u: TUsers;
  id: Integer;
begin
  u := TUsers.Create;
  u.Name := 'Mario';
  u.Age := 24;
  u.Birthdate := '25-03-88';
  u.Save;

  id := u.ID;

  u.Free;

  u := TUsers.Create(id);

  AssertEquals(u.Name,'Mario');
  AssertEquals(u.Age,24);
  AssertEquals(u.Birthdate,'25-3-88');

  u.Free;

  gid := id;
end;

procedure TSimpleTestCase.LoadNotExisting;
var
  u: TUsers;
begin
  try
    u := TUsers.Create(255);
  except
    on e: EghSQL do
      Exit;
    on e: Exception do
      Fail('Unexpected ' + e.ClassName + ': ' + e.Message);
  end;
  Fail('Exception expected');
end;

procedure TSimpleTestCase.Reset;
var
  u: TUsers;
begin
  u := TUsers.Create(gid);

  u.Name := 'Marijan';
  u.Age := 72;
  u.Birthdate := '1-1-99';

  u.Load(gid);

  AssertEquals(u.Name,'Mario');
  AssertEquals(u.Age,24);
  AssertEquals(u.Birthdate,'25-3-88');

  u.Free;
end;

procedure TSimpleTestCase.SetUp;
begin
  SetConnection(TghSQLite3Lib,'test.db');
end;

procedure TSimpleTestCase.TearDown;
var
  t: TghSQLTable;
begin
  t := GetConnection.Tables['users'].Open;
  while not t.EOF do begin
    t.Delete;
    t.Next;
  end;
end;

initialization
  RegisterTest(TSimpleTestCase);

end.

