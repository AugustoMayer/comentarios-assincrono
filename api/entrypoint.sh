#!/bin/bash
set -e
# Remove um possível server.pid antigo que impede o Rails de subir
rm -f /app/tmp/pids/server.pid
exec "$@"