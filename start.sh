#!/bin/sh

# Caminhos
SERVER_PATH="./samp03svr"
LOG_DIR="./logs"
LOG_FILE="server.log"

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

# Remover log anterior
rm -f $LOG_FILE

# Iniciar o servidor e capturar saída no log
echo "Iniciando o servidor..."
./$SERVER_PATH > $LOG_FILE 2>&1 &

# Aguardar indefinidamente até detectar "Started" no log
echo "Aguardando o servidor iniciar..."

while true; do
    if grep -q "Started" $LOG_FILE; then
        echo "Started Servidor iniciado com sucesso!" 
        break
    fi
    sleep 10
done

# Manter o script rodando para que o contêiner não finalize
echo "Monitorando logs do servidor..."
tail -f $LOG_FILE
