#!/bin/bash

# Caminho para o executável do servidor e arquivo de log
SERVER_PATH="./samp03svr"
LOG_FILE="./server_log.txt"

# Função para mostrar as últimas 35 linhas do arquivo de log
mostrar_ultimas_linhas_log() {
    if [ -f "$LOG_FILE" ]; then
        # Exibir as últimas 35 linhas do arquivo de log
        echo "Últimas 35 linhas do arquivo de log ($LOG_FILE):"
        tail -n 50 "$LOG_FILE"
    else
        echo "Arquivo de log $LOG_FILE não encontrado."
    fi
}

# Função para verificar se o servidor está rodando
verificar_servidor() {
    # Verificar se o processo do servidor está em execução
    if ! pgrep -x "samp03svr" > /dev/null; then
        echo "O processo do servidor samp03svr não está mais rodando."
        return 1  # Retorna 1 se o processo não estiver rodando
    else
        return 0  # Retorna 0 se o processo estiver rodando
    fi
}

# Função para monitorar o servidor e mostrar os logs
monitorar_servidor() {
    while true; do
        # Verificar se o servidor ainda está rodando
        if ! verificar_servidor; then
            echo "O servidor fechou automaticamente. Exibindo últimas 35 linhas do log."
            mostrar_ultimas_linhas_log
            exit 0
        fi

        # Exibir as últimas 35 linhas de log enquanto o servidor estiver rodando
        mostrar_ultimas_linhas_log
        
        # Aguardar 5 segundos antes de verificar novamente
        sleep 5
    done
}

# Verificar se o arquivo samp03svr existe
if [ ! -f "$SERVER_PATH" ]; then
    echo "Arquivo $SERVER_PATH não encontrado. Baixando..."

    # Baixar o arquivo samp03svr do repositório do GitHub
    curl -L https://github.com/sampbr/start/raw/main/samp03svr -o $SERVER_PATH

    # Dar permissões 755 ao arquivo
    chmod 755 $SERVER_PATH

    echo "Arquivo samp03svr baixado e permissões definidas!"
fi

# Iniciar o servidor em segundo plano
echo "Iniciando o servidor..."
./$SERVER_PATH &  # Rodando o servidor em segundo plano

# Aguardar o servidor iniciar
sleep 5

# Monitorar o servidor e mostrar os logs
monitorar_servidor
