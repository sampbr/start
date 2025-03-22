#!/bin/bash

# Caminho para o executável do servidor
SERVER_PATH="./samp03svr"
LOG_DIR="./logs"
CFG_FILE="./server.cfg"

# Verificar se o servidor já está em execução
if pgrep -x "samp03svr" > /dev/null; then
    echo "O servidor já está em execução. Não será iniciado novamente."
    exit 1
fi

# Verificar se a pasta logs existe e removê-la
if [ -d "$LOG_DIR" ]; then
    echo "Pasta logs identificada. Tentando remover..."
    rm -rf "$LOG_DIR"
    
    if [ ! -d "$LOG_DIR" ]; then
        echo "Pasta logs removida com sucesso!"
    else
        echo "Falha ao remover a pasta logs. Verifique as permissões ou se a pasta está em uso."
    fi
else
    echo "Pasta logs não encontrada. Nenhuma ação necessária."
fi

# Verificar se o arquivo samp03svr existe
if [ ! -f "$SERVER_PATH" ]; then
    echo "Arquivo $SERVER_PATH não encontrado. Baixando..."
    
    curl -L https://github.com/sampbr/start/raw/main/samp03svr -o $SERVER_PATH
    
    chmod 755 $SERVER_PATH
    
    echo "Arquivo samp03svr baixado e permissões definidas!"
else
    current_permissions=$(stat -c "%a" "$SERVER_PATH")
    if [ "$current_permissions" != "755" ]; then
        echo "Permissões do arquivo $SERVER_PATH não estão como 755. Corrigindo..."
        chmod 755 $SERVER_PATH
        clear
    fi
fi

# Iniciar o servidor e capturar a saída
echo "Iniciando o servidor..."
./$SERVER_PATH +exec $CFG_FILE > $LOG_DIR/server_output.log &

# Esperar até 40 segundos e verificar se a mensagem "Started server on port" aparece
TIMEOUT=40
STARTED_MSG="Started server on port"

for ((i=0; i<$TIMEOUT; i++)); do
    if grep -q "$STARTED_MSG" $LOG_DIR/server_output.log; then
        echo "Started"
        exit 0
    fi
    sleep 1
done

# Se a mensagem não apareceu em 40 segundos, fechar o processo usando kill
echo "O servidor não iniciou corretamente dentro do tempo limite. Fechando..."

# Encontrar o PID do processo e matar o servidor
PID=$(pgrep -x "samp03svr")
if [ -n "$PID" ]; then
    kill "$PID"
    echo "Servidor fechado com o PID $PID."
else
    echo "Não foi possível encontrar o PID do servidor."
fi

exit 1
