FROM node:22-slim

# 2. Create app directory
WORKDIR /usr/src/app

# 3. Set dev-specific env vars
ENV NODE_ENV=development
# enable polling so Next.js file watching works when code is mounted from macOS
ENV CHOKIDAR_USEPOLLING=true

# 4. Install dependencies
COPY package.json package-lock.json ./

RUN npm ci

# # 5. Copy the rest of your source code
COPY . .

# # 6. Expose Next.js dev server port
EXPOSE 3001

# # 7. Start in dev mode
CMD ["npm", "run", "dev"]
