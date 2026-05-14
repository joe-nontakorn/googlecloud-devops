# ===== Stage 1: Build Vue.js Application =====
FROM node:22-alpine AS build

WORKDIR /app

# Copy package files first for better layer caching
COPY package.json bun.lock ./

# Install dependencies using npm (compatible with CI environments)
RUN npm install

# Copy source code
COPY . .

# Build for production
RUN npm run build

# ===== Stage 2: Serve with Nginx =====
FROM nginx:alpine

# Copy custom nginx config
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copy built files from build stage
COPY --from=build /app/dist /usr/share/nginx/html

# Expose port 80
EXPOSE 80

# Start Nginx
CMD ["nginx", "-g", "daemon off;"]
