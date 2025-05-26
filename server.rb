require 'bundler/setup'
require 'sinatra/base'
require 'sinatra/reloader' if Sinatra::Base.environment == :development
require 'sinatra/activerecord'
require_relative 'models/user'
require_relative 'models/account'
require_relative 'models/transaction'
require_relative 'services/transaction_history_service'
require 'logger'

# Clase 'App' que hereda de 'Sinatra::Application',
# convirtiéndola en una aplicación web Sinatra.
class App < Sinatra::Application

    # Configuración de archivo de base de datos.
    set :database_file, '/app/config/database.yml'

    configure :development do
        enable :logging
        logger = Logger.new(STDOUT)
        logger.level = Logger::DEBUG if development?
        set :logger, logger

        register Sinatra::Reloader
        after_reload do
            logger.info 'Reloaded!!!'
        end
    end

    # Ruta para solicitudes GET a la URL raíz ('/').
    get '/' do
        'Welcome'
    end

   get '/transactions/history' do
   account = Account.find(params[:account_id])
   history = TransactionHistoryService.new(account).call

   {
    sent: history[:sent].map { |t| format_transaction(t) },
    received: history[:received].map { |t| format_transaction(t) }
     }.to_json
     end

    def format_transaction(t)
    {
        id: t.id,
        from: t.source_account.alias,
        to: t.target_account.alias,
        amount: t.amount,
        date: t.created_at.strftime("%d/%m/%Y %H:%M")
      }
    end
  
end