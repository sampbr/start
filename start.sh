#!/bin/bash

# Caminho para o executável do servidor
SERVER_PATH="./samp03svr"
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

# Exibir a mensagem "Started server on" sem desaparecer
echo "Started server on port: 7777, with maxplayers: 500 lanmode is OFF."

# Monitorar o log server_log.txt em tempo real (tail -f)
tail -f ./server_log.txt &

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
