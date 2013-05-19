unit models;

{$mode objfpc}{$H+}

interface

uses
  gh_orm;

type

  { TUser }

  TUser = class(TghModel)
  private
    FName: String;
    FAge: Integer;
    FBirthdate: String;
  published
    property Name: String read FName write FName;
    property Age: Integer read FAge write FAge;
    property Birthdate: String read FBirthdate write FBirthdate;
  end;

  TRole = class(TghModel)
  private
    FName: String;
    FDescription: String;
  published
    property Name: String read FName write FName;
    property Description: String read FDescription write FDescription;
  end;

function AddUser(const AName: String; const AAge: Integer; const ABirthdate: String): Integer;
function AddRole(const AName,ADescription: String): Integer;

implementation

function AddUser(const AName: String; const AAge: Integer;
  const ABirthdate: String): Integer;
var
  u: TUser;
begin
  u := TUser.Create;
  u.Name := 'Mario';
  u.Age := 24;
  u.Birthdate := '25-03-88';
  u.Save;

  Result := u.ID;

  u.Free;
end;

function AddRole(const AName,ADescription: String): Integer;
var
  r: TRole;
begin
  r := TRole.Create;
  r.Name := AName;
  r.Description := ADescription;
  r.Save;

  Result := r.ID;

  r.Free;
end;


initialization
  RegisterClass(TUser);
  RegisterClass(TRole);

end.

