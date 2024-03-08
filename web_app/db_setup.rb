require 'sequel'

DB = Sequel.connect('sqlite://myDb.db', create: true, max_connections: 5)


unless DB.table_exists?(:users)
  DB.create_table :users do
    primary_key :id
    String :name
    String :email
    String :image_url
    String :password_hash
  end
end

class User < Sequel::Model
  include BCrypt

  def password
    Password.new(self.password_hash)
  end

  def password=(new_password)
    @password = Password.create(new_password)
    self.password_hash = @password
  end
end

user = User.new(name: 'Gustavo', email: 'gustavoalberttodev@gmail.com', image_url: 'https://cdn.discordapp.com/avatars/312572734955585536/51e5164338d76750088af6a09cf21aa6.webp?size=240')
user.password = '123456'
user.save
