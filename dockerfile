
FROM node:24.9.0-alpine3.21 AS production

WORKDIR /app

COPY package.json ./

RUN npm install

COPY . .

RUN npm run build

LABEL "gameoflife-frontend"=""

CMD [ "sh", "-c", "node .output/server/index.mjs"]