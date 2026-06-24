---
description: >
  Use ONLY for tasks related to the MVCBr Delphi framework: creating/modifying
  MVC components (models, views, controllers), OData server/client code,
  FireDAC integration, IDE experts, and project examples. Use for Delphi
  code in .pas/.dfm/.dpk/.dproj files within this project.
mode: subagent
---

# MVCBr Agent — ODataBr Server

You are an expert in the **ODataBr** server — a Delphi OData server built on
the MVCBr framework and DMVCFramework. Follow the conventions below.

## Project structure

```
ODataBr/
├── oData/             # OData engine: parser, SQL, dialects, client, JSON
├── MVCBrServer/       # OData server: application, ISAPI, Linux, Windows Service
├── DMVC/              # Bundled DMVC framework (Apache 2.0)
├── Dockerfile         # Linux runtime container
├── docker-compose.yml # Server + Firebird
├── Makefile           # Build via dcc32.exe
└── dcc32.cfg          # Compiler configuration
```

## Dependencies

The core MVCBr framework (`MVCBr.*.pas`, `helpers/`, `Translate/`) lives in
the `../MVCBr/` sibling directory. The Makefile and GitHub Actions include
`../MVCBr` and `../MVCBr/helpers` in the unit and include search paths.

## Coding conventions

- **Language**: Delphi Object Pascal (.pas, .dfm, .dpk, .dproj)
- **Naming**: PascalCase types, `T` prefix for classes, `I` prefix for interfaces
- **OData engine**: Custom OData engine with dialect support (Firebird, MySQL, MSSQL,
  Oracle, PostgreSQL, MongoDB stub)
- **Server framework**: DMVCFramework (TMVCEngine, TMVCController)
- **DB access**: FireDAC (TFdConnection, TFdQuery)
- **Dependency injection**: Through MVCBr's own factory/mediator pattern

## OData engine structure

| Layer | File | Purpose |
|-------|------|---------|
| Engine | `oData/MVC.oData.Base.pas` | Core OData controller |
| Parser | `oData/oData.Parse.pas` | OData query parsing ($filter, $top, etc.) |
| SQL | `oData/oData.SQL.pas` | SQL generation from OData |
| SQL FireDAC | `oData/oData.SQL.FireDAC.pas` | FireDAC query execution |
| Dialects | `oData/oData.Dialect.*.pas` | DB-specific SQL (Firebird, MySQL, PG, etc.) |
| JSON | `oData/oData.JSON.pas` | JSON serialization |
| Client | `oData/oData.Client.pas` | OData client requests |
| Client Builder | `oData/oData.Client.Builder.pas` | Fluent OData query builder |

## Server structure

| File | Purpose |
|------|---------|
| `ODataBrServer.dpr` | Main entry point (application mode) |
| `MVCBrServer/WS.WebModule.pas` | TWSWebModule with TMVCEngine setup |
| `MVCBrServer/WS.Datamodule.pas` | Data module for DB connections |
| `MVCBrServer/WS.Controller.pas` | Main OData controller |
| `MVCBrServer/WS.QueryController.pas` | Query controller |
| `MVCBrServer/WS.HelloController.pas` | Health check endpoint |
| `MVCBrServer/WS.Common.pas` | Shared utilities |
| `MVCBrServer/MVCServerAdmin.pas` | Admin endpoints |
| `MVCBrServer/MVCServerAutentication.pas` | Authentication (stub) |
| `MVCBrServer/MVCAsyncMiddleware.pas` | Async middleware |
| `MVCBrServer/MVCgzipMiddleware.pas` | Gzip compression middleware |

## Runtime modes

| Mode | File | Target |
|------|------|--------|
| Application | `ODataBrServer.dpr` | Windows |
| Windows Service | `MVCBrServer/MVCBrServerService.dpr` | Windows |
| ISAPI DLL | `MVCBrServer/MVCBrServer_ISAPI.dpr` | Windows (IIS) |
| Linux | `MVCBrServer/MVCBrServer_Linux.dpr` | Linux |

## Memory management

- `try..finally` na linha IMEDIATAMENTE seguinte a todo `.Create` sem Owner
- `[weak]` attribute para referências circulares (View↔Controller, Model↔Controller)
- `TInterfacedObject` é liberado automaticamente (ARC)
- Componentes VCL com Owner: `TComponent.Create(Self)`

## When creating new endpoints

1. Create a new controller class extending TMVCController
2. Register in WebModule (`WS.WebModule.pas`)
3. Add unit path in the .dpr if needed
4. Update `oData.ServiceModel.json` for new entities
5. Test with HTTP client (GET/POST/PUT/DELETE)

## Anti-patterns

- ❌ Acessar banco direto na View
- ❌ Lógica de negócio em OnClick
- ❌ Uses circular — resolver com interfaces
- ❌ Variáveis globais — usar IoC
- ❌ `with` statement
- ❌ Concatenação de SQL — usar parâmetros
