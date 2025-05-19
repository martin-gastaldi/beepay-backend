require 'bundler/setup'
require 'sinatra/base'
require 'sinatra/reloader' if Sinatra::Base.environment == :development
require 'logger'
require 'puma'
require 'sinatra/activerecord'
require_relative 'models/user'
# para conectar ActiveRecord con database.yml
require 'active_record'
require 'yaml'
require 'erb'

db_config_path = File.expand_path('../config/database.yml', __FILE__)
db_config = YAML.load(ERB.new(File.read(db_config_path)).result)
env = ENV['RACK_ENV'] || 'development'

ActiveRecord::Base.establish_connection(db_config[env])

class App < Sinatra::Application
  configure :development do
    enable :logging
    set :logger, Logger.new(STDOUT)
    settings.logger.level = Logger::DEBUG

    register Sinatra::Reloader

    after_reload do
      settings.logger.info 'Reloaded!!!'
    end
  end

  get '/' do
    'Welcome, hice un cambio en el archivo server.rb , y funciono sin problemas'
  end
end
