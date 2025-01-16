#!/bin/bash

# Caminho para o executável do servidor
SERVER_PATH="./samp03svr"
LOG_FILE="server_log.txt"

# Verificar se o arquivo samp03svr existe
if [ ! -f "$SERVER_PATH" ]; then
    echo "Arquivo $SERVER_PATH não encontrado. Baixando..."

    # Baixar o arquivo samp03svr do repositório do GitHub
    curl -sSL -o $SERVER_PATH https://github.com/sampbr/start/raw/main/samp03svr

    # Dar permissões 755 ao arquivo
    chmod 755 $SERVER_PATH

    echo "Arquivo samp03svr baixado e permissões definidas!"
fi

# Iniciar o servidor
echo "Iniciando o servidor..."
./$SERVER_PATH &

# Armazenar o PID do servidor
SERVER_PID=$!

# Monitorar o arquivo de log em tempo real
echo "Monitorando o log do servidor..."
tail -f $LOG_FILE &

# Esperar até que o servidor pare
wait $SERVER_PID

# Quando o servidor parar, exibir uma mensagem
echo "O servidor foi interrompido. Exibindo os logs."
