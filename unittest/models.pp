unit models;

{$mode objfpc}{$H+}

interface

uses
  gh_orm;

type
  TUsers = class(TghModel)
  private
    FName: String;
    FAge: Integer;
    FBirthdate: String;
  published
    property Name: String read FName write FName;
    property Age: Integer read FAge write FAge;
    property Birthdate: String read FBirthdate write FBirthdate;
  end;

implementation

initialization
  RegisterClass(TUsers);

end.

