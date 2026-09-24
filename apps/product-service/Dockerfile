FROM node:20-alpine

# ফোল্ডার তৈরি করে তার মালিকানা 'node' ইউজারকে দেওয়া হলো
WORKDIR /app
RUN chown -R node:node /app

# এবার নিরাপদে সাধারণ ইউজার হয়ে যাওয়া হলো
USER node

COPY --chown=node:node package*.json ./
RUN npm install --omit=dev

COPY --chown=node:node src/ ./src/

EXPOSE 8082

CMD ["node", "src/index.js"]
