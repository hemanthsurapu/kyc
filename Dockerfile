FROM node:20-alpine3.17 AS development

RUN npm config set registry https://registry.npmjs.org/ \
    && npm config set fetch-retry-mintimeout 20000 \
    && npm config set fetch-retry-maxtimeout 120000 \
    && npm config set fetch-retries 5 \
    && npm config set fetch-timeout 300000

WORKDIR /usr/app

COPY package*.json ./
# COPY .env .

# All installations
RUN npm install || npm install || npm install
COPY . .
#RUN npx prisma generate

RUN npm run build

FROM node:20-alpine3.17 AS production
RUN npm config set registry https://registry.npmjs.org/

WORKDIR /usr/app

COPY package*.json ./
# COPY .env .

# All installations
RUN npm install || npm install || npm install
COPY . .
COPY --from=development /usr/app/prisma ./prisma

RUN npm install

RUN npx prisma generate

COPY --from=development /usr/app/dist ./dist

CMD [ "node", "dist/main" ]
