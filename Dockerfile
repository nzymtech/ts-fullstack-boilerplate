# Prepare workspace 
FROM node:18-alpine as workspace
RUN corepack enable && corepack prepare pnpm@9.1.2 --activate

COPY pnpm-lock.yaml .
COPY package.json .

RUN pnpm install --prod

WORKDIR /app
COPY . . 

## Create minimal deployment for the api package

FROM workspace AS serverBuild
WORKDIR /app
RUN pnpm -F=server run build

## Production image 
FROM node:18-alpine 
WORKDIR /app

ENV NODE_ENV=production

COPY --from=serverBuild /app/server/dist dist

ENTRYPOINT ["node", "dist/main"]
