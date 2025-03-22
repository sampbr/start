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

# Iniciar o servidor
echo "Iniciando o servidor..."
exec ./$SERVER_PATH
