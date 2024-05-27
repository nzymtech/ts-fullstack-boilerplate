FROM node:20-slim AS base
ENV PATH="$PNPM_HOME:$PATH"
RUN corepack enable

FROM base AS build
COPY . /usr/src/app
WORKDIR /usr/src/app
RUN --mount=type=cache,id=pnpm,target=/pnpm/store pnpm install --frozen-lockfile

FROM build as serverBuild
WORKDIR /usr/src/app/server
RUN npm i -g @vercel/ncc
RUN npx ncc build src/main.ts --out dist

FROM base AS server
WORKDIR /usr/src/app
EXPOSE 3033 
COPY --from=serverBuild /usr/src/app/server/dist dist
CMD [ "node", "dist/index.js" ]

FROM build AS webBuild
WORKDIR /usr/src/app/web
RUN pnpm run prebuild 
RUN pnpm run build 
RUN pnpm prune --production 

FROM base AS web
WORKDIR /app
COPY --from=webBuild /usr/src/app/web/package.json ./package.json
COPY --from=webBuild /usr/src/app/web/node_modules ./node_modules
COPY --from=webBuild /usr/src/app/web/.next ./.next 
COPY --from=webBuild /usr/src/app/web/public ./public
EXPOSE 3000
CMD ["pnpm","start"]
