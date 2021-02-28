FROM node:10.15-slim

ENV NODE_ENV=development

WORKDIR /app

COPY package.json package-lock*.json ./

RUN npm install && npm cache clean --force

COPY . .

CMD ["./node_modules/nodemon/bin/nodemon.js",  "./bin/www"]