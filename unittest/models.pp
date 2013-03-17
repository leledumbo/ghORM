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

implementation

initialization
  RegisterClass(TUser);

end.

