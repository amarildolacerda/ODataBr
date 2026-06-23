unit oData.Dialect.Mongo;

interface

uses
  oData.Dialect;

type
  TODataDialectMongo = class(TODataDialect)
  public
    function DialectName: string; override;
  end;

implementation

{ TODataDialectMongo }

function TODataDialectMongo.DialectName: string;
begin
  result := 'Mongo';
end;

end.
