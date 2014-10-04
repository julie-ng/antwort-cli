require 'sinatra/base'
require 'sinatra/partial'
require 'sinatra/content_for'
require 'rack-livereload'
require 'sinatra/reloader'

module Antwort
  class Server < Sinatra::Base
    use Rack::LiveReload
    Tilt.register Tilt::ERBTemplate, 'html.erb'
    register Sinatra::Partial
    register Sinatra::Reloader
    helpers Sinatra::ContentFor
    include Antwort::ApplicationHelpers
    include Antwort::MarkupHelpers

    configure do
      enable :logging
      set :root, Dir.pwd
      set :views, settings.root
      set :templates_dir, settings.root + '/emails'
      set :partial_template_engine, :erb
      enable :partial_underscores
      set :port, 9292
    end

    register Sinatra::Assets # must come after we set root

    get '/' do
      pages = Dir.entries(settings.templates_dir)
      pages.delete_if { |page| page.to_s[0] == '.' }
      @pages = pages.map { |page| page.split('.').first }
      erb :'views/index', layout: :'views/server'
    end

    get '/foo/:template' do
      @layout = 'views/layout'
      @template = params[:template]
      file = "#{settings.views}/emails/#{@template}/index.html.erb"
      file_content = File.read(file)

      if (md = file_content.match(/^(?<metadata>---\s*\n.*?\n?)^(---\s*$\n?)/m))
        contents = md.post_match
        @metadata = YAML.load(md[:metadata])
      end

      context = self
      template = Tilt['erb'].new { contents }
      layout = Tilt::ERBTemplate.new("#{settings.views}/views/layout.erb")
      layout.render(context) {
        puts template.inspect
        template.render(context, :world => 'World!')
      }
    end

    get '/template/:template/?' do
      @template = params[:template]

      data_file = settings.root + '/data/' + @template + '.yml'
      if File.file? data_file
        @data = YAML.load_file(data_file)
        @data = symbolize_keys! @data
      else
        @data = {}
      end

      if File.file? settings.templates_dir + '/' + @template + '/index.html.erb'
        erb :"emails/#{@template}/index", layout: :'views/layout'
      else
        status 404
      end
    end

    not_found do
      erb :'views/404', layout: :'views/server'
    end
  end
end
