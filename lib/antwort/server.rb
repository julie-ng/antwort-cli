require 'antwort/server/assets'
require 'antwort/server/helpers'
require 'antwort/server/markup'
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
    helpers Antwort::ApplicationHelpers
    helpers Antwort::MarkupHelpers

    configure do
      enable :logging
      set :root, Dir.pwd
      set :root, Dir.pwd + '/spec/fixtures/' if ENV['RACK_ENV'] == 'test'
      set :views, settings.root
      set :templates_dir, settings.root + '/emails'
      set :partial_template_engine, :erb
      enable :partial_underscores
      set :port, 9292
    end

    register Sinatra::Assets # after we set root

    get '/' do
      pages = Dir.entries(settings.templates_dir)
      pages.delete_if { |page| page.to_s[0] == '.' }
      @pages = Array.new
      pages.each do |p|
        path = p.split('.').first
        @pages.push({
          path: path,
          title: get_page_title(path)
        })
      end
      erb :'views/index', layout: :'views/server'
    end

    get '/template/:template' do
      @config   = OpenStruct.new(fetch_data_yaml('config'))
      @template = sanitize_param params[:template]

      if template_exists? @template
        content = read_template @template
        hash_to_instance_vars content[:metadata]
        hash_to_instance_vars fetch_data_yaml(@template)
        erb content[:body], layout: :'views/layout'
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
