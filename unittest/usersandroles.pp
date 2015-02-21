unit UsersAndRoles;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, ghSQL, ghORM;

type

  TRole = class;

  { TRoleList }

  TRoleList = specialize TModelList<TRole>;

  { TUser }

  TUser = class(TModel)
  private
    FName: String;
    FPassword: String;
    FRoles: TRoleList;
  public
    constructor Create;
    destructor Destroy; override;
    class function GetTableName: String; override;
    function Validate: Boolean; override;
    procedure LoadFromTable(ATable: TghSQLTable); override;
    procedure SaveToTable(ATable: TghSQLTable); override;
    procedure LoadRelationships(ALinks: TghSQLTableList); override;
    procedure SaveRelationships(ALinks: TghSQLTableList); override;
    property Name: String read FName write FName;
    property Password: String read FPassword write FPassword;
    property Roles: TRoleList read FRoles;
  end;

  { TUserList }

  TUserList = specialize TModelList<TUser>;

  TRole = class(TModel)
  private
    FName: String;
    FDescription: String;
    FUsers: TUserList;
  public
    constructor Create;
    destructor Destroy; override;
    class function GetTableName: String; override;
    function Validate: Boolean; override;
    procedure LoadFromTable(ATable: TghSQLTable); override;
    procedure SaveToTable(ATable: TghSQLTable); override;
    procedure LoadRelationships(ALinks: TghSQLTableList); override;
    procedure SaveRelationships(ALinks: TghSQLTableList); override;
    property Name: String read FName write FName;
    property Description: String read FDescription write FDescription;
    property Users: TUserList read FUsers;
  end;

  { TUsers }

  TUsers = class(specialize TORM<TUser>)
  public
    procedure LinkRelationships; override;
  end;

  { TRoles }

  TRoles = class(specialize TORM<TRole>)
  public
    procedure LinkRelationships; override;
  end;

implementation

{ TUser }

constructor TUser.Create;
begin
  FRoles := TRoleList.Create;
end;

destructor TUser.Destroy;
begin
  FRoles.Free;
  inherited Destroy;
end;

procedure TUser.LoadFromTable(ATable: TghSQLTable);
begin
  FName     := ATable['name'].AsString;
  FPassword := ATable['password'].AsString;
end;

procedure TUser.SaveToTable(ATable: TghSQLTable);
begin
  ATable['name'].AsString     := FName;
  ATable['password'].AsString := FPassword;
end;

class function TUser.GetTableName: String;
begin
  Result := 'users';
end;

function TUser.Validate: Boolean;
begin
  Result := true;
end;

procedure TUser.SaveRelationships(ALinks: TghSQLTableList);
var
  UserRoleTab: TghSQLTable;
  LRole: TRole;
begin
  UserRoleTab := ALinks['users_roles'];
  for LRole in FRoles do begin
    UserRoleTab.Insert;
    UserRoleTab['user_id'].AsInteger := Self.ID;
    UserRoleTab['role_id'].AsInteger := LRole.ID;
    UserRoleTab.Commit;
  end;
end;

procedure TUser.LoadRelationships(ALinks: TghSQLTableList);
var
  RoleORM: TRoles;
  RoleTab: TghSQLTable;
  LRole: TRole;
begin
  FRoles.Clear;
  RoleORM := TRoles.Create;
    RoleTab := ALinks['roles'].Open;
    RoleTab.First;
    while not RoleTab.EOF do begin
      RoleORM.GetOne(RoleTab['id'].AsInteger,LRole);
      FRoles.Add(LRole);
      RoleTab.Next;
    end;
  RoleORM.Free;
end;

{ TRole }

constructor TRole.Create;
begin
  FUsers := TUserList.Create;
end;

destructor TRole.Destroy;
begin
  FUsers.Free;
  inherited Destroy;
end;

procedure TRole.LoadFromTable(ATable: TghSQLTable);
begin
  FName        := ATable['name'].AsString;
  FDescription := ATable['description'].AsString;
end;

procedure TRole.SaveToTable(ATable: TghSQLTable);
begin
  ATable['name'].AsString        := FName;
  ATable['description'].AsString := FDescription;
end;

class function TRole.GetTableName: String;
begin
  Result := 'roles';
end;

function TRole.Validate: Boolean;
begin
  Result := true;
end;

procedure TRole.SaveRelationships(ALinks: TghSQLTableList);
var
  UserRoleTab: TghSQLTable;
  LUser: TUser;
begin
  UserRoleTab := ALinks['users_roles'];
  for LUser in FUsers do begin
    UserRoleTab.Insert;
    UserRoleTab['role_id'].AsInteger := Self.ID;
    UserRoleTab['user_id'].AsInteger := LUser.ID;
    UserRoleTab.Commit;
  end;
end;

procedure TRole.LoadRelationships(ALinks: TghSQLTableList);
var
  UserORM: TUsers;
  UserTab: TghSQLTable;
  LUser: TUser;
begin
  FUsers.Clear;
  UserORM := TUsers.Create;
    UserTab := ALinks['users'].Open;
    while not UserTab.EOF do begin
      UserORM.GetOne(UserTab['id'].AsInteger,LUser);
      FUsers.Add(LUser);
      UserTab.Next;
    end;
  UserORM.Free;
end;

{ TUsers }

procedure TUsers.LinkRelationships;
begin
  GetTable.Relations['roles']
        .Where('id IN (SELECT role_id FROM users_roles WHERE user_id = :id)');
  GetTable.Relations['users_roles']
        .Where('user_id = :id');
end;

{ TRoles }

procedure TRoles.LinkRelationships;
begin
  GetTable.Relations['users']
        .Where('id IN (SELECT user_id FROM users_roles WHERE role_id = :id)');
  GetTable.Relations['users_roles']
        .Where('role_id = :id');
end;

end.

