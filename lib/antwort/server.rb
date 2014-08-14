require 'sinatra/base'
require 'tilt'

module Antwort
  class Server < Sinatra::Base

    configure do
      enable :logging
      set :root, File.expand_path('../../../', __FILE__) + '/source'
      set :views, settings.root + '/emails'
      set :templates_dir, settings.root + '/emails'
      # set :template_ext, 'html.erb'
    end

    register Sinatra::Assets
    Tilt.register Tilt::ERBTemplate, 'html.erb'

    puts "root: #{settings.root}"
    puts "views: #{settings.views}"

    get '/' do
      @pages = Dir.entries(settings.templates_dir).delete('.')
      erb :index, layout: false
    end

    get '/:template/?' do
      template = params[:template]
      if File.file? settings.views + '/' + template + '.html.erb'
        puts "Template exists"
        erb template.to_sym #:"#{settings.templates_dir}/#{template}"
      else
        status 404
      end
    end

    not_found do
      puts "Template does not exist"
      erb :'404'
    end

  end
end