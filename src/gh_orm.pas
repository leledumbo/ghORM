unit gh_orm;

{$mode objfpc}{$H+}
{$assertions on}
{$M+}

interface

uses
  gh_SQL, gvector;

type

  TghModel = class;

  { TghModelList }

  TghModelList = class(specialize TVector<TghModel>)
  public
    destructor Destroy; override;
  end;

  TghModelClass = class of TghModel;

  { TghModel }

  TghModel = class
  private
    function GetConnections(const ATargetTable: TghModelClass): TghModelList;
    function NewID: Integer;
  protected
    FID: Integer;
    class function GetTableClass: TghSQLTable;
    function GetTableInstance: TghSQLTable;
  public
    constructor Create; virtual;
    constructor Create(const AID: Integer);
    class procedure Connect1N(const ATargetTable: TghModelClass);
    class procedure ConnectMN(const ATargetTable: TghModelClass);
    procedure Save; virtual;
    procedure Load(const AID: Integer); virtual;
    property Connections[const ATargetTable: TghModelClass]: TghModelList read GetConnections;
  published
    property ID: Integer read FID;
  end;

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

{ TghModelList }

destructor TghModelList.Destroy;
var
  m: TghModel;
begin
  for m in Self do m.Free;
  inherited Destroy;
end;

class function TClassHash.hash(a: TClass; n: longint): longint;
var
  s: String;
  c: Char;
begin
  Result := 0;
  s := LowerCase(a.ClassName);
  for c in s do Inc(Result,Ord(c));
  Result := Result mod n;
end;

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
var
  ClassInfo: TClassInfo;
begin
  with ClassInfo do begin
    Name := AName;
    IDGeneratorName := AIDGeneratorName;
  end;
  ClassMap[AClass] := ClassInfo;
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

{ TghModel }

function TghModel.GetConnections(const ATargetTable: TghModelClass
  ): TghModelList;
var
  Rel: TghSQLTable;
begin
  if ClassMap.Contains(ATargetTable) then begin
    Result := TghModelList.Create;
    Rel := GetTableInstance.Links[ClassMap[ATargetTable].Name];
    Rel.First;
    while not Rel.EOF do begin
      Result.PushBack(ATargetTable.Create(Rel.Columns['id'].AsInteger));
      Rel.Next;
    end;
  end else
    raise EghSQLError.CreateFmt('%s is not a registered model class',[ATargetTable.ClassName]);
end;

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

class procedure TghModel.Connect1N(const ATargetTable: TghModelClass);
var
  TargetClassName: String;
begin
  if ClassMap.Contains(ATargetTable) then begin
    TargetClassName := ClassMap[ATargetTable].Name;
    GetTableClass.Relations[TargetClassName].Where(TargetClassName + '_id = :id');
  end else
    raise EghSQLError.CreateFmt('%s is not a registered model class',[ATargetTable.ClassName]);
end;

class procedure TghModel.ConnectMN(const ATargetTable: TghModelClass);
var
  ThisClassName,TargetClassName: String;
begin
  if ClassMap.Contains(ATargetTable) then begin
    ThisClassName := ClassMap[ClassType].Name;
    TargetClassName := ClassMap[ATargetTable].Name;
    GetTableClass
      .Relations[TargetClassName]
      .Where(
        Format(
          'id in (select %s_id from %s_%s where %s_id = :id)',
          [TargetClassName,ThisClassName,TargetClassName,ThisClassName]
        )
      )
      .OrderBy('id');
  end else
    raise EghSQLError.CreateFmt('%s is not a registered model class',[ATargetTable.ClassName]);
end;

initialization
  Connection := nil;
  ClassMap := TClassMap.Create;

finalization
  if Assigned(Connection) then Connection.Free;
  ClassMap.Free;

end.

