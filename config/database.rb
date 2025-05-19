require 'active_record'
require 'yaml'
require 'erb'

# Cargar archivo YAML
db_config_path = File.expand_path('../database.yml', __FILE__)
db_config = YAML.load(ERB.new(File.read(db_config_path)).result)

# Detectar entorno actual
env = ENV['RACK_ENV'] || 'development'

# Establecer conexión
ActiveRecord::Base.establish_connection(db_config[env])
