FROM node:20-slim AS base
ENV PATH="$PNPM_HOME:$PATH"
RUN corepack enable

FROM base AS build
COPY . /usr/src/app
WORKDIR /usr/src/app
RUN --mount=type=cache,id=pnpm,target=/pnpm/store pnpm install --frozen-lockfile

FROM build as serverBuild
WORKDIR /usr/src/app
RUN pnpm run -F=server build

FROM base AS server
WORKDIR /usr/src/app 

COPY --from=serverBuild /usr/src/app/server/package.json package.json
COPY --from=serverBuild /usr/src/app/server/dist dist
COPY --from=serverBuild /usr/src/app/server/node_modules node_modules
CMD [ "node", "dist/main.js" ]
