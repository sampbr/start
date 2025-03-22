#!/bin/sh

# Caminhos
SERVER_PATH="./samp03svr"
LOG_DIR="./logs"
LOG_FILE="./server_log.txt"

# Remover pasta de logs se existir
if [ -d "$LOG_DIR" ]; then
    echo "Pasta logs identificada. Removendo..."
    rm -rf "$LOG_DIR"
fi

# Verificar se o executável do SAMP existe
if [ ! -f "$SERVER_PATH" ]; then
    echo "Servidor não encontrado. Baixando..."
    curl -L https://github.com/sampbr/start/raw/main/samp03svr -o $SERVER_PATH
fi

# Verificar e corrigir permissões do servidor
CURRENT_PERM=$(ls -l "$SERVER_PATH" | awk '{print $1}')
if [ "$CURRENT_PERM" != "-rwxrwxrwx" ]; then
    echo "Corrigindo permissões do $SERVER_PATH para 777..."
    chmod 777 "$SERVER_PATH"
fi

# Limpar o conteúdo anterior do arquivo de log
echo "" > $LOG_FILE

# Iniciar o servidor em segundo plano e redirecionar os logs para o arquivo
echo "Iniciando o servidor..."
./$SERVER_PATH > $LOG_FILE 2>&1 &

# Capturar o PID do servidor
SERVER_PID=$!

# Monitorar o arquivo de logs e exibir no console
echo "Monitorando logs..."
tail -f $LOG_FILE | while read line; do
    echo "$line"  # Exibe a linha no console
    
    # Verificar se a linha contém a frase "Started"
    if echo "$line" | grep -q "Started"; then
        echo "Servidor iniciado. O script agora continuará monitorando as logs."
        break  # Sai do loop de monitoramento de logs
    fi
done

# Agora que o servidor foi iniciado, monitoramos as logs e o servidor continuará sendo monitorado
echo "O servidor está rodando. As logs continuam sendo exibidas."

# Enquanto o servidor estiver rodando, o script não vai fechar
while true; do
    # Verificar se o servidor ainda está em execução
    if ! ps -p $SERVER_PID > /dev/null; then
        echo "O servidor foi fechado inesperadamente. Continuando o monitoramento."
        sleep 10  # Aguarda 10 segundos antes de verificar novamente
        ./$SERVER_PATH > $LOG_FILE 2>&1 &  # Reinicia o servidor
        SERVER_PID=$!  # Atualiza o PID com o novo processo
    fi
    sleep 5  # Atraso para verificar a cada 5 segundos
done
