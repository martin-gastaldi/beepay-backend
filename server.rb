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
        # Generar alias automático
            base_alias = user.user_name.downcase.gsub(/\s+/, "") # sin espacios y en minúscula
            unique_alias = "#{base_alias}#{user.id || rand(1000..9999)}"

            # Asegurar unicidad (opcional, si no tienes validación en modelo)
            while Account.exists?(alias: unique_alias)
                unique_alias = "#{base_alias}#{rand(1000..9999)}"
            end
            generated_cbu = SecureRandom.hex(11) # Genera un CBU/CVU aleatorio de 22 caracteres hexadecimales.
            Account.create(user: user, balance: 500, alias: unique_alias,cbu_cvu: generated_cbu)
            session[:user_id] = user.id
            redirect '/welcome'
        else
            @error = user.errors.full_messages.join(", ")
            erb :signup
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

    get '/welcome' do
        user = User.find_by(id: session[:user_id])
        if user.nil?
            redirect '/login'
        end

        account = user.account
        unless account
        return erb :welcome, locals: {
            user_name: user.user_name,
            balance: 0,
            transactions: [],
            received_transactions: [],
            error: "No tienes una cuenta asociada.",
            account_alias: nil
        }
        end

        sent_transactions = account.source_transactions.order(created_at: :desc).limit(5)
        received_transactions = account.target_transactions.order(created_at: :desc).limit(5)
            erb :welcome, locals: {
                user_name: user.user_name,
                balance: account.balance,
                sent_transactions: sent_transactions,
                received_transactions: received_transactions,
                error: nil,
                account_alias: account.alias,
                account: account
            }
    end

    post '/welcome' do
        user = User.find_by(id: session[:user_id])
        redirect '/login' if user.nil?

        # Si el motivo viene por params, guardalo en la sesión
        session[:reason] = params[:reason] if params[:reason]

        # Validar que todos los datos estén presentes
        if session[:target_account_alias].nil? || session[:amount].nil? || session[:reason].nil?
            redirect '/transferir'
        end

        account = user.account
        target_account = Account.find_by(alias: session[:target_account_alias])
        amount = session[:amount].to_i
        reason = session[:reason]

        # Validaciones
        if account.nil? || target_account.nil? || amount <= 0 || reason.nil? || reason.strip.empty?
            @error = "Datos inválidos para la transferencia."
            return erb :seleccionarMotivoTransferencia, locals: { error: @error, amount: amount }
        end

        transaction = Transaction.create(
            source_account: account,
            target_account: target_account,
            amount: amount,
            reason: reason
        )
        unless transaction.persisted?
            @error = transaction.errors.full_messages.join(', ')
            return erb :seleccionarMotivoTransferencia, locals: { error: @error, amount: amount }
        end

        # Limpiar sesión SOLO después de transferencia exitosa, esto es para evitar problemas si el usuario refresca la página
        session[:target_account_alias] = nil
        session[:amount] = nil # Limpiar el monto
        session[:reason] = nil # Limpiar el motivo
        
        redirect '/welcome'
    end

    get '/mi_tarjeta' do
        user = User.find_by(id: session[:user_id])
         return erb :mi_tarjeta, locals: {
            user_name: user.user_name
        }
    end

    get '/museo' do 
        erb :museo 
    end

    get '/personas' do
    personas = [
    {
      nombre: "GastaCuadros",
      usericon: "/images/logoGastaCuadros.png",
      instagram: "https://www.instagram.com/gastacuadros?igsh=c3FiODM2amtkbTJ5",
      facebook: "#",
      imagenes: ["/images/cuadro1.png", "/images/cuadro2.png", "/images/cuadro3.png", "/images/cuadro5.jpg"],
      descripcion: "Especialista en calado de madera a mano"
    },
    {
      nombre: "ArteVivo",
      usericon: "/images/logoart3.jpg",
      instagram: "https://www.instagram.com/artevivo",
      facebook: "#",
      imagenes: ["/images/cuadro6.jpg", "/images/cuadro7.jpg", "/images/cuadro8.jpg", "/images/cuadro9.jpg"],
      descripcion: "Colores que despiertan espacios y emociones"
    },
    {
      nombre: "CulturaUrbana",
      usericon: "/images/logoart5.jpg",
      instagram: "https://www.instagram.com/culturau",
      facebook: "#",
      imagenes: ["/images/cuadro10.jpg", "/images/cuadro11.jpg", "/images/cuadro12.jpg", "/images/cuadro13.jpg"],
      descripcion: "Expresiones urbanas hechas decoración."
    },
    {
      nombre: "GaleriaArte",
      usericon: "/images/logoart4.jpg",
      instagram: "https://www.instagram.com/galeriaarte",
      facebook: "#",
      imagenes: ["/images/cuadro14.jpg", "/images/cuadro15.jpg", "/images/cuadro16.jpg", "/images/cuadro17.jpg"],
      descripcion: "Tu rincón con estilo de galería."
    },
   
    ]
        erb :personas, locals: { personas: personas } 
    end

    get '/personaInd' do
    personas = [
        {
        nombre: "GastaCuadros",
        usericon: "/images/logoGastaCuadros.png",
        instagram: "https://www.instagram.com/gastacuadros",
        facebook: "#",
        imagenes: [
            "/images/cuadro1.png",
            "/images/cuadro2.png",
            "/images/cuadro3.png",
            "/images/cuadro5.jpg"
        ],
        descripcion: "Especialista en calado de madera a mano"
        }
    ]

    erb :personaInd, locals: { personas: personas }
    end


    get '/transferir' do
        user = User.find_by(id: session[:user_id])
        if user.nil?
            redirect '/login'
        end

        account = user.account
        if account.nil?
            return erb :transferir, locals: { error: "No tienes una cuenta asociada." }
        end

        erb :transferir, locals: { error: nil, account: account }
    end
   

    get '/seleccionarMontoTransferencia' do
        user = User.find_by(id: session[:user_id])
        redirect '/login' if user.nil?

        account = user.account
        if account.nil?
            return erb :seleccionarMontoTransferencia, locals: { error: "No tienes una cuenta asociada." }
        end

        erb :seleccionarMontoTransferencia, locals: { error: nil, account: account }
    end

   post '/seleccionarMontoTransferencia' do
        user = User.find_by(id: session[:user_id])
        redirect '/login' if user.nil?

        account = user.account
        return erb :seleccionarMontoTransferencia, locals: { error: "No tienes una cuenta asociada." } if account.nil?

        # Si viene el destinatario, guardalo en la sesión
        if params[:target_account]
            session[:target_account_alias] = params[:target_account]
        end

        # Si NO está en la sesión, error
        if session[:target_account_alias].nil? || session[:target_account_alias].strip.empty?
            return erb :seleccionarMontoTransferencia, locals: { error: "Debes ingresar un destinatario.", account: account }
        end

        amount = params[:amount].to_i
        if amount <= 0 || amount > account.balance
            return erb :seleccionarMontoTransferencia, locals: { error: "Monto inválido.", account: account }
        end

        session[:amount] = params[:amount].to_i if params[:amount]
        redirect '/seleccionarMotivoTransferencia'
    end

    get '/seleccionarMotivoTransferencia' do
        user = User.find_by(id: session[:user_id])
        redirect '/login' if user.nil?

        account = user.account
        if account.nil?
            return erb :seleccionarMotivoTransferencia, locals: { error: "No tienes una cuenta asociada." }
        end

       # Validar que el monto y destinatario estén en sesión
       if session[:amount].nil? || session[:amount].to_s.strip.empty? || session[:target_account_alias].nil?
           redirect '/seleccionarMontoTransferencia'
       end

         erb :seleccionarMotivoTransferencia, locals: { amount: session[:amount], error: nil, account: account }
    end

    post '/seleccionarMotivoTransferencia' do
        user = User.find_by(id: session[:user_id])
        redirect '/login' if user.nil?

        account = user.account
        return erb :seleccionarMotivoTransferencia, locals: { error: "No tienes una cuenta asociada.", amount: nil } if account.nil?

        # Si viene el monto por params, actualiza la sesión (por si el usuario refresca)
        session[:amount] = params[:amount] if params[:amount]

        reason = params[:reason]
        if reason.nil? || reason.strip.empty?
            return erb :seleccionarMotivoTransferencia, locals: { error: "Motivo inválido.", account: account, amount: session[:amount] }
        end
        session[:reason] = reason
        redirect '/welcome'
    end
    get '/calculadora' do
        erb :calculadora
    end

    get '/introduccionMuseo' do
        erb :introduccionMuseo
    end

    get '/museoDeArte' do
        erb :museoDeArte
    end

    get '/museoDeMusica' do
        erb :museoDeMusica
    end

    get '/miIdeaMuseo' do
        erb :miIdeaMuseo
    end

    get '/depositar' do
        user = User.find_by(id: session[:user_id])
        redirect '/login' if user.nil?

        account = user.account
        if account.nil?
            return erb :depositar, locals: {
            error: "No tenés una cuenta asociada.",
            cuenta_alias: nil,
            cbu_cvu: nil,
            nuevo_alias: nil,
            mensaje: nil
        }
        end

        erb :depositar, locals: {
            error: nil,
            cuenta_alias: account.alias,
            cbu_cvu: account.cbu_cvu,
            nuevo_alias: nil,
            mensaje: nil
        }
    end

    post '/depositar' do
        user = User.find_by(id: session[:user_id])
        redirect '/login' if user.nil?

        account = user.account
        if account.nil?
            return erb :depositar, locals: {
            error: "No tenés una cuenta asociada.",
            cuenta_alias: nil,
            cbu_cvu: nil,
            nuevo_alias: nil,
            mensaje: nil
            }
        end

        nuevo_alias = params[:alias].to_s.strip

        if nuevo_alias.empty?
            return erb :depositar, locals: {
            error: "El alias no puede estar vacío.",
            cuenta_alias: account.alias,
            cbu_cvu: account.cbu_cvu,
            nuevo_alias: nuevo_alias,
            mensaje: nil
            }
        end

        if Account.exists?(alias: nuevo_alias)
            return erb :depositar, locals: {
            error: "Ese alias ya está en uso.",
            cuenta_alias: account.alias,
            cbu_cvu: account.cbu_cvu,
            nuevo_alias: nuevo_alias,
            mensaje: nil
            }
        end

        if account.update(alias: nuevo_alias)
            return erb :depositar, locals: {
            mensaje: "✔️ Su alias se modificó con éxito.",
            cuenta_alias: account.alias,
            cbu_cvu: account.cbu_cvu,
            error: nil,
            nuevo_alias: nil
            }
        else
            return erb :depositar, locals: {
            error: "No se pudo actualizar el alias.",
            cuenta_alias: account.alias,
            cbu_cvu: account.cbu_cvu,
            nuevo_alias: nuevo_alias,
            mensaje: nil
            }
        end
    end

    get '/notificaciones' do
        user = User.find_by(id: session[:user_id])
        redirect '/login' if user.nil?
      
        # ejemplos para probar la vista, no deberia ir aca y hace falta conectarlo con la base de datos
        @notifications = [
          {
            type: 'transfer',
            message: 'Recibiste $1,000 de Leonardo',
            time: 'Hace 2 horas',
            unread: true
          },
          {
            type: 'deposit',
            message: 'Depósito exitoso por $3,000',
            time: 'Ayer',
            unread: false
          },
          {
            type: 'general',
            message: 'Actualización de términos y condiciones',
            time: '15/06/2025',
            unread: false
          }
        ]
      
        erb :notificaciones
      end
    
end
