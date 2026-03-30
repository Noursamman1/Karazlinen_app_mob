FROM node:22-alpine

WORKDIR /app

COPY bff/package*.json ./
RUN npm ci

COPY bff ./
RUN npm run build

CMD ["npm", "run", "start"]
