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

# Iniciar o servidor em segundo plano
echo "Iniciando o servidor..."
./$SERVER_PATH &

# Armazenar o PID do processo do servidor
SERVER_PID=$!

# Monitorar o arquivo de log em tempo real
echo "Monitorando o log do servidor..."
tail -f $LOG_FILE &

# Monitorar se o servidor fechou sozinho (processo terminado)
while true; do
    # Usar pgrep para verificar se o processo ainda está rodando
    if ! pgrep -f "samp03svr" > /dev/null; then
        echo "O servidor fechou automaticamente. Encerrando o script."
        exit 0
    fi
    # Aguardar 5 segundos antes de verificar novamente
    sleep 5
done
