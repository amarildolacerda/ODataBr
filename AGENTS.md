# Regras do Projeto — ODataBr Server

## Controle de versão

- **Alterações só podem ser feitas no branch `dev`**.
- Nunca commitar diretamente no branch `master` ou `main`.
- Commits devem ser em português ou inglês, com mensagens claras e concisas.
- Sempre fazer push para `origin/dev`.

## Código

- Seguir as convenções e padrões existentes no projeto (Delphi Pascal, OData).
- Não adicionar dependências externas sem necessidade.
- Testar alterações nos exemplos correspondentes antes de commitar.
- Manter especializações em arquivos separados.

## Linguagem e stack

- **Linguagem:** Object Pascal (Delphi)
- **Servidor HTTP:** Indy (TIdHTTPWebBrokerBridge)
- **Framework web:** DMVCFramework (bundled em `DMVC/`)
- **ORM:** FireDAC (Firebird, MySQL, MSSQL, Oracle, PostgreSQL)
- **Banco NoSQL:** MongoDB (via MongoWire, dialeto stub `oData.Dialect.Mongo`)
- **IDE:** Delphi Seattle (10), Berlin (10.1) ou Tokyo (10.2)
- **Extensão de arquivos:** `.pas` (units), `.dfm` (forms), `.dpr` (project),
  `.dpk` (package), `.dproj` (project config)

## Dependência externa

O ODataBr depende do repositório [MVCBr](https://github.com/amarildolacerda/MVCBr),
que deve estar clonado lado a lado (`../MVCBr/`). O Makefile e o .dpr já
configuram os paths de busca (unit path e include path) para encontrar os
arquivos do framework.

## Convenções de nomenclatura

### Prefixos obrigatórios

| Tipo | Prefixo | Exemplo |
|------|---------|---------|
| Classe | `T` | `TODataController` |
| Interface | `I` | `IODataDialect` |
| Exceção | `E` | `EODataParseError` |
| Campo privado | `F` | `FDialect` |
| Parâmetro | `A` | `ADialect` |
| Variável local | `L` | `LDialect` |
| Tipos enumerados | `T` | `TODataMethod` |
| Itens de enum | Prefixo curto | `odGet`, `odPost` |

### Nomenclatura de units

```
oData.{Camada}.{Subcamada}.pas
MVCBrServer.{Camada}.pas
```

Exemplos:
- `oData.Dialect.Firebird.pas` — dialeto Firebird
- `oData.SQL.FireDAC.pas` — execução SQL via FireDAC
- `oData.Parse.pas` — parser de query OData
- `MVCBrServer.WS.WebModule.pas` — WebModule do servidor
- `MVCBrServer.WS.Controller.pas` — controllers do servidor

### Nomenclatura de métodos

- Métodos de ação: verbos — `Execute`, `ParseQuery`, `BuildSQL`
- Getters: prefixo `Get` — `GetDialect`, `GetSQL`
- Setters: prefixo `Set` — `SetDialect`, `SetConnection`
- Métodos booleanos: prefixo `Is`, `Has`, `Can` — `IsSupported`,
  `HasFilter`, `CanHandle`

## Gerenciamento de memória (crítico)

- **Blocos vigiados:** Toda chamada a `.Create` de um `TObject` sem *Owner*
  DEVE ter a linha IMEDIATAMENTE seguinte como `try`:
  ```pascal
  var LList := TStringList.Create;
  try
    // uso
  finally
    LList.Free;
  end;
  ```
- **Objetos com Owner** (componentes VCL):
  `TMyComponent.Create(Self)` — o Owner assume o release
- **ARC via interfaces:** Objetos `TInterfacedObject` são liberados
  automaticamente ao sair do escopo

## SOLID

- **S** — Cada classe tem uma responsabilidade. `TODataParse` não executa SQL.
- **O** — Extensão via interfaces. `IODataDialect` permite novos dialetos.
- **L** — `TODataDialect` é substituível por qualquer dialeto específico.
- **I** — Interfaces coesas: `IODataDialect`, `IODataQuery`, `IODataParse`.
- **D** — Dependa de abstrações. Controller depende de `IODataDialect`, não de `TODataDialectFirebird`.

## Padrões de projeto

O framework MVCBr (dependência) já inclui implementações em `MVCBr.Patterns.*`:
Builder, Facade, Factory, Singleton, Mediator, Memento, Observer, Adapter,
Decorator, Composite, Strategy, States, Prototype, Lazy Loading.

Usar as implementações existentes em vez de criar novas.

## Estrutura de diretórios

```
ODataBr/
├── oData/             # Engine OData (parser, SQL, dialetos, cliente)
│   ├── MVC.oData.Base.pas
│   ├── oData.Parse.pas
│   ├── oData.SQL.pas
│   ├── oData.SQL.FireDAC.pas
│   ├── oData.Dialect.pas (base)
│   ├── oData.Dialect.Firebird.pas
│   ├── oData.Dialect.MySQL.pas
│   ├── oData.Dialect.MSSQL.pas
│   ├── oData.Dialect.Oracle.pas
│   ├── oData.Dialect.PostgreSQL.pas
│   ├── oData.Dialect.Mongo.pas (stub)
│   ├── oData.Engine.pas
│   ├── oData.Interf.pas
│   ├── oData.JSON.pas
│   ├── oData.Client.pas
│   ├── oData.Client.Builder.pas
│   ├── oData.Collections.pas
│   ├── oData.ServiceModel.pas
│   ├── oData.ProxyBase.pas
│   ├── oData.ProxyNoSql.pas (stub)
│   ├── oData.NoSql.pas (stub)
│   └── oData.Packet.*.pas
├── MVCBrServer/       # Código do servidor
│   ├── ODataBrServer.dpr         # Entry point (original)
│   ├── WS.WebModule.pas          # WebModule principal
│   ├── WS.Datamodule.pas         # DataModule (conexão BD)
│   ├── WS.Controller.pas         # Controller principal
│   ├── WS.QueryController.pas    # Controller de queries
│   ├── WS.HelloController.pas    # Health check
│   ├── WS.Common.pas             # Utilitários do servidor
│   ├── WSConfig/                 # Configuração visual (VCL)
│   ├── Models/                   # Models de configuração
│   ├── MVCServerAdmin.pas        # Admin endpoints
│   ├── MVCServerAutentication.pas# Autenticação (stub)
│   └── MVC*.pas                  # Middlewares (gzip, async)
├── DMVC/              # DMVCFramework (bundled, Apache 2.0)
│   ├── sources/       # Core do DMVCFramework
│   └── lib/           # LoggerPro, dmustache
├── Dockerfile         # Container Linux
├── docker-compose.yml # Servidor + Firebird
├── Makefile           # Build via dcc32.exe
├── dcc32.cfg          # Config do compilador
└── .github/workflows/ # CI/CD (GitHub Actions)
```

## Organização de units

```pascal
unit oData.Nome;

interface

uses
  { RTL },
  { DMVC },
  { MVCBr },
  { Projeto };

type
  { Enums e records }
  { Interfaces }
  { Classes }

implementation

uses
  { Units adicionais só da implementação };

{ Implementações agrupadas por classe }

end.
```

## Documentação

- Usar **XMLDoc** para métodos públicos e interfaces
- Comentários em **português** para o projeto brasileiro
- Não comentar código auto-explicativo — deixar o nome do método explicar

## OData

### Servidor

- Engine em `oData/MVC.oData.Base.pas`
- Dialetos em `oData/oData.Dialect.*.pas`
- SQL FireDAC em `oData/oData.SQL.FireDAC.pas`
- ServiceModel em `MVCBrServer/oData.ServiceModel.json`

### Cliente

- Builder em `oData/oData.Client.Builder.pas`
- Componentes VCL (no repositório MVCBr): `TODataDatasetAdapter`, `TODataFDMemTable`

## Configuração de banco (FireDAC)

### Firebird
```pascal
FConnection.DriverName := 'FB';
FConnection.Params.Values['CharacterSet'] := 'UTF8';
FConnection.Params.Values['SQLDialect'] := '3';
FConnection.Params.Values['PageSize'] := '16384';
FConnection.TxOptions.Isolation := xiReadCommitted;
```

### PostgreSQL
```pascal
FConnection.DriverName := 'PG';
FConnection.Params.Values['CharacterSet'] := 'UTF8';
```

### MySQL
```pascal
FConnection.DriverName := 'MySQL';
FConnection.Params.Values['CharacterSet'] := 'utf8mb4';
```

## Modos de execução do servidor

| Modo | Arquivo | Plataforma |
|------|---------|------------|
| Aplicação | `ODataBrServer.dpr` (raiz) | Windows |
| Windows Service | `MVCBrServer/MVCBrServerService.dpr` | Windows |
| ISAPI DLL | `MVCBrServer/MVCBrServer_ISAPI.dpr` | Windows (IIS) |
| Linux | `MVCBrServer/MVCBrServer_Linux.dpr` | Linux |

## Build e CI/CD

### Compilação por linha de comando

Usar `dcc32.exe` com o `Makefile` na raiz:

```
make server      - Compilar servidor OData
make clean       - Remover artefatos compilados
```

### CI/CD (GitHub Actions)

O workflow em `.github/workflows/build.yml` automatiza:
- Checkout do ODataBr + MVCBr
- Build do servidor (`ODataBrServer.dpr`)
- Executado em push para `dev`/`master` e PRs para `master`

### Configuração do compilador

O arquivo `dcc32.cfg` na raiz contém as configurações globais do compilador.
Ajustar paths de units conforme ambiente local.

Referência: https://github.com/amarildolacerda/delphi_deploy

## Docker

```bash
# Construir imagem (requer binário pré-compilado)
docker build -t odatabr-server .

# Executar com Firebird
docker compose up -d
```

## Testes (DUnit)

- Framework: **DUnit** (`TestFramework`, `TestExtensions`)
- Runner: `DUnitTestRunner.RunRegisteredTests`
- Classe base: `TTestCase`
- Setup/Teardown: `SetUp` / `TearDown` override
- Asserções: `CheckNotNull`, `CheckTrue`, `CheckSame`, `CheckEquals`
- Registro: `RegisterTest(TSuite)` em `initialization`
- Mock classes: `TFake*` ou `TMock*` prefixo, definidas localmente no arquivo de teste
- Nomenclatura: `Action_Condition_ExpectedResult`

### Anti-patterns em testes

- ❌ Acoplar teste ao banco real — use interfaces com `TFake*` ou `TMock*`
- ❌ Testar UI — teste apenas Domain/Application layer
- ❌ `try..except` genérico em métodos testados — quebra `Assert.WillRaise`

## Anti-patterns a evitar

- ❌ **God class / God unit** — units com milhares de linhas
- ❌ **Lógica de negócio em OnClick** — delegar a Services/Controllers
- ❌ **Uses circular** — resolver com separação em camadas
- ❌ **Variáveis globais** — usar injeção de dependência
- ❌ **Strings hardcoded** — usar `resourcestring` ou constantes
- ❌ **`with` statement** — reduz legibilidade
- ❌ **Magic numbers** — declarar constantes
- ❌ **Métodos > 30 linhas** — extrair em métodos menores
- ❌ **Concatenação de SQL** — usar parâmetros

## Novos dialetos

Para adicionar suporte a um novo banco:
1. Criar unit `oData.Dialect.NovoBanco.pas` estendendo `TODataDialect`
2. Implementar métodos: `DialectName`, `GetTopSkip`, `GetTop`, `GetSkip`, `GetIdentitySQL`
3. Adicionar no `uses` do `WS.WebModule.pas`
4. Testar com banco real
5. Atualizar `oData.ServiceModel.json` se necessário

## Novos arquivos no servidor

Ao criar novo código no servidor:
1. Controllers, Models, Middlewares em arquivos separados
2. Seguir padrão DMVCFramework (TMVCController)
3. Registrar no WebModule (`WS.WebModule.pas`)
4. Adicionar ao .dpr principal (`ODataBrServer.dpr`)
