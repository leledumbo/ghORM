unit gh_orm;

{$mode objfpc}{$H+}
{$assertions on}
{$M+}

interface

uses
  gh_SQL;

type

  { TghModel }

  TghModel = class
  private
    function NewID: Integer;
  protected
    FID: Integer;
    class function GetTableClass: TghSQLTable;
    function GetTableInstance: TghSQLTable;
  public
    constructor Create; virtual;
    constructor Create(const AID: Integer);
    procedure Save; virtual;
    procedure Load(const AID: Integer); virtual;
    procedure Connect1N(const ATargetTable: String);
    procedure ConnectMN(const ATargetTable: String);
  published
    property ID: Integer read FID;
  end;

  TghModelClass = class of TghModel;

procedure RegisterClass(AClass: TghModelClass); inline;
procedure RegisterClass(AClass: TghModelClass; const AName: String); inline;
procedure RegisterClass(AClass: TghModelClass; const AName: String; const AIDGeneratorName: String);

procedure SetConnection(const ALib: TghSQLLibClass; const ADBName: String);
function GetConnection: TghSQLConnector; inline;

function ConnectionNameToLibClass(const AConName: String): TghSQLLibClass;

implementation

uses
  SysUtils,TypInfo,ghashmap,gh_SQLdbLib;

type

  { TClassHash }

  TClassHash = class
    class function hash(a:TClass; n:longint):longint; inline;
  end;

  TClassInfo = record
    Name: String;
    IDGeneratorName: String;
  end;

  TClassMap = specialize THashmap<TClass,TClassInfo,TClassHash>;

var
  Connection: TghSQLConnector;
  ClassMap: TClassMap;

procedure RegisterClass(AClass: TghModelClass); inline;
var
  ClassName: String;
begin
  ClassName := AClass.ClassName;
  Delete(ClassName,1,1);
  RegisterClass(AClass,ClassName);
end;

procedure RegisterClass(AClass: TghModelClass; const AName: String);
begin
  RegisterClass(AClass,AName,'');
end;

procedure RegisterClass(AClass: TghModelClass; const AName: String;
  const AIDGeneratorName: String);
begin
  with ClassMap[AClass] do begin
    Name := AName;
    IDGeneratorName := AIDGeneratorName;
  end;
end;

procedure SetConnection(const ALib: TghSQLLibClass; const ADBName: String);
begin
  if Assigned(Connection) then Connection.Free;
  Connection := TghSQLConnector.Create(ALib);
  with Connection do begin
    Database := ADBName;
    Connect;
  end;
end;

function GetConnection: TghSQLConnector; inline;
begin
  Result := Connection;
  Assert(Assigned(Result));
end;

function ConnectionNameToLibClass(const AConName: String): TghSQLLibClass;
begin
  case LowerCase(AConName) of
    'sqlite3'  : Result := TghSQLite3Lib;
    'interbase': Result := TghIBLib;
    'firebird' : Result := TghFirebirdLib;
    'mssql'    : Result := TghMSSQLLib;
    else         Result := nil;
  end;
end;

class function TClassHash.hash(a: TClass; n: longint): longint;
begin
  Result := PtrUInt(a) mod n;
end;

{ TghModel }

function TghModel.NewID: Integer;
begin
  Result := Connection.Lib.GetSequenceValue(ClassMap[ClassType].IDGeneratorName);
end;

class function TghModel.GetTableClass: TghSQLTable;
begin
  Result := GetConnection.Tables[ClassMap[ClassType].Name];
end;

function TghModel.GetTableInstance: TghSQLTable;
begin
  Result := GetTableClass.Where('id = ' + IntToStr(FID)).Open;
end;

constructor TghModel.Create;
begin
  FID := NewID;
end;

constructor TghModel.Create(const AID: Integer);
begin
  Load(AID);
end;

procedure TghModel.Save;
var
  t: TghSQLTable;
  PropCount,i: Integer;
  Props: PPropList;
  Prop: PPropInfo;
begin
  t := GetTableInstance;
  PropCount := GetPropList(Self,Props);
  try
    if t.EOF then t.Insert else t.Edit;
    for i := 0 to PropCount - 1 do begin
      Prop := Props^[i];
      case Prop^.PropType^.Kind of
        tkInteger, tkChar, tkWChar, tkBool:
          t.Columns[Prop^.Name].AsInteger := GetOrdProp(Self,Prop);
        tkFloat:
          t.Columns[Prop^.Name].AsFloat := GetFloatProp(Self,Prop);
        tkString, tkAString, tkLString:
          t.Columns[Prop^.Name].AsString := GetStrProp(Self,Prop);
        tkWString:
          t.Columns[Prop^.Name].AsWideString := GetWideStrProp(Self,Prop);
        tkInt64, tkQWord:
          t.Columns[Prop^.Name].AsLargeInt := GetInt64Prop(Self,Prop);
      end;
    end;
    t.Post;
    t.Commit;
  finally
    FreeMem(Props);
  end;
end;

procedure TghModel.Load(const AID: Integer);
var
  t: TghSQLTable;
  PropCount,i: Integer;
  Props: PPropList;
  Prop: PPropInfo;
begin
  FID := AID;
  t := GetTableInstance;
  if t.EOF then raise EghSQLError.CreateFmt(
    'No row in table %s having ID = %d',
    [ClassMap[TghModelClass(ClassType)].Name,AID]
  );
  PropCount := GetPropList(Self,Props);
  try
    for i := 0 to PropCount - 1 do begin
      Prop := Props^[i];
      case Prop^.PropType^.Kind of
        tkInteger, tkChar, tkWChar, tkBool:
          SetOrdProp(Self,Prop,t.Columns[Prop^.Name].AsInteger);
        tkFloat:
          SetFloatProp(Self,Prop,t.Columns[Prop^.Name].AsFloat);
        tkString, tkAString, tkLString:
          SetStrProp(Self,Prop,t.Columns[Prop^.Name].AsString);
        tkWString:
          SetWideStrProp(Self,Prop,t.Columns[Prop^.Name].AsWideString);
        tkInt64, tkQWord:
          SetInt64Prop(Self,Prop,t.Columns[Prop^.Name].AsLargeInt);
      end;
    end;
  finally
    FreeMem(Props);
  end;
end;

procedure TghModel.Connect1N(const ATargetTable: String);
begin
  GetTableClass.Relations[ATargetTable].Where('id = :' + ATargetTable + '_id')
end;

procedure TghModel.ConnectMN(const ATargetTable: String);
var
  ThisClassName: String;
begin
  ThisClassName := ClassMap[ClassType].Name;
  GetTableClass
    .Relations[ATargetTable]
    .Where(
      Format(
        'id in (select %s_id from %s_%s where %s_id = :id)',
        [ATargetTable,ThisClassName,ATargetTable,ThisClassName]
      )
    )
    .OrderBy('id');
end;

initialization
  Connection := nil;
  ClassMap := TClassMap.Create;

finalization
  if Assigned(Connection) then Connection.Free;
  ClassMap.Free;

end.

