# Stage 1: Build Flutter Web
FROM ghcr.io/cirruslabs/flutter:3.29.0 AS build
WORKDIR /ds_milk_world
COPY ds_milk_world_client /ds_milk_world/ds_milk_world_client
COPY ds_milk_world_flutter /ds_milk_world/ds_milk_world_flutter
WORKDIR /ds_milk_world/ds_milk_world_flutter
RUN flutter pub get
RUN flutter build web --release

# Stage 2: Production Nginx Server
FROM nginx:alpine
COPY --from=build /ds_milk_world/ds_milk_world_flutter/build/web /usr/share/nginx/html
COPY ds_milk_world_flutter/nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]