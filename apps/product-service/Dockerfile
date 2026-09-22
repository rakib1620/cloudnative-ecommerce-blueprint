FROM node:20-alpine

# Non-root user setup
USER node
WORKDIR /home/node/app

COPY --chown=node:node package*.json ./
RUN npm install --only=production

COPY --chown=node:node src/ ./src/

EXPOSE 8082

CMD ["node", "src/index.js"]
