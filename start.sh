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

# Função para iniciar o servidor
start_server() {
    echo "Iniciando o servidor..." | tee -a $LOG_FILE
    # Executar o servidor em segundo plano e redirecionar a saída para o log
    ./$SERVER_PATH >> $LOG_FILE 2>&1 &
    SERVER_PID=$!
}

# Iniciar o servidor pela primeira vez
start_server

# Monitorar o servidor sem ps ou pgrep (usando a saída de erro do servidor)
while true; do
    # Esperar que o servidor tenha rodado um pouco antes de verificar
    sleep 10

    # Verificar se o servidor ainda está gerando logs ou se falhou
    if ! tail -n 20 $LOG_FILE | grep -q "Running Grand Larceny"; then
        echo "O servidor falhou ou fechou inesperadamente. Reiniciando..." | tee -a $LOG_FILE
        # Reiniciar o servidor
        start_server
    fi

    # Aguardar mais um pouco antes de verificar novamente
    sleep 5
done
