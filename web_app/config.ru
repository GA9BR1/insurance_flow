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
require 'net/http'


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
    data = GraphqlRequests.query_all_polices(
      token: session[:user][:value], token_kind: session[:user][:kind]
    )
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
      update_token(kind: 'login_and_password', email: params[:email])

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
    if params[:provider] == 'google_oauth2'
      create_updated_user_or_update_user_token
    else
      update_token(kind: 'cognito')
    end
    redirect '/'
  end

  get '/login-cognito' do
    redirect 'https://relabs-pool.auth.us-east-1.amazoncognito.com/login?' \
      'response_type=code&client_id=2m0gcvut6sh3ggassgu6srn4jr&' \
      'redirect_uri=http://localhost:3000/auth/cognito-idp/callback'
  end


  private

  def logged_in?
    return false if session[:user].nil? || session[:user][:value].nil? || session[:user][:kind].nil?
    if session[:user][:kind] == 'cognito'
      logged_in_with_cognito?
    else
      logged_in_with_google?
    end
  end

  def not_logged_in?
    !logged_in?
  end

  def generate_token(email: params[:email])
    JWT.encode({id: SecureRandom.uuid, email:}, ENV['JWT_SECRET'], 'HS256')
  end

  def update_token(kind: 'login_and_password', email: nil)
    case kind
    when 'login_and_password', 'oauth_google'
      encoded_token = generate_token(email:)
      session[:user] = { value: encoded_token, kind: }
    when 'cognito'
      token = get_cognito_token_by_code
      session[:user] = { value: token['access_token'], kind: 'cognito' }
    end
  end

  def create_updated_user_or_update_user_token
    metadata = request.env['omniauth.auth'].to_hash
    update_token(kind: 'oauth_google', email: metadata['info']['email'])
    user = User.where(email: metadata['info']['email'])
    unless user
      User.create(email: metadata['info']['email'],
      name: metadata['info']['name'],
      image_url: metadata['info']['image'])
    end
  end

  def get_cognito_token_by_code
    response = Net::HTTP.post_form(
      URI("https://relabs-pool.auth.us-east-1.amazoncognito.com/oauth2/token"),
      {
        'grant_type' => 'authorization_code',
        'client_id' => ENV['COGNITO_CLIENT_ID'],
        'client_secret' => ENV['COGNITO_CLIENT_SECRET'],
        'code' => params[:code],
        'redirect_uri' => 'http://localhost:3000/auth/cognito-idp/callback'
      }
    )
    JSON.parse(response.body)
  end

  def logged_in_with_cognito?
    resp = Net::HTTP.get(URI("https://relabs-pool.auth.us-east-1.amazoncognito.com/oauth2/userInfo"),
                            {
                              'Authorization' => "Bearer #{session[:user][:value]}",
                              'Token-Kind' => 'cognito'
                            })
    user_info = JSON.parse(resp)
    return false if user_info['error']
    @user = OpenStruct.new(email: user_info['email'], name: user_info['username'])
    true
  end

  def logged_in_with_google?
    encoded_token = session[:user][:value]
    decode = JWT.decode encoded_token, ENV['JWT_SECRET'], true, algorithm: 'HS256'
    @user = User.where(email: decode[0]['email']).first
    decode
  end
end

Rack::Handler::Puma.run(
  MyApplication,
  Port: 3000,
  Host: '0.0.0.0'
)
