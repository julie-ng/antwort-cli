require 'antwort/server/assets'
require 'antwort/helpers/server_helper'
require 'antwort/helpers/markup_helper'
require 'sinatra/base'
require 'sinatra/partial'
require 'sinatra/content_for'
require 'rack-livereload'
require 'sinatra/reloader'
require 'ostruct'

module Antwort
  class Server < Sinatra::Base
    use Rack::LiveReload
    Tilt.register Tilt::ERBTemplate, 'html.erb'
    register Sinatra::Partial
    register Sinatra::Reloader
    helpers Sinatra::ContentFor
    helpers Antwort::Helpers
    helpers Antwort::ApplicationHelpers
    helpers Antwort::MarkupHelpers

    configure do
      enable :logging
      set :root, Dir.pwd
      set :root, Dir.pwd + '/spec/fixtures/' if ENV['RACK_ENV'] == 'test'
      set :views, settings.root
      set :partial_template_engine, :erb
      enable :partial_underscores
      set :port, 9292
    end

    register Sinatra::Assets # after we set root

    get '/' do
      @emails = Antwort::EmailCollection.new
      erb :'views/index', layout: :'views/server'
    end

    get '/template/:template' do
      name     = sanitize_param params[:template]

      @template = Antwort::EmailTemplate.new(name)
      hash_to_instance_vars @template.data

      if @template.exists?
        erb @template.body, layout: @template.layout
      else
        status 404
      end
    end

    not_found do
      content_type 'text/html'
      erb :'views/404', layout: :'views/server'
    end

  end
end
