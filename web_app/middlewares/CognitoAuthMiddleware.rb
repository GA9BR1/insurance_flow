require 'net/http'
class CognitoAuthMiddleware
  def initialize(app)
    @app = app
  end

  def call(env)
    request = Rack::Request.new(env)
    if request.path_info.match?(/\/auth\/cognito-idp\/callback/)
      response = Net::HTTP.post_form(
        URI("https://relabs-pool.auth.us-east-1.amazoncognito.com/oauth2/token"),
        {
          'grant_type' => 'authorization_code',
          'client_id' => ENV['COGNITO_CLIENT_ID'],
          'client_secret' => ENV['COGNITO_CLIENT_SECRET'],
          'code' => request.params['code'],
          'redirect_uri' => 'http://localhost:3000/auth/cognito-idp/callback'
        }
      )
      token = JSON.parse(response.body)
      env['rack.session'][:user] = { value: token['access_token'], kind: 'cognito' }
    end

    if request.path_info.match?(/^\/auth\/cognito-idp(?:\/|$)/)
      p '----------------'
      p Rack::Protection::AuthenticityToken.new(@app).accepts?(env)
      p '----------------'
      puts 'XD'
    end
    @app.call(env)
  end
end
