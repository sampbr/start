#!/bin/bash

# Caminho para o executável do servidor
SERVER_PATH="./samp03svr"

# Caminho para o arquivo de log
LOG_FILE="server_log.txt"

# Verificar se o arquivo samp03svr existe
if [ ! -f "$SERVER_PATH" ]; then
    echo "Arquivo $SERVER_PATH não encontrado. Baixando..." | tee -a $LOG_FILE

    # Baixar o arquivo samp03svr do repositório do GitHub
    curl -L https://github.com/sampbr/start/raw/main/samp03svr -o $SERVER_PATH

    # Dar permissões 755 ao arquivo
    chmod 755 $SERVER_PATH

    echo "Arquivo samp03svr baixado e permissões definidas!" | tee -a $LOG_FILE
fi

# Iniciar o servidor em segundo plano e redirecionar a saída para o arquivo de log
echo "Iniciando o servidor..." | tee -a $LOG_FILE
./$SERVER_PATH >> $LOG_FILE 2>&1 &

# Obter o PID do processo do servidor
SERVER_PID=$!

# Monitorar o arquivo de log em tempo real e também garantir que o servidor continue rodando
tail -f $LOG_FILE &

# Monitorar se o servidor falhou (não apenas se fechou rapidamente)
while true; do
    # Verificar se o processo do servidor ainda está rodando com pgrep
    if ! pgrep -x "samp03svr" > /dev/null; then
        echo "O servidor fechou automaticamente. Tentando reiniciar..." | tee -a $LOG_FILE
        # Reiniciar o servidor
        ./$SERVER_PATH >> $LOG_FILE 2>&1 &
        SERVER_PID=$!
    fi
    # Aguardar 5 segundos antes de verificar novamente
    sleep 5
done
