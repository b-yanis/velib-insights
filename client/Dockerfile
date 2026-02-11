# Stage 1: Build
FROM node:20-alpine AS build-stage
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build

# Stage 2: Serve
FROM nginx:stable-alpine
COPY --from=build-stage /app/dist /usr/share/nginx/html
# On remplace la config par défaut de NGINX si besoin d'un proxy
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]