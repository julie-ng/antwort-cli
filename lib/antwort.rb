require 'sinatra/base'

class Antwort < Sinatra::Base
  configure do
    set :root, File.expand_path('../', __FILE__, '/source')
    set :views, settings.root + '/emails'
  end
end