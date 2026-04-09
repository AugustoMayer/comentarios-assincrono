# frontend/Dockerfile
FROM node:20-alpine

WORKDIR /app

# Instala as dependências primeiro
COPY package*.json ./
RUN npm install

COPY . .

EXPOSE 5173

# Rodando o servidor de desenvolvimento do Vite com acesso externo
CMD ["npm", "run", "dev", "--", "--host"]