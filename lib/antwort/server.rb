require 'sinatra/base'
require 'sinatra/partial'
require 'sinatra/content_for'

module Antwort
  class Server < Sinatra::Base
    Tilt.register Tilt::ERBTemplate, 'html.erb'
    register Sinatra::Partial
    helpers Sinatra::ContentFor
    include Antwort::MarkupHelpers

    configure do
      enable :logging
      set :root, File.expand_path('../../../', __FILE__) + '/source'
      set :views, settings.root
      set :templates_dir, settings.root + '/emails'
      set :partial_template_engine, :erb
    end

    register Sinatra::Assets # must come after we set root

    get '/' do
      pages = Dir.entries(settings.templates_dir)
      pages.delete_if {|page| page.to_s[0] == '.' }
      @pages = pages.map { |page| page.split('.').first }
      erb :'views/index', layout: false
    end

    get '/template/:template/?' do
      @template = params[:template]
      if File.file? settings.templates_dir + '/' + @template + '.html.erb'
        erb :"emails/#{@template}", layout: :'views/layout'
      else
        status 404
      end
    end

    not_found do
      erb :'views/404'
    end

  end
end