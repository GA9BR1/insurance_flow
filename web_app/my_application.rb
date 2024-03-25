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
require 'byebug'
require 'faye/websocket'
require_relative 'middlewares/CognitoAuthMiddleware'

class MyApplication < Sinatra::Base
  configure do
    set :sessions, true
  end

  use Rack::Session::Cookie, :secret => ENV['RACK_COOKIE_SECRET']
  use OmniAuth::Builder do
    provider :google_oauth2, ENV['GOOGLE_KEY'], ENV['GOOGLE_SECRET'], scope: 'email profile'
  end
  use CognitoAuthMiddleware

  set :server, 'thin'
  set :sockets, []

  before do
    case request.path_info
    when '/'
      p session[:user]
      not_logged_in? ? redirect('/login') : return
    when '/login'
      logged_in? ? redirect('/') : return
    when '/policies/new'
      not_logged_in? ? redirect('/login') : return
    end
  end

  get '/' do
    env = request.env
    if Faye::WebSocket.websocket?(env)
      ws = Faye::WebSocket.new(env)
      settings.sockets << ws
      ws.rack_response
    else
      data = GraphqlRequests.query_all_polices(
        token: session[:user][:value], token_kind: session[:user][:kind]
      )
      erb :index, locals: { policies: data, user: @user }
    end
  end

  get '/broadcast' do
    broadcast('Hello, world!')
  end

  post '/send_to_websockets' do
    body = request.body.read
    p body
    broadcast(body)
    status 200
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
      update_token(email: params[:email], kind: 'login_password')

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
    erb :new_policy, locals: { user: @user }
  end

  post '/create_policy' do
    p request.params
    mutation = {
  query: <<-GRAPHQL
    mutation {
      createPolicy(input: {
        policy: {
          dataEmissao: "#{Date.today.to_s}",
          dataFimCobertura: "#{request.params['end-date']}",
          valorPremio: #{request.params['prize-value']},
          segurado: {
            nome: "#{request.params['full-name']}",
            cpf: "#{request.params['cpf']}",
            email: "#{request.params['email']}"
          },
          veiculo: {
            marca: "#{request.params['car-brand']}",
            modelo: "#{request.params['car-model']}",
            ano: #{request.params['car-year']},
            placa: "#{request.params['car-plate']}"
          }
        }
      }) {
        result
      }
    }
  GRAPHQL
}.to_json
    token = session[:user][:value]
    token_kind = session[:user][:kind]
    response = Net::HTTP.post(URI('http://graphql_api:3001/graphql'), mutation, 'Content-Type' => 'application/json', 'Authorization' => "Bearer #{token}", 'Token-Kind' => token_kind)
    p response.body
    p response.code
    response.body
  end

  get '/auth/:provider/callback' do
    if params[:provider] == 'google_oauth2'
      create_updated_user_or_update_user_token
    end
    redirect '/'
  end

  post '/auth/cognito-idp' do
    redirect 'https://relabs-pool.auth.us-east-1.amazoncognito.com/login?' \
      'response_type=code&client_id=2m0gcvut6sh3ggassgu6srn4jr&' \
      'redirect_uri=http://localhost:3000/auth/cognito-idp/callback'
  end

  private

  def broadcast(message)
    settings.sockets.each { |s| s.send(message) }
  end


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

  def update_token(email: nil, kind:)
    encoded_token = generate_token(email:)
    session[:user] = { value: encoded_token, kind: }
  end

  def create_updated_user_or_update_user_token
    metadata = request.env['omniauth.auth'].to_hash
    update_token(email: metadata['info']['email'], kind: 'google_oauth')
    user = User.where(email: metadata['info']['email']).first
    unless user
      User.create(email: metadata['info']['email'],
      name: metadata['info']['name'],
      image_url: metadata['info']['image'])
    end
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
