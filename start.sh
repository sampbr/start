#!/bin/bash

# Caminho para o executável do servidor
SERVER_PATH="./samp03svr"

# Iniciar o servidor e capturar a saída
echo "Iniciando o servidor..."
output=$(./$SERVER_PATH)

# Verificar se o servidor iniciou corretamente
echo "$output" | grep -q "Started server..."

# Se a mensagem "Started server..." estiver na saída, o servidor iniciou corretamente
if [ $? -eq 0 ]; then
    echo "Servidor iniciado com sucesso!"
else
    # Se não encontrar a mensagem, significa que falhou
    echo "Falha ao iniciar o servidor. Encerrando o script."
    exit 1
fi
