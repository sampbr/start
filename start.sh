#!/bin/bash

# Caminho para o executável do servidor e arquivo de log
SERVER_PATH="./samp03svr"
LOG_FILE="./server_log.txt"

# Função para mostrar as últimas 35 linhas do arquivo de log
mostrar_ultimas_linhas_log() {
    if [ -f "$LOG_FILE" ]; then
        # Exibir as últimas 35 linhas do arquivo de log
        echo "Últimas 35 linhas do arquivo de log ($LOG_FILE):"
        tail -n 35 "$LOG_FILE"
    else
        echo "Arquivo de log $LOG_FILE não encontrado."
    fi
}

# Função para verificar se o servidor está rodando
verificar_servidor_rodando() {
    # Verificar se o processo samp03svr está em execução usando ps
    if ps aux | grep -v grep | grep -q "$SERVER_PATH"; then
        return 0  # O servidor está rodando
    else
        return 1  # O servidor não está rodando
    fi
}

# Função para monitorar o servidor
monitorar_servidor() {
    # Continuar verificando o log até encontrar que o servidor parou
    while true; do
        # Verificar se o servidor ainda está rodando
        if ! verificar_servidor_rodando; then
            echo "O servidor parou ou falhou."
            mostrar_ultimas_linhas_log  # Exibir as últimas 35 linhas de log
            exit 0  # Encerra o script se o servidor parar
        fi
        
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

# Monitorar o servidor e verificar quando ele parar
monitorar_servidor
