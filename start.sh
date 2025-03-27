#!/bin/bash

# Caminho para o executável do servidor
SERVER_PATH="./samp03svr"
LOG_DIR="./logs"

# Remover a pasta logs se existir
if [ -d "$LOG_DIR" ]; then
    echo "Removendo pasta logs..."
    rm -rf "$LOG_DIR"
fi

# Verificar se o arquivo samp03svr existe, senão baixar
if [ ! -f "$SERVER_PATH" ]; then
    echo "Arquivo $SERVER_PATH não encontrado. Baixando..."
    curl -L https://github.com/sampbr/start/raw/main/samp03svr -o "$SERVER_PATH"
    
    # Verificar se o download foi bem-sucedido
    if [ ! -f "$SERVER_PATH" ]; then
        echo "Falha ao baixar o arquivo. Verifique a conexão ou o link."
        exit 1
    fi

    echo "Arquivo baixado com sucesso!"
fi

# Garantir que o arquivo samp03svr tem permissão 777
chmod 777 "$SERVER_PATH"

# Iniciar o servidor e exibir saída
echo "Iniciando o servidor..."
exec "$SERVER_PATH"
