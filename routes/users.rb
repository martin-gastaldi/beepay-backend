require 'sinatra'
require 'sinatra/namespace'
require './models/user'

namespace '/users' do

  # Obtener todos los usuarios
  get do
    content_type :json
    User.all.to_json
  end

  # Crear un nuevo usuario
  post do
    data = JSON.parse(request.body.read)

    user = User.new(name: data['name'], email: data['email'])

    if user.save
      status 201
      user.to_json
    else
      status 422
      { errors: user.errors.full_messages }.to_json
    end
  end

end
