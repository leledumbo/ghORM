unit ghORM;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, fgl, ghSQL;

type

  { TModel }

  TModel = class
  protected
    FID: Integer;
  public
    class function GetTableName: String; virtual; abstract;
    function Validate: Boolean; virtual; abstract;
    procedure LoadFromTable(ATable: TghSQLTable); virtual; abstract;
    procedure SaveToTable(ATable: TghSQLTable); virtual; abstract;
    procedure LoadRelationships(ALinks: TghSQLTableList); virtual;
    procedure SaveRelationships(ALinks: TghSQLTableList); virtual;
    property ID: Integer read FID;
  end;

  { TModelList }

  generic TModelList<T: TObject> = class(specialize TFPGObjectList<T>)
  public
    constructor Create;
  end;

  { TORM }

  generic TORM<T: TModel> = class
  protected
    function GetTable: TghSQLTable;
  public
    type TThisModelList = specialize TModelList<T>;
    constructor Create;
    function New: T;
    function Insert(o: T): Boolean;
    function Update(o: T): Boolean;
    function Delete(o: T): Boolean;
    function GetOne(id: Integer; out o: T): Boolean;
    function GetWhere(conditions: String; out ol: TThisModelList): Boolean;
    procedure LinkRelationships; virtual;
    procedure ResolveLinks(o: T);
  end;

procedure SetConn(AConn: TghSQLConnector);
function Conn: TghSQLConnector;

resourcestring
  rsDbConnUninitialized = 'Database connection has not been initialized';

implementation

var
  LConn: TghSQLConnector;

procedure SetConn(AConn: TghSQLConnector);
begin
  LConn := AConn;
end;

function Conn: TghSQLConnector;
begin
  if not Assigned(LConn) then
    raise EghSQLHandlerError(rsDbConnUninitialized);
  Result := LConn;
end;

{ TModel }

procedure TModel.LoadRelationships(ALinks: TghSQLTableList);
begin
  // intentionally left blank
end;

procedure TModel.SaveRelationships(ALinks: TghSQLTableList);
begin
  // intentionally left blank
end;

{ TModelList }

constructor TModelList.Create;
begin
  inherited Create(true);
end;

{ TORM }

function TORM.Delete(o: T): Boolean;
begin
  try
    GetTable.Where('id = %d',[o.ID]).Delete;
    Result := true;
  except
    Result := false;
  end;
end;

function TORM.GetOne(id: Integer; out o: T): Boolean;
var
  Tab: TghSQLTable;
begin
  Tab := GetTable.Where('id = %d',[id]).Open;
  Result := not Tab.EOF;
  if Result then begin
    o := T.Create;
    o.FID := Tab['id'].AsInteger;
    o.LoadFromTable(Tab);
  end;
end;

function TORM.GetWhere(conditions: String; out ol: TThisModelList): Boolean;
var
  Tab: TghSQLTable;
  o: T;
begin
  Tab := GetTable.Where(Conditions).Open;
  ol := TThisModelList.Create;
  while not Tab.EOF do begin
    o := T.Create;
    o.LoadFromTable(Tab);
    ol.Add(o);
    Tab.Next;
  end;
  Result := true;
end;

function TORM.Insert(o: T): Boolean;
var
  Tab: TghSQLTable;
begin
  try
    Tab := GetTable.Open;
    // first save the object, we need the id
    Tab.Insert;
    o.SaveToTable(Tab);
    Tab.Commit;
    // now we can use the id to save relationships
    o.FID := Tab['id'].AsInteger;
    Tab.Edit;
    o.SaveRelationships(Tab.Links);
    Tab.Commit;
    Result := true;
  except
    Result := false;
  end;
end;

function TORM.New: T;
begin
  Result := T.Create;
end;

function TORM.Update(o: T): Boolean;
var
  Tab: TghSQLTable;
begin
  try
    Tab := GetTable.Open;
    // already has id, we can save both the object and relationships in one go
    Tab.Edit;
    o.SaveToTable(Tab);
    o.SaveRelationships(Tab.Links);
    Tab.Commit;
    Result := true;
  except
    Result := false;
  end;
end;

function TORM.GetTable: TghSQLTable;
begin
  Result := Conn.Tables[T.GetTableName];
end;

procedure TORM.ResolveLinks(o: T);
var
  Tab: TghSQLTable;
begin
  Tab := GetTable.Where('id = %d',[o.ID]).Open;
  o.LoadRelationships(Tab.Links);
end;

constructor TORM.Create;
begin
  LinkRelationships;
end;

procedure TORM.LinkRelationships;
begin
  // intentionally left blank
end;

end.

