# backend/Dockerfile
FROM ruby:3.2.2

# Instala dependências do sistema
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs

# Define o diretório de trabalho
WORKDIR /app

# Copia o Gemfile e instala as gems (antes de copiar o código para usar o cache do Docker)
COPY Gemfile Gemfile.lock ./
RUN bundle install

# Copia o restante do código
COPY . .

# Script para resolver o problema do server.pid do Rails
COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]

EXPOSE 3000

CMD ["rails", "server", "-b", "0.0.0.0"]