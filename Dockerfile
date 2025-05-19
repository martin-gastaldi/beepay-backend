# Usa la imagen oficial de Ruby 3.2.2 como base.
FROM ruby:3.2.2

# Define variables de entorno para Bundler:
# - BUNDLE_PATH: Directorio donde se instalarán las gemas.
ENV BUNDLE_PATH=/usr/local/bundle \
    BUNDLE_APP_CONFIG=/usr/local/bundle/config \
    RAILS_ENV=development
# - BUNDLE_APP_CONFIG: Directorio de configuración de Bundler.
# - RAILS_ENV: Establece el entorno de Rails.

# Establece /app como el directorio de trabajo dentro del contenedor.
WORKDIR /app

# Copia Gemfile y Gemfile.lock para instalar dependencias primero (aprovecha caché de Docker).
COPY Gemfile Gemfile.lock ./
RUN apt-get update && apt-get install -y sqlite3 libsqlite3-dev
# Ejecuta bundle install para instalar las gemas especificadas en el Gemfile.
RUN bundle install
# Copia todo el contenido del proyecto al directorio
COPY . .

# Expone el puerto 8000 para que la aplicación sea accesible desde fuera del contenedor.
EXPOSE 8000

# Define el comando predeterminado para iniciar el contenedor:
# - bundle exec: Ejecuta comandos en el contexto de las gemas instaladas.
# - rackup: Inicia el servidor Rack.
# - -o 0.0.0.0: Escucha en todas las interfaces de red.
# - -p 8000: Usa el puerto 8000.
# Busca automáticamente config.ru para iniciar la aplicación.
CMD ["bundle", "exec", "rackup", "-o", "0.0.0.0", "-p", "8000"]