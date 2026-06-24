---
name: ODataBr OData
description: >
  Guia para criar e modificar endpoints OData, dialetos de banco,
  service models e componentes do servidor ODataBr.
---

# ODataBr OData — Skill para Servidor OData

## Quando usar

Use esta skill ao criar **endpoints OData**, **dialetos** para novos bancos,
**service models**, ou modificar o servidor ODataBr.

## Arquitetura do OData

### Servidor

```
ODataBrServer (.dpr)
  └── WS.WebModule (TWSWebModule)
        └── TMVCEngine
              └── Controllers (WS.HelloController, WS.QueryController)
                    └── TODataController (MVC.oData.Base.pas)
                          ├── TODataParse (parser de query)
                          ├── TODataSQL (geração SQL)
                          ├── TODataDialect* (dialetos por banco)
                          └── TODataFiredacQuery (execução FireDAC)
```

### Engine OData

| Camada | Arquivo | Descrição |
|--------|---------|-----------|
| Engine | `oData/MVC.oData.Base.pas` | `TODataController` base |
| Parser | `oData/oData.Parse.pas` | Parse de $filter, $top, $skip, $orderby |
| SQL | `oData/oData.SQL.pas` | Geração de SQL genérico |
| SQL FireDAC | `oData/oData.SQL.FireDAC.pas` | Execução via FireDAC |
| Dialeto base | `oData/oData.Dialect.pas` | Classe base de dialetos |
| Firebird | `oData/oData.Dialect.Firebird.pas` | Dialeto Firebird |
| MySQL | `oData/oData.Dialect.MySQL.pas` | Dialeto MySQL |
| MSSQL | `oData/oData.Dialect.MSSQL.pas` | Dialeto SQL Server |
| Oracle | `oData/oData.Dialect.Oracle.pas` | Dialeto Oracle |
| PostgreSQL | `oData/oData.Dialect.PostgreSQL.pas` | Dialeto PostgreSQL |
| JSON | `oData/oData.JSON.pas` | Serialização JSON |
| Client | `oData/oData.Client.pas` | HTTP client |
| Client Builder | `oData/oData.Client.Builder.pas` | Fluent query builder |

### Servidor

| Arquivo | Descrição |
|---------|-----------|
| `ODataBrServer.dpr` (raiz) | Aplicação servidor (Windows) |
| `MVCBrServer/ODataBrServer.dpr` | Entry point alternativo |
| `MVCBrServer/MVCBrServer_ISAPI.dpr` | ISAPI DLL |
| `MVCBrServer/MVCBrServer_Linux.dpr` | Linux server |
| `MVCBrServer/MVCBrServerService.dpr` | Windows Service |
| `MVCBrServer/oData.ServiceModel.json` | Metadados OData |

## Como criar um dialeto para novo banco

### 1. Criar a unit do dialeto

```pascal
unit oData.Dialect.NovoBanco;

interface

uses
  oData.Dialect,
  oData.Interf;

type
  TODataDialectNovoBanco = class(TODataDialect)
  public
    function DialectName: string; override;
    function GetTopSkip(var ASQL: string; ATop, ASkip: integer): string; override;
    function GetTop(var ASQL: string; ATop: integer): string; override;
    function GetSkip(var ASQL: string; ASkip: integer): string; override;
    function GetIdentitySQL: string; override;
  end;

implementation

{ TODataDialectNovoBanco }

function TODataDialectNovoBanco.DialectName: string;
begin
  result := 'NovoBanco';
end;

// Implementar métodos específicos do dialeto
```

### 2. Registrar no WebModule

Adicionar a unit na cláusula `uses` de `MVCBrServer/WS.WebModule.pas`:

```pascal
uses
  // ... existing units ...
  oData.Dialect.NovoBanco;
```

### 3. Configurar o TODataFiredacQueryRS

Em `MVCBrServer/WS.WebModule.pas`, o método `DialectClass` mapeia
driver name → dialeto:

```pascal
function TODataFiredacQueryRS.DialectClass: TODataDialectClass;
var
  drv: string;
begin
  drv := oDataConnection.Params.DriverName;
  if drv = 'FB' then
    result := TODataDialectFirebird
  else if drv = 'MySQL' then
    result := TODataDialectMySQL
  else if drv = 'MSSQL' then
    result := TODataDialectMSSQL
  else if drv = 'Ora' then
    result := TODataDialectOracle
  else if drv = 'PG' then
    result := TODataDialectPostgreSQL
  else if drv = 'Mongo' then
    result := TODataDialectMongo
  else
    result := TODataDialect;
end;
```

## ServiceModel (MVCBrServer/oData.ServiceModel.json)

O arquivo `MVCBrServer/oData.ServiceModel.json` define as entidades disponíveis:

```json
{
  "namespace": "MVCBr",
  "entities": [
    {
      "name": "Clientes",
      "table": "CLIENTES",
      "keys": ["ID"],
      "properties": [
        { "name": "ID", "type": "Edm.Int32", "nullable": false },
        { "name": "NOME", "type": "Edm.String", "maxLength": 100 },
        { "name": "ATIVO", "type": "Edm.Boolean" }
      ]
    }
  ],
  "import": ["outro_model.json"]
}
```

## Configuração de banco (FireDAC) no servidor

Configurar em `MVCBrServer.config` ou diretamente no código:

```pascal
// Firebird
FConnection.DriverName := 'FB';
FConnection.Params.Values['CharacterSet'] := 'UTF8';
FConnection.Params.Values['SQLDialect'] := '3';
FConnection.Params.Values['PageSize'] := '16384';
FConnection.TxOptions.Isolation := xiReadCommitted;

// PostgreSQL
FConnection.DriverName := 'PG';
FConnection.Params.Values['CharacterSet'] := 'UTF8';

// MySQL
FConnection.DriverName := 'MySQL';
FConnection.Params.Values['CharacterSet'] := 'utf8mb4';
```

## Cliente OData (VCL)

Os componentes cliente estão no repositório MVCBr (`../MVCBr/VCL/`).

```pascal
var
  LBuilder: TODataClientBuilder;
  LDataSet: TODataFDMemTable;
begin
  LBuilder := TODataClientBuilder.Create(nil);
  try
    LBuilder.URL('http://servidor/odata')
      .Resource('Clientes')
      .Filter("NOME eq 'Joao'")
      .Top(10)
      .Skip(0);

    LDataSet := TODataFDMemTable.Create(nil);
    LDataSet.Builder(LBuilder);
    LDataSet.Open;
  finally
    LBuilder.Free;
  end;
end;
```

## Docker

```bash
# Construir imagem (requer binário pré-compilado)
docker build -t odatabr-server .

# Executar com Firebird
docker compose up -d
```

Servidor disponível em `http://localhost:8080/odata`.

## Verificação

- [ ] Dialeto implementa todos os métodos da classe base
- [ ] ServiceModel.json com entidades e propriedades corretas
- [ ] Testado com banco real
- [ ] Query OData ($filter, $top, $skip, $orderby) funcionando
- [ ] CRUD (POST, PUT/PATCH, DELETE) operacional
- [ ] Metadata/ServiceModel retornando corretamente
