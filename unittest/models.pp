unit models;

{$mode objfpc}{$H+}

interface

uses
  gh_orm;

type

  { TUsers }

  TUsers = class(TghModel)
  private
    FName: String;
    FAge: Integer;
    FBirthdate: String;
    class constructor Create;
  published
    property Name: String read FName write FName;
    property Age: Integer read FAge write FAge;
    property Birthdate: String read FBirthdate write FBirthdate;
  end;

  TRoles = class(TghModel)
  private
    FName: String;
    FDescription: String;
  published
    property Name: String read FName write FName;
    property Description: String read FDescription write FDescription;
  end;

implementation

{ TUsers }

class constructor TUsers.Create;
begin
  GetTableClass.Relations['roles'].Where('').;
end;

initialization
  RegisterClass(TUsers);

end.

