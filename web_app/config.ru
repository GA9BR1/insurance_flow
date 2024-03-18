require_relative './my_application'

Rackup::Handler::Puma.run(
  MyApplication,
  Port: ENV['APP_PORT'],
  Host: '0.0.0.0'
)
