FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build || true

FROM node:20-alpine AS runner
WORKDIR /app
ENV NODE_ENV=production
USER node

COPY --chown=node:node package*.json ./
RUN npm install --only=production

COPY --from=builder --chown=node:node /app/.next ./.next
COPY --from=builder --chown=node:node /app/src ./src

EXPOSE 3000
CMD ["npm", "start"]
