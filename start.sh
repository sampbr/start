#!/bin/bash

# Caminho para o executável do servidor
SERVER_PATH="./samp03svr"
LOG_DIR="./logs"
PLUGINS_DIR="./plugins"
CFG_FILE="./server.cfg"

# Verificar se a pasta logs existe e removê-la
if [ -d "$LOG_DIR" ]; then
    echo "Pasta logs identificada. Tentando remover..."
    rm -rf "$LOG_DIR"
    
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
    curl -L https://github.com/sampbr/start/raw/main/samp03svr -o $SERVER_PATH
    chmod 755 $SERVER_PATH
    echo "Arquivo samp03svr baixado e permissões definidas!"
else
    current_permissions=$(stat -c "%a" "$SERVER_PATH")
    if [ "$current_permissions" != "755" ]; then
        echo "Permissões do arquivo $SERVER_PATH não estão como 755. Corrigindo..."
        chmod 755 $SERVER_PATH
        clear
    fi
fi

# Verificar quais plugins .so existem na pasta plugins
PLUGIN_LIST=$(ls $PLUGINS_DIR/*.so 2>/dev/null)

if [ ! -z "$PLUGIN_LIST" ]; then
    PLUGINS_LINE="plugins"
    for plugin in $PLUGIN_LIST; do
        PLUGINS_LINE="$PLUGINS_LINE $(basename $plugin)"
    done
    
    if [ -f "$CFG_FILE" ]; then
        echo "Atualizando a linha de plugins em $CFG_FILE..."
        sed -i "s|^plugins.*|$PLUGINS_LINE|" $CFG_FILE
        echo "Linha de plugins atualizada com sucesso!"
    else
        echo "Arquivo $CFG_FILE não encontrado. Não foi possível atualizar a linha de plugins."
    fi
else
    echo "Nenhum plugin .so encontrado na pasta $PLUGINS_DIR."
fi

# Iniciar o servidor
echo "Iniciando o servidor..."
./$SERVER_PATH &  # Executa o servidor em segundo plano
SERVER_PID=$!

# Monitoramento do uso da CPU
while true; do
    if ! ps -p $SERVER_PID > /dev/null; then
        echo "O servidor fechou automaticamente. Encerrando o script."
        exit 0
    fi

    # Capturar o uso da CPU do processo
    CPU_USAGE=$(ps -o %cpu= -p $SERVER_PID | awk '{print int($1)}')

    # Verificar se o uso da CPU ultrapassa 150%
    if [ "$CPU_USAGE" -ge 150 ]; then
        echo "Alerta! Uso da CPU atingiu ${CPU_USAGE}%. Encerrando o servidor..."
        kill -9 $SERVER_PID
        exit 1
    fi

    sleep 5
done
