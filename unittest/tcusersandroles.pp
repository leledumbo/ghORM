unit TCUsersAndRoles;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, fpcunit, testutils, testregistry;

type

  { TTestUsersAndRoles }

  TTestUsersAndRoles = class(TTestCase)
  protected
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestInsertUser;
    procedure TestInsertRole;
    procedure TestAddRoleToUser;
    procedure TestAddUserToRole;
  end;

implementation

uses
  ghORM, UsersAndRoles;

procedure TTestUsersAndRoles.SetUp;
begin
  Conn.Tables['users'].DeleteAll.Commit;
  Conn.Tables['roles'].DeleteAll.Commit;
  Conn.Tables['users_roles'].DeleteAll.Commit;
end;

procedure TTestUsersAndRoles.TearDown;
begin
end;

procedure TTestUsersAndRoles.TestInsertUser;
var
  o: TUsers;
  u: TUser;
  id: Integer;
begin
  o := TUsers.Create;

  u := o.New;
  u.Name := 'Mario';
  u.Password := '123abc';
  AssertTrue('Failed to insert user to database',o.Insert(u));
  id := u.ID;
  u.Free;

  AssertTrue('Failed to get user from database, id = ' + IntToStr(id),o.GetOne(id,u));
  AssertEquals('"Mario" <> "' + u.Name + '"','Mario',u.Name);
  AssertEquals('"123abc" <> "' + u.Password + '"','123abc',u.Password);

  u.Free;
  o.Free;
end;

procedure TTestUsersAndRoles.TestInsertRole;
var
  o: TRoles;
  r: TRole;
  id: Integer;
begin
  o := TRoles.Create;

  r := o.New;
  r.Name := 'login';
  r.Description := 'logged in user';
  AssertTrue('Failed to insert role to database',o.Insert(r));
  id := r.ID;
  r.Free;

  AssertTrue('Failed to get role from database, id = ' + IntToStr(id),o.GetOne(id,r));
  AssertEquals('"login" <> "' + r.Name + '"','login',r.Name);
  AssertEquals('"logged in user" <> "' + r.Description + '"','logged in user',r.Description);

  r.Free;
  o.Free;
end;

procedure TTestUsersAndRoles.TestAddRoleToUser;
const
  RoleName = 'login';
  RoleDesc = 'logged in user';
  UserName = 'Mario';
  UserPassword = '123abc';
var
  ormu: TUsers;
  ormr: TRoles;
  r: TRole;
  u: TUser;
  id: Integer;
begin
  ormu := TUsers.Create;
  ormr := TRoles.Create;

  u := ormu.New;
  u.Name := UserName;
  u.Password := UserPassword;

  r := ormr.New;
  r.Name := RoleName;
  r.Description := RoleDesc;
  AssertTrue('Failed to insert role to database',ormr.Insert(r));
  u.Roles.Add(r);

  AssertTrue('Failed to insert user to database',ormu.Insert(u));
  id := u.ID;
  u.Free;

  AssertTrue(Format('Failed to get user from database, id = %d',[id]),ormu.GetOne(id,u));
  AssertEquals(Format('"%s" <> "%s"',[UserName,u.Name]),UserName,u.Name);
  AssertEquals(Format('"%s" <> "%s"',[UserPassword,u.Password]),UserPassword,u.Password);
  ormu.ResolveLinks(u);
  AssertEquals(Format('Roles count don''t match: %d <> %d',[1,u.Roles.Count]),1,u.Roles.Count);
  r := u.Roles[0];
  AssertEquals(Format('"%s" <> "%s"',[RoleName,r.Name]),RoleName,r.Name);
  AssertEquals(Format('"%s" <> "%s"',[RoleDesc,r.Description]),RoleDesc,r.Description);

  u.Free;
  ormu.Free;
  ormr.Free;
end;

procedure TTestUsersAndRoles.TestAddUserToRole;
const
  RoleName = 'login';
  RoleDesc = 'logged in user';
  UserName = 'Mario';
  UserPassword = '123abc';
var
  ormu: TUsers;
  ormr: TRoles;
  r: TRole;
  u: TUser;
  id: Integer;
begin
  ormu := TUsers.Create;
  ormr := TRoles.Create;

  r := ormr.New;
  r.Name := RoleName;
  r.Description := RoleDesc;

  u := ormu.New;
  u.Name := UserName;
  u.Password := UserPassword;
  AssertTrue('Failed to insert user to database',ormu.Insert(u));
  r.Users.Add(u);

  AssertTrue('Failed to insert role to database',ormr.Insert(r));
  id := r.ID;
  r.Free;

  AssertTrue(Format('Failed to get role from database, id = %d',[id]),ormr.GetOne(id,r));
  AssertEquals(Format('"%s" <> "%s"',[RoleName,r.Name]),RoleName,r.Name);
  AssertEquals(Format('"%s" <> "%s"',[RoleDesc,r.Description]),RoleDesc,r.Description);
  ormr.ResolveLinks(r);
  AssertEquals(Format('Users count don''t match: %d <> %d',[1,r.Users.Count]),1,r.Users.Count);
  u := r.Users[0];
  AssertEquals(Format('"%s" <> "%s"',[UserName,u.Name]),UserName,u.Name);
  AssertEquals(Format('"%s" <> "%s"',[UserPassword,u.Password]),UserPassword,u.Password);

  u.Free;
  ormu.Free;
  ormr.Free;
end;

initialization
  RegisterTest(TTestUsersAndRoles);

end.

