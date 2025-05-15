FROM node:20-alpine3.17 AS development


RUN npm config set registry https://registry.npmjs.org/ \
    && npm config set fetch-retry-mintimeout 20000 \
    && npm config set fetch-retry-maxtimeout 120000 \
    && npm config set fetch-retries 5 \
    && npm config set fetch-timeout 300000

WORKDIR /usr/app


COPY package.json ./
COPY package-lock.json ./

RUN npm install || npm install || npm install

COPY . .

RUN npm run build


FROM node:20-alpine3.17 AS production

RUN npm config set registry https://registry.npmjs.org/

WORKDIR /usr/app

COPY package.json ./
COPY package-lock.json ./

RUN npm install --omit=dev || npm install --omit=dev || npm install --omit=dev

COPY . .

COPY --from=development /usr/app/prisma ./prisma
COPY --from=development /usr/app/dist ./dist

CMD ["node", "dist/main"]
