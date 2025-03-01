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

# Verificar quais plugins .so existem na pasta plugins
PLUGIN_LIST=$(ls $PLUGINS_DIR/*.so 2>/dev/null)

# Verificar se encontrou plugins .so
if [ ! -z "$PLUGIN_LIST" ]; then
    # Construir a linha de plugins, começando com os plugins padrão
    PLUGINS_LINE="plugins "
    
    # Adicionar os plugins encontrados na pasta
    for plugin in $PLUGIN_LIST; do
        PLUGINS_LINE="$PLUGINS_LINE $(basename $plugin)"
    done
    
    # Verificar se o arquivo server.cfg existe antes de tentar modificá-lo
    if [ -f "$CFG_FILE" ]; then
        echo "Atualizando a linha de plugins em $CFG_FILE..."
        
        # Procurar e substituir a linha que começa com "plugins" no arquivo de configuração
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
./$SERVER_PATH

# Monitorar se o servidor fechou sozinho (processo terminou)
while true; do
    # Verificar se o processo do servidor ainda está rodando
    if ! pgrep -x "samp03svr" > /dev/null; then
        echo "O servidor fechou automaticamente. Encerrando o script."
        exit 0
    fi
    # Aguardar 5 segundos antes de verificar novamente
    sleep 5
done
