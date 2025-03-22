#!/bin/sh

# Caminhos
SERVER_PATH="./samp03svr"
LOG_DIR="./logs"

# Remover pasta de logs se existir
if [ -d "$LOG_DIR" ]; then
    echo "Pasta logs identificada. Removendo..."
    rm -rf "$LOG_DIR"
fi

# Verificar se o executável do SAMP existe
if [ ! -f "$SERVER_PATH" ]; then
    echo "Servidor não encontrado. Baixando..."
    curl -L https://github.com/sampbr/start/raw/main/samp03svr -o $SERVER_PATH
    chmod +x $SERVER_PATH
fi

# Iniciar o servidor em background
echo "Iniciando o servidor..."
./$SERVER_PATH &

# Capturar o PID do servidor
SERVER_PID=$!

# Aguardar 10 segundos
sleep 10

# Verificar se o servidor ainda está rodando
if kill -0 $SERVER_PID 2>/dev/null; then
    echo "Started"
else
    echo "Servidor fechou inesperadamente. Encerrando script."
    exit 1
fi

# Manter o script rodando para não fechar o contêiner
wait $SERVER_PID
