class AddColumnsToUsers < ActiveRecord::Migration[8.0]
  def change

    add_column :users, :password_digest, :string
  end
end
# esta migración agrega dos columnas a la tabla 'users':

# - 'email': para almacenar el correo electrónico del usuario.

# - 'password_digest': para almacenar el hash de la contraseña del usuario.

# Ambas columnas son de tipo 'string'.
# Esta migración es útil para implementar autenticación de usuarios en la aplicación.

