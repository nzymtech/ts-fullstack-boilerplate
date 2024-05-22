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
