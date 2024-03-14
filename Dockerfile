FROM node:20-bookworm-slim as base
WORKDIR /app
COPY package*.json ./
EXPOSE 3000

FROM base as builder
WORKDIR /app
COPY . .
RUN yarn build


FROM base as production
WORKDIR /app

ENV NODE_ENV=production
RUN yarn install --frozen-lockfile

RUN addgroup -g 1001 -S nodejs
RUN adduser -S nextjs -u 1001
USER nextjs


COPY --from=builder --chown=nextjs:nodejs /app/.next ./.next
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package.json ./package.json
COPY --from=builder /app/public ./public

CMD yarn start

FROM base as dev
ENV NODE_ENV=development
RUN yarn install 
COPY . .
CMD yarn dev

FROM cypress/included as test
WORKDIR /app

ENV NODE_ENV=test
RUN yarn install
COPY . .
RUN yarn build
RUN yarn test
RUN yarn e2e:headless
RUN yarn component:headless
CMD yarn start
