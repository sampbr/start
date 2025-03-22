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
fi

# Verificar e corrigir permissões do servidor
CURRENT_PERM=$(ls -l "$SERVER_PATH" | awk '{print $1}')
if [ "$CURRENT_PERM" != "-rwxrwxrwx" ]; then
    echo "Corrigindo permissões do $SERVER_PATH para 777..."
    chmod 777 "$SERVER_PATH"
fi

# Iniciar o servidor e capturar a saída
echo "Iniciando o servidor..."
./$SERVER_PATH 2>&1 | while read line; do
    echo "$line"
    
    # Verificar se a linha contém a mensagem de inicialização do servidor
    if echo "$line" | grep -q "Started server on port"; then
        echo "Started :) (Servidor Online!)"
        exit 0  # Finaliza o loop, mas mantém o servidor rodando
    fi
done

# Se o servidor encerrar sem exibir a mensagem, finalizar o script
echo "Servidor fechou inesperadamente. Encerrando script."
exit 1
