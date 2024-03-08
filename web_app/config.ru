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
require_relative './db_setup'

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
    data = GraphqlRequests.query_all_polices(token: session[:user][:value])
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
    encoded_token = session[:user][:value]
    decode = JWT.decode encoded_token, ENV['JWT_SECRET'], true, algorithm: 'HS256'
    @user = User.where(email: decode[0]['email']).first
    decode
  end

  def not_logged_in?
    !logged_in?
  end

  def generate_token(email: params[:email])
    JWT.encode({id: SecureRandom.uuid, email:}, ENV['JWT_SECRET'], 'HS256')
  end

  def update_token
    encoded_token = generate_token
    session[:user] = { value: encoded_token }
  end

  def create_updated_user_or_update_user_token
    metadata = request.env['omniauth.auth'].to_hash
    encoded_token = generate_token(email: metadata['info']['email'])

    session[:user] = { value: encoded_token }

    user = User.where(email: metadata['info']['email'])
    unless user
      User.create(email: metadata['info']['email'],
                  name: metadata['info']['name'],
                  image_url: metadata['info']['image'])
    end
  end
end

Rack::Handler::Puma.run(
  MyApplication,
  Port: 5000,
  Host: '0.0.0.0'
)
