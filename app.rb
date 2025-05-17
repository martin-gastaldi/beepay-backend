require 'sinatra'
require 'sinatra/activerecord'
require './models/user'
require 'json'
require './routes/users'
require 'sinatra/namespace'


set :database_file, 'config/database.yml'

get '/' do
  '¡BeePay API corriendo!'
end
