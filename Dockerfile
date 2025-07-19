#Imagem base
FROM node:20.18 AS base

#Instala o pnpm globalmente
RUN npm i -g pnpm

#Imagem de dependências
FROM base AS dependencies

#Diretório de trabalho
WORKDIR /usr/src/app

#Copia o package.json e o pnpm-lock.yaml
COPY package.json pnpm-lock.yaml ./

#Instala as dependências
RUN pnpm install

#Imagem de build (Usando estrategia de multi-stage)
FROM base AS build

#Diretório de trabalho
WORKDIR /usr/src/app

#Copia as dependências do stage de dependências
COPY --from=dependencies /usr/src/app/node_modules ./node_modules

#Copia o resto do código
COPY . .

#Executa o build e remove as dependências de desenvolvimento
RUN pnpm build
RUN pnpm prune --prod


#Imagem de runner (Usando estrategia de multi-stage)
FROM gcr.io/distroless/nodejs20-debian12 AS runner

#Diretório de trabalho
WORKDIR /usr/src/app

#Usa o usuário 1000 (no-root)
USER 1000

#Copia as dependências do stage de build
COPY --from=build /usr/src/app/node_modules ./node_modules
COPY --from=build /usr/src/app/dist ./dist
COPY --from=build /usr/src/app/package.json ./package.json

#Variáveis de ambiente
ENV CLOUDFLARE_ACCESS_KEY_ID="#"
ENV CLOUDFLARE_SECRET_ACCESS_KEY="#"
ENV CLOUDFLARE_BUCKET="#"
ENV CLOUDFLARE_ACCOUNT_ID="#"
ENV CLOUDFLARE_PUBLIC_URL="http://localhost"

#Expoe a porta 3333
EXPOSE 3333

#Usa o node para executar o servidor, em vez de pnpm, pois o pnpm não existe no contexto do runner
CMD ["dist/server.mjs"]