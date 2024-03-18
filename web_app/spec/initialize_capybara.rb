ENV['APP_PORT'] = '6000'
require_relative '../my_application'
app = MyApplication

require 'webdrivers/chromedriver'
require 'random-port'

chrome_options = Selenium::WebDriver::Chrome::Options.new
chrome_options.binary = "/usr/bin/google-chrome"
chrome_options.add_argument('--headless')
chrome_options.add_argument('--window-size=1280,1024')
chrome_options.add_argument('--no-sandbox')

RandomPort::Pool.new.acquire do |port|
  Capybara.server_port = '6001'
end

Capybara.register_driver :local_headless_chrome do |app|
  Capybara::Selenium::Driver.new(app, browser: :chrome, options: chrome_options)
end

Capybara.default_driver = :local_headless_chrome

# Definir Capybara.app com a instância já inicializada
Capybara.app = app
