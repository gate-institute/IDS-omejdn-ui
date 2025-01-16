# ----- BUILD STAGE -----
FROM node:18-slim AS builder
# Temporarily necessary, see https://github.com/webpack/webpack/issues/14532
ARG NODE_OPTIONS=--openssl-legacy-provider
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci
RUN npm install -g @angular/cli

COPY *.json browserslist ./
COPY ./src src
RUN ng build --configuration production

FROM nginx:1.27

WORKDIR /opt
COPY nginx.conf /etc/nginx/nginx.conf
COPY ./docker-entrypoint.sh .
COPY --from=builder /app/dist/ui/* ./
COPY ./src/assets ./assets

ENV CLIENT_ID=adminUI

EXPOSE 80
ENTRYPOINT ["/bin/bash", "./docker-entrypoint.sh"]
CMD ["/docker-entrypoint.sh","nginx","-g","daemon off;"]
