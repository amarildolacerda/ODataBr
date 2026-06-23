# ODataBr Server

Servidor OData para Delphi com suporte a Firebird, MySQL, MSSQL, Oracle e PostgreSQL.

Baseado no framework [MVCBr](https://github.com/amarildolacerda/MVCBr).

## Estrutura

```
ODataBr/
├── oData/            # Engine OData (parser, SQL, dialetos)
├── MVCBrServer/      # Código do servidor (WebModule, controllers)
├── DMVC/             # DMVC Framework (bundled)
├── helpers/          # Utilitários (JSON, ThreadSafe)
├── Translate/        # Arquivos de tradução
├── Dockerfile        # Container Linux
└── docker-compose.yml # Servidor + Firebird
```

## Compilar

```bash
# Com dcc32.exe (Delphi command-line)
make server

# Ou diretamente
dcc32 ODataBrServer.dpr
```

## Executar

```bash
# Windows
ODataBrServer.exe

# Linux
./ODataBrServer_Linux

# Docker
docker compose up -d
```

## Configuração

Edite `MVCBrServer.config`:

```json
{
  "Config": {
    "WSPort": "8080",
    "driverid": "FB",
    "Server": "localhost",
    "Database": "mvcbr",
    "user_name": "sysdba",
    "Password": "masterkey"
  }
}
```

## Docker

```bash
# Construir imagem
docker build -t odatabr-server .

# Executar com banco
docker compose up -d
```

Servidor disponível em `http://localhost:8080/odata`.
