# ETAPA 1: Construcción (Usamos Ruby para compilar Jekyll)
FROM ruby:3.2-alpine AS builder

# Instalamos las dependencias del sistema necesarias para compilar algunas gemas nativas
RUN apk add --no-cache build-base gcc cmake git

# Creamos el directorio de trabajo
WORKDIR /srv/jekyll

# Copiamos los archivos de dependencias
COPY Gemfile Gemfile.lock ./

# Instalamos las gemas de Ruby
RUN bundle install

# Copiamos el resto de los archivos de tu página
COPY . .

# 1. Creamos un archivo de configuración temporal exclusivo para Azure
RUN echo 'url: "https://hmis-dcf313-cadqgqc7g8gnbpbn.norwayeast-01.azurewebsites.net"' > _config.azure.yml
RUN echo 'baseurl: ""' >> _config.azure.yml

# 2. Compilamos fusionando tu configuración original con la nueva
RUN JEKYLL_ENV=production bundle exec jekyll build --config _config.yml,_config.azure.yml

# ETAPA 2: Producción (Usamos Nginx para servir el HTML puro)
FROM nginx:alpine

# Copiamos el HTML generado en la Etapa 1 a la carpeta pública de Nginx
COPY --from=builder /srv/jekyll/_site /usr/share/nginx/html

# Exponemos el puerto estándar de Nginx
EXPOSE 80

# Comando para iniciar el servidor
CMD ["nginx", "-g", "daemon off;"]