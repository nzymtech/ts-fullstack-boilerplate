FROM node:20-slim AS base
ENV PATH="$PNPM_HOME:$PATH"
RUN corepack enable && corepack prepare pnpm@latest-8 --activate

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
WORKDIR /usr/src/app
ENV NEXT_TELEMETERY_DISABLED 1
RUN --mount=type=cache,id=pnpm,target=/pnpm/store pnpm -w add sharp
RUN --mount=type=cache,id=pnpm,target=/pnpm/store pnpm --filter=web install --no-optional
RUN --mount=type=cache,id=pnpm,target=/pnpm/store pnpm --filter=web run build 
RUN --mount=type=cache,id=pnpm,target=/pnpm/store pnpm --filter=web install --prod --frozen-lockfile 

FROM base AS web

RUN addgroup --system --gid 1001 nonroot && adduser --system --uid 1001 nonroot
# RUN apk update && apk add --no-cache init

WORKDIR /app
COPY --from=webBuild --chown=nonroot:nonroot /usr/src/app/web/.next/standalone ./ 
COPY --from=webBuild --chown=nonroot:nonroot /usr/src/app/web/.next/static ./.next/static 
COPY --from=webBuild --chown=nonroot:nonroot /usr/src/app/web/public ./public
COPY --from=webBuild --chown=nonroot:nonroot /usr/src/app/web/.next.config.mjs .

USER nonroot:nonroot 
EXPOSE 3000
ENTRYPOINT ["/sbin/tini", "--"]
CMD ["node","server.js"]
