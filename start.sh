#!/bin/bash

# Caminho para o executável do servidor
SERVER_PATH="./samp03svr"
LOG_FILE="./server_log.txt"

# Função para mostrar as últimas 35 linhas do arquivo de log
mostrar_ultimas_linhas_log() {
    if [ -f "$LOG_FILE" ]; then
        echo "Últimas 35 linhas do arquivo de log ($LOG_FILE):"
        # Usando tail para exibir as últimas 35 linhas
        tail -n 35 "$LOG_FILE"
    else
        echo "Arquivo de log $LOG_FILE não encontrado."
    fi
}

# Função para verificar o tamanho do arquivo de log
verificar_tamanho_log() {
    local size=$(stat -c %s "$LOG_FILE")
    
    # Definindo um tamanho limite de 10 MB (em bytes)
    local size_limit=10485760
    
    if [ "$size" -gt "$size_limit" ]; then
        echo "Aviso: O arquivo de log é grande (${size} bytes). O monitoramento das últimas 35 linhas pode não ser eficiente."
    fi
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

# Iniciar o servidor
echo "Iniciando o servidor..."
./$SERVER_PATH &  # Rodando o servidor em segundo plano

# Aguardar o servidor iniciar
sleep 5

# Monitorar o servidor e mostrar o log periodicamente
while true; do
    # Verificar se o processo do servidor ainda está rodando
    if ! pgrep -x "samp03svr" > /dev/null; then
        echo "O servidor fechou automaticamente. Encerrando o script."
        exit 0
    fi
    
    # Verificar o tamanho do arquivo de log
    verificar_tamanho_log

    # Exibir as últimas 35 linhas do log
    mostrar_ultimas_linhas_log
    
    # Aguardar 5 segundos antes de verificar novamente
    sleep 5
done
