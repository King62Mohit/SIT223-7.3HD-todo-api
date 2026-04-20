# use slim node image — smaller = less attack surface for security scan
FROM node:18-alpine

WORKDIR /app

# copy package files first so Docker caches the npm install layer
COPY package*.json ./
RUN npm ci --only=production

# copy source
COPY src/ ./src/
COPY tests/ ./tests/

EXPOSE 3000

CMD ["node", "src/app.js"]