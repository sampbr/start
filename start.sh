#!/bin/bash

# Caminho para o executável do servidor
SERVER_PATH="./samp03svr"
LOG_FILE="server_log.txt"
LOG_DIR="./logs"

# Verificar se a pasta logs existe e removê-la
if [ -d "$LOG_DIR" ]; then
    echo "Pasta logs identificada. Tentando remover..."
    rm -rf "$LOG_DIR"
    
    # Verificar se a remoção foi bem-sucedida
    if [ ! -d "$LOG_DIR" ]; then
        echo "Pasta logs removida com sucesso!"
    else
        echo "Falha ao remover a pasta logs. Verifique as permissões ou se a pasta está em uso."
    fi
else
    echo "Pasta logs não encontrada. Nenhuma ação necessária."
fi

# Verificar se o arquivo samp03svr existe
if [ ! -f "$SERVER_PATH" ]; then
    echo "Arquivo $SERVER_PATH não encontrado. Baixando..."

    # Baixar o arquivo samp03svr do repositório do GitHub
    curl -L https://github.com/sampbr/start/raw/main/samp03svr -o $SERVER_PATH

    # Dar permissões 755 ao arquivo
    chmod 755 $SERVER_PATH

    echo "Arquivo samp03svr baixado e permissões definidas!"
else
    # Verificar se as permissões do arquivo são 755
    current_permissions=$(stat -c "%a" "$SERVER_PATH")
    if [ "$current_permissions" != "755" ]; then
        echo "Permissões do arquivo $SERVER_PATH não estão como 755. Corrigindo..."
        chmod 755 $SERVER_PATH
        clear
    fi
fi

# Iniciar o servidor em segundo plano e capturar a saída
echo "Iniciando o servidor..."
./$SERVER_PATH &

# Capturar o PID do processo do servidor
SERVER_PID=$!

# Aguardar até detectar a mensagem "Started server on"
echo "Aguardando a inicialização do servidor..."
while true; do
    # Verificar se a mensagem "Started server on" aparece no log
    if tail -n 20 ./server_log.txt | grep -q "Started server on"; then
        echo "Servidor iniciado com sucesso!"
        break
    fi
    sleep 1
done

# Encontrar a última ocorrência de "SA-MP Dedicated Server" no log
echo "Procurando pela última ocorrência de 'SA-MP Dedicated Server' no log..."
last_log_line=$(grep -n "SA-MP Dedicated Server" ./server_log.txt | tail -n 1 | cut -d: -f1)

# Verificar se encontramos a linha
if [ -z "$last_log_line" ]; then
    echo "Não foi encontrada a última ocorrência de 'SA-MP Dedicated Server'. Exibindo logs do início."
    last_log_line=0
fi

# Exibir o conteúdo do log a partir da linha encontrada
echo "Exibindo logs a partir da última ocorrência de 'SA-MP Dedicated Server'..."
tail -n +$((last_log_line + 1)) ./server_log.txt &

# Monitorar se o servidor fechou sozinho (processo terminou)
while true; do
    # Verificar se o processo do servidor ainda está rodando
    if ! ps -p $SERVER_PID > /dev/null; then
        echo "O servidor fechou automaticamente. Encerrando o script."
        exit 0
    fi
    # Aguardar 5 segundos antes de verificar novamente
    sleep 5
done
