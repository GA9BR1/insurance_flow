require 'sinatra'
require 'omniauth'
require 'omniauth-google-oauth2'
require 'rack/handler/puma'
require 'dotenv/load'
require 'sequel'
require 'bcrypt'
require 'jwt'
require 'securerandom'
require_relative './requests/graphql_requests'


DB = Sequel.connect('sqlite://myDb.db', create: true, max_connections: 5)

unless DB.table_exists?(:users)
  DB.create_table :users do
    primary_key :id
    String :name
    String :email
    String :image_url
    String :encoded_token
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

  def encoded_token
    JWT.decode(self.encoded_token, ENV['JWT_SECRET'], true, algorithm: 'HS256')
  end
end

user = User.new(name: 'Gustavo', email: 'gustavoalberttodev@gmail.com', image_url: 'https://cdn.discordapp.com/avatars/312572734955585536/51e5164338d76750088af6a09cf21aa6.webp?size=240')
user.password = '123456'
user.save

class MyApplication < Sinatra::Base
  configure do
    set :sessions, true
  end

  use Rack::Session::Cookie, :secret => ENV['RACK_COOKIE_SECRET']
  use OmniAuth::Builder do
    provider :google_oauth2, ENV['GOOGLE_KEY'], ENV['GOOGLE_SECRET'], scope: 'email profile'
  end

  before do
    case request.path_info
    when '/'
      not_logged_in? ? redirect('/login') : return
    when '/login'
      logged_in? ? redirect('/') : return
    end
  end

  get '/' do
    data = GraphqlRequests.query_all_polices
    erb :index, locals: { policies: data, user: @user }
  end

  get '/login' do
    erb :login, locals: {
      google_key: ENV['GOOGLE_KEY'],
      csrf_token: request.env['rack.session']['csrf']
    }
  end

  post '/authenticate' do
    user = User.where(email: params[:email]).first
    if user && user.password == params[:password]
      update_token

      redirect '/'
    else
      redirect '/login'
    end
  end

  post '/sign_out' do
    encoded_token = JWT.encode session[:user][:value], ENV['JWT_SECRET'], 'HS256'
    User.where(encoded_token:).first.update(encoded_token: nil)
    session[:user] = nil
    redirect '/'
  end

  get '/policies/new' do
    erb :new_policy
  end

  post '/policies' do
    #Net::HTTP.post('localhost:8080/graphql?mutation')
    # Implementar
  end

  get '/auth/:provider/callback' do
    content_type 'text/plain'
    create_updated_user_or_update_user_token

    redirect '/'
  end

  private

  def logged_in?
    return false if session[:user].nil? || session[:user][:value].nil?
    encoded_token = JWT.encode session[:user][:value], ENV['JWT_SECRET'], 'HS256'
    @user = User.where(encoded_token:).first
    return false unless @user.is_a? User
    true
  end

  def not_logged_in?
    !logged_in?
  end

  def generate_token
    token = JWT.encode SecureRandom.uuid, nil, 'none'
    encoded_token = JWT.encode token, ENV['JWT_SECRET'], 'HS256'
    { token: token, encoded_token: encoded_token }
  end

  def update_token
    token, encoded_token = generate_token.values_at(:token, :encoded_token)
    session[:user] = { value: token }
    User.where(email: params[:email]).update(encoded_token:)
  end

  def create_updated_user_or_update_user_token
    metadata = request.env['omniauth.auth'].to_hash
    generate_token
    token, encoded_token = generate_token.values_at(:token, :encoded_token)

    session[:user] = { value: token }

    user = User.where(email: metadata['info']['email'])
    unless user
      User.create(email: metadata['info']['email'],
                  name: metadata['info']['name'],
                  image_url: metadata['info']['image'],
                  encoded_token:)
      return
    end

    user.update(encoded_token:)
  end
end

Rack::Handler::Puma.run(
  MyApplication,
  Port: 5000,
  Host: '0.0.0.0'
)
