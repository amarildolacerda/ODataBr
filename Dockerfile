# Dockerfile — ODataBr Server (Linux runtime)
#
# Esta imagem EXECUTA o servidor ODataBr pré-compilado para Linux.
# A compilação deve ser feita separadamente (IDE Delphi ou GitHub Actions).
#
# Uso:
#   1. Compile ODataBrServer.dpr (produz bin/ODataBrServer)
#   2. docker build -t odatabr-server .
#   3. docker run -p 8080:8080 odatabr-server

FROM ubuntu:22.04 AS base
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates libc6 \
    && rm -rf /var/lib/apt/lists/*

FROM base AS fb
RUN apt-get update && apt-get install -y --no-install-recommends \
    libfbclient2 \
    && rm -rf /var/lib/apt/lists/*

FROM base AS pg
RUN apt-get update && apt-get install -y --no-install-recommends \
    libpq5 \
    && rm -rf /var/lib/apt/lists/*

FROM fb
COPY --from=pg /usr/lib/x86_64-linux-gnu/libpq* /usr/lib/x86_64-linux-gnu/

WORKDIR /app
COPY --chmod=755 ODataBrServer /app/ODataBrServer
COPY --chmod=644 MVCBrServer.config /app/MVCBrServer.config

EXPOSE 8080
ENTRYPOINT ["/app/ODataBrServer"]
