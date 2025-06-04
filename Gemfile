# Versión de Ruby.
ruby '~> 3.2'

# Origen de Bundler para leer y procesar el Gemfile.
source "https://rubygems.org"

# Dependencias del proyecto (gemas requeridas).

# Gema: Sinatra (framework ligero para construir aplicaciones web en Ruby).
# Versión 4.1.x (cualquier versión 4.1 con parches, pero no 4.2 o superior).
gem 'sinatra', '~> 4.1'

# Gema: Rackup (herramienta de línea de comandos incluida en la gema rack para iniciar servidores web compatibles con Rack).
# Última versión estable disponible.
gem 'rackup'

# Gema: Puma (servidor web concurrente y de alto rendimiento para aplicaciones Ruby/Rack).
# Versión 6.6.x (cualquier versión 6.6 con parches, pero no 6.7 o superior).
gem 'puma', '~> 6.6'

# Gema: Sinatra-Contrib (proporciona extensiones útiles para Sinatra, como recarga automática (reloader), helpers y herramientas de desarrollo).
gem 'sinatra-contrib'

# Gema: Sinatra-ActiveRecord (permite usar modelos y manejar bases de datos relacionales).
gem 'sinatra-activerecord'

# Gema: Sqlite3 (interfaz para usar SQLite, una base de datos ligera y sin servidor).
gem 'sqlite3'

# Gema: Rake (automatizar tareas en Ruby. Se usa para ejecutar tareas de base de datos, como migraciones con ActiveRecord).
gem 'rake'

# Gema: Bcrypt (manejo seguro de contraseñas).
gem 'bcrypt', '~> 3.1.7'

# Gemas : Rspec y Rack-Test (automatización de tests).
group :test, :development do
  gem 'rspec'
  gem 'rack-test'
end