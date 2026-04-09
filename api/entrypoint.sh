#!/bin/bash
set -e

# Remove um possível server.pid antigo que impede o Rails de subir
rm -f /app/tmp/pids/server.pid

# Cria o banco se não existir, e roda as migrations pendentes.
bundle exec rails db:prepare

# Executa o comando principal do container (iniciar o servidor)
exec "$@"