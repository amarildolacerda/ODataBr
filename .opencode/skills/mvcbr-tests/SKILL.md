---
name: ODataBr Tests (DUnit)
description: >
  Guia para escrever testes unitários no servidor ODataBr usando DUnit.
  Cobre padrões de teste, mocks/fakes, e anti-patterns.
---

# ODataBr Tests — Skill para Testes com DUnit

## Quando usar

Use esta skill ao criar **testes unitários** para Controllers, Models,
Dialetos OData e Patterns do servidor ODataBr.

## Stack de testes

- **Framework:** DUnit (`TestFramework`, `TestExtensions`)
- **Runner:** `DUnitTestRunner.RunRegisteredTests`
- **Classe base:** `TTestCase`
- **Flag condicional:** `CONSOLE_TESTRUNNER` para modo console

## Template de teste

```pascal
unit TestODataBr.Something;

interface

uses
  TestFramework,
  oData.Interf;

type
  TestTSomething = class(TTestCase)
  strict private
    FSut: IInterface; // System Under Test
  public
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure DoSomething_WithValidParams_ReturnsExpectedResult;
    procedure DoSomething_WithInvalidParams_RaisesException;
  end;

implementation

{ TestTSomething }

procedure TestTSomething.SetUp;
begin
  FSut := TMyClass.Create as IMyInterface;
end;

procedure TestTSomething.TearDown;
begin
  FSut := nil; // Interface ARC libera automaticamente
end;

procedure TestTSomething.DoSomething_WithValidParams_ReturnsExpectedResult;
begin
  CheckNotNull(FSut);
  CheckTrue(FSut.DoSomething);
end;

procedure TestTSomething.DoSomething_WithInvalidParams_RaisesException;
begin
  // Usar WillRaise com anonymous method
end;

initialization
  RegisterTest(TestTSomething.Suite);
end.
```

## Padrões de asserção

| Método | Uso |
|--------|-----|
| `CheckTrue(ACondition)` | Condição verdadeira |
| `CheckFalse(ACondition)` | Condição falsa |
| `CheckEquals(A, B)` | Igualdade |
| `CheckSame(A, B)` | Mesma instância (ponteiros) |
| `CheckNotNull(AObj)` | Não é nil |
| `CheckNull(AObj)` | É nil |
| `CheckNotEquals(A, B)` | Diferença |
| `WillRaise(AMethod, EExceptionClass)` | Exceção esperada |

## Mocks e Fakes

Classes mock/fake devem ser definidas localmente no arquivo de teste:

```pascal
type
  TFakeDialect = class(TInterfacedObject, IODataDialect)
  private
    FName: string;
  public
    function DialectName: string;
    function GetTopSkip(var ASQL: string; ATop, ASkip: integer): string;
    function GetTop(var ASQL: string; ATop: integer): string;
    function GetSkip(var ASQL: string; ASkip: integer): string;
    function GetIdentitySQL: string;
  end;
```

## Testando dialetos OData

```pascal
procedure TestTODataDialectFirebird.TestTopSkip;
var
  LSQL: string;
begin
  LSQL := 'SELECT * FROM CLIENTES';
  FSut.GetTopSkip(LSQL, 10, 20);
  CheckTrue(Pos('FIRST 10', LSQL) > 0);
  CheckTrue(Pos('SKIP 20', LSQL) > 0);
end;
```

## Testando o parser OData

```pascal
procedure TestTODataParse.TestFilter;
var
  LResult: string;
begin
  LResult := FSut.BuildWhere("NOME eq 'Joao'");
  CheckEquals("WHERE NOME = 'Joao'", LResult);
end;
```

## Testando controllers do servidor

Usar mocks para simular o DataModule e conexão:

```pascal
type
  TFakeDataModule = class(TInterfacedObject, IWSDataModule)
    // Implementação fake
  end;
```

## Nomenclatura de testes

Usar o padrão: `Ação_Condição_ResultadoEsperado`

| Exemplo | Descrição |
|---------|-----------|
| `TestParseFilter_SimpleExpression_ReturnsSQL` | Parse de filter simples |
| `TestDialect_GetTopSkip_PositionCorrect` | Posicionamento TOP/SKIP |
| `TestSQL_SelectAll_NoFilter` | Select sem filtro |
| `TestBuildSQL_WithTop_ReturnsLimitedSQL` | SQL com TOP |

## Anti-patterns em testes

- ❌ **Acoplar teste ao banco real** — usar TFake* ou TMock* com interfaces
- ❌ **Testar UI** — testar apenas Domain e Application layer
- ❌ **`try..except` genérico em métodos testados** — quebra `WillRaise`
- ❌ **Testes que dependem de ordem** — cada teste deve ser independente
- ❌ **Setup complexo** — extrair em métodos auxiliares
- ❌ **Variáveis globais entre testes** — usar campos da classe de teste

## Verificação

- [ ] Teste segue o padrão `SetUp` / `TearDown`
- [ ] Nome do teste segue `Ação_Condição_Resultado`
- [ ] Usa Fakes/Mocks para isolar dependências
- [ ] Não acopla a banco real ou UI
- [ ] Registrado via `RegisterTest` no `initialization`
- [ ] Compila sem warnings
