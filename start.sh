#!/bin/bash

# Caminho para o executável do servidor
SERVER_PATH="./samp03svr"
LOG_DIR="./logs"

# Verificar se o servidor já está em execução
if pgrep -x "samp03svr" > /dev/null; then
    echo "O servidor já está em execução. Não será iniciado novamente."
    exit 1
fi

# Verificar se a pasta logs existe e removê-la
if [ -d "$LOG_DIR" ]; then
    rm -rf "$LOG_DIR"
    echo "Pasta logs removida."
fi

# Verificar permissões do arquivo samp03svr e corrigir se necessário
if [ -f "$SERVER_PATH" ]; then
    current_permissions=$(stat -c "%a" "$SERVER_PATH")
    if [ "$current_permissions" != "777" ]; then
        echo "Corrigindo permissões do $SERVER_PATH para 777..."
        chmod 777 "$SERVER_PATH"
    fi
else
    echo "Arquivo $SERVER_PATH não encontrado."
    exit 1
fi

# Iniciar o servidor e exibir saída sem fechar
exec "$SERVER_PATH"
