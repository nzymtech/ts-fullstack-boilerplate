# Prepare workspace 


FROM node:18-alpine as workspace
WORKDIR /app

RUN corepack enable && corepack prepare pnpm@7.29.3 --activate

COPY pnpm-lock.yaml .
COPY package.json .

RUN pnpm install
COPY . . 

## Create minimal deployment for the api package

FROM workspace AS pruned
WORKDIR /app
RUN pnpm -F=server run build


## Production image 
FROM node:18-alpine 
WORKDIR /app

ENV NODE_ENV=production

COPY --from=pruned /app/dist dist

ENTRYPOINT ["node", "dist/main"]
