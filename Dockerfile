# Imagen oficial de Ruby 3.2.2 como base.
FROM ruby:3.2.2

# Variables de entorno para Bundler:
# - BUNDLE_PATH: Directorio donde se instalan las gemas.
# - BUNDLE_APP_CONFIG: Ubicación del archivo de configuración de Bundler.
# - RAILS_ENV: Establece el entorno como desarrollo.
ENV BUNDLE_PATH=/usr/local/bundle \
    BUNDLE_APP_CONFIG=/usr/local/bundle/config \
    RAILS_ENV=development

# Directorio de trabajo dentro del contenedor.
WORKDIR /app

# Instalar dependencias.
COPY Gemfile Gemfile.lock ./

# Instalar las gemas especificadas en el Gemfile.
RUN bundle install

# Copiar todo el contenido del proyecto al directorio /app.
COPY . .
COPY public/ /app/public/

# Puerto para acceso externo.
EXPOSE 8000

# Comando predeterminado para iniciar el contenedor:
# - bundle exec: Ejecuta comandos en el contexto de las gemas instaladas.
# - rackup: Inicia el servidor Rack.
# - -o 0.0.0.0: Escucha en todas las interfaces de red.
# - -p 8000: Usa el puerto 8000.
# Busca automáticamente config.ru para iniciar la aplicación.
CMD ["bundle", "exec", "rackup", "-o", "0.0.0.0", "-p", "8000"]