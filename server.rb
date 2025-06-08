require 'bundler/setup'
require 'sinatra/base'
require 'sinatra'
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

    enable :sessions # Habilita el uso de sesiones en la aplicación.

    # Configuración de archivo de base de datos.
    set :database_file, '/app/config/database.yml'
    set :views, File.expand_path('../views', __FILE__) # Establece la ruta de las vistas para la aplicación.
    set :public_folder, File.dirname(__FILE__) + '/public' # Establece la carpeta pública para archivos estáticos.	

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




    # Rutas para manejar el registro y autenticación de usuarios.
    # Estas rutas permiten a los usuarios registrarse, iniciar sesión y acceder a su panel de control.
    # Ruta para mostrar el formulario de registro.
    get '/signup' do
        erb :signup
    end
    # Ruta para manejar el envío del formulario de registro.
    post '/signup' do
    user = User.new(
        user_name: params[:user_name], 
        email: params[:email],
        password: params[:password], 
    )
    # Aquí se crea un nuevo usuario con los parámetros del formulario.
    if user.save
        session[:user_id] = user.id
        redirect '/welcome' # Redirige al usuario al panel de control después de un registro exitoso.
    else
        @error = user.errors.full_messages.join(", ") # Si hay errores al guardar el usuario, se muestran en la vista.
        # Se utiliza 'full_messages' para obtener un mensaje de error legible.
        # 'join' une los mensajes de error en una sola cadena separada por comas.
        erb :signup # Renderiza la vista de registro nuevamente con los errores.
    end
    end
    # Ruta para mostrar el formulario de inicio de sesión.
    get '/login' do
     erb :login
    end
    # Ruta para manejar el envío del formulario de inicio de sesión.
    post '/login' do
        
    user = User.find_by(email: params[:email])  # Busca al usuario por su correo electrónico.

    if user && user.authenticate(params[:password]) # Verifica si el usuario existe y si la contraseña es correcta.
        session[:user_id] = user.id # Si la autenticación es exitosa, guarda el ID del usuario en la sesión.
        redirect '/welcome' # Redirige al usuario a la página de bienvenida (o panel de control).
    else
        @error = "Invalid email or password"
        erb :login # Si la autenticación falla, muestra un mensaje de error y vuelve a renderizar el formulario de inicio de sesión.
    end
    end
    # Ruta para cerrar sesión.
    get '/welcome' do     
    @user = User.find_by(id: session[:user_id])
    if @user
        erb :welcome
    else
        redirect '/login'
    end
    end

end