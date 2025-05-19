require 'active_record'
require 'yaml'
require 'erb'
require 'active_record/tasks/database_tasks'

# Cargar configuración desde config/database.yml
db_config = YAML.load(ERB.new(File.read('config/database.yml')).result)

# Detectar entorno (default: development)
env = ENV['RACK_ENV'] || 'development'

# Establecer conexión
ActiveRecord::Base.configurations = db_config
ActiveRecord::Base.establish_connection(db_config[env])

# Configurar DatabaseTasks
ActiveRecord::Tasks::DatabaseTasks.database_configuration = db_config
ActiveRecord::Tasks::DatabaseTasks.env = env
ActiveRecord::Tasks::DatabaseTasks.db_dir = 'db'
ActiveRecord::Tasks::DatabaseTasks.root = File.dirname(__FILE__)
ActiveRecord::Tasks::DatabaseTasks.migrations_paths = ['db/migrate']

# Task necesario para algunas operaciones (como db:create)
task :environment do
  # Acá podrías cargar tu entorno si es necesario
end

# Cargar tareas estándar de ActiveRecord (como db:create, db:migrate, etc.)
load 'active_record/railties/databases.rake'
