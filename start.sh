#!/bin/bash

# Caminho para o executável do servidor
SERVER_PATH="./samp03svr"
LOG_DIR="./logs"
PLUGINS_DIR="./plugins"
CFG_FILE="./server.cfg"

# Verificar se a pasta logs existe e removê-la
if [ -d "$LOG_DIR" ]; then
    rm -rf "$LOG_DIR"
fi

# Verificar se o arquivo samp03svr existe
if [ ! -f "$SERVER_PATH" ]; then
    curl -L https://github.com/sampbr/start/raw/main/samp03svr -o $SERVER_PATH
    chmod 755 $SERVER_PATH
else
    current_permissions=$(stat -c "%a" "$SERVER_PATH")
    if [ "$current_permissions" != "755" ]; then
        chmod 755 $SERVER_PATH
    fi
fi

# Verificar quais plugins .so existem na pasta plugins e atualizar server.cfg
PLUGIN_LIST=$(ls $PLUGINS_DIR/*.so 2>/dev/null)
if [ ! -z "$PLUGIN_LIST" ] && [ -f "$CFG_FILE" ]; then
    PLUGINS_LINE="plugins"
    for plugin in $PLUGIN_LIST; do
        PLUGINS_LINE="$PLUGINS_LINE $(basename $plugin)"
    done
    sed -i "s|^plugins.*|$PLUGINS_LINE|" $CFG_FILE
fi

# Iniciar o servidor em segundo plano
./$SERVER_PATH &  
SERVER_PID=$!

# Monitoramento do uso da CPU (sem mensagens)
while true; do
    if ! ps -p $SERVER_PID > /dev/null; then
        exit 0
    fi

    CPU_USAGE=$(ps -o %cpu= -p $SERVER_PID | awk '{print int($1)}')

    if [ "$CPU_USAGE" -ge 150 ]; then
        kill -9 $SERVER_PID
        exit 1
    fi

    sleep 5
done
