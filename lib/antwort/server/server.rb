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
      set :server_views, File.expand_path(File.dirname(__FILE__)) + '/views'
      set :partial_template_engine, :erb
      enable :partial_underscores
      set :port, 9292
    end

    register Sinatra::Assets # after we set root

    @server_index  ||= File.read(settings.server_views + '/index.html.erb')
    @server_404    ||= File.read(settings.server_views + '/404.html.erb')
    @server_layout ||= File.read(settings.server_views + '/server.erb')

    get '/' do
      @emails = Antwort::EmailCollection.new
      erb :server_index, layout: :server_layout
    end

    get '/template/:template' do
      name      = sanitize_param params[:template]
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
      erb :server_404, layout: :server_layout
    end

    template :server_index do
      @server_index
    end

    template :server_404 do
      @server_404
    end

    template :server_layout do
      @server_layout
    end
  end
end
