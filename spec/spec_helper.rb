require 'yaml'
require 'active_record'
require_relative '../models/transaction'
require_relative '../models/account'
require_relative '../models/user'

# Se establece Test como entorno por defecto.
ENV['RACK_ENV'] ||= 'test'

# Se carga la configuración y se establece la conexión a la base de datos.
db_config = YAML.load_file(File.expand_path('../../config/database.yml', __FILE__), aliases: true)
ActiveRecord::Base.establish_connection(db_config[ENV['RACK_ENV']])