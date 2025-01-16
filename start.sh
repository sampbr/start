#!/bin/bash

# Caminho para o executável do servidor
SERVER_PATH="./samp03svr"
LOG_FILE="server_log.txt"

# Função para iniciar o servidor
start_server() {
    echo "Iniciando o servidor..."
    ./$SERVER_PATH &
    SERVER_PID=$!
}

# Função para monitorar os logs
monitor_logs() {
    echo "Monitorando o log do servidor..."
    tail -f $LOG_FILE
}

# Verificar se o arquivo samp03svr existe
if [ ! -f "$SERVER_PATH" ]; then
    echo "Arquivo $SERVER_PATH não encontrado. Baixando..."

    # Baixar o arquivo samp03svr do repositório do GitHub
    curl -sSL -o $SERVER_PATH https://github.com/sampbr/start/raw/main/samp03svr

    # Dar permissões 755 ao arquivo
    chmod 755 $SERVER_PATH

    echo "Arquivo samp03svr baixado e permissões definidas!"
fi

# Iniciar o servidor e monitorar os logs
start_server
monitor_logs &

# Continuar monitorando os logs sem encerrar o script
while true; do
    # Verificar se o processo do servidor está rodando sem usar ps/pgrep
    if ! kill -0 $SERVER_PID 2>/dev/null; then
        echo "O servidor fechou automaticamente, mas os logs ainda estão sendo exibidos."
    fi
    # Aguardar 5 segundos antes de verificar novamente
    sleep 5
done
