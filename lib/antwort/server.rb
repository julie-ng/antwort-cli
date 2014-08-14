require 'sinatra/base'

module Antwort
  class Server < Sinatra::Base

    configure do
      enable :logging
      set :root, File.expand_path('../../../', __FILE__) + '/source'
      set :views, settings.root + '/emails'
    end

    register Sinatra::Assets
    Tilt.register Tilt::ERBTemplate, 'html.erb'

    # puts "root: #{settings.root}"
    # puts "views: #{settings.views}"

    def self.get_files_list(dir_name)
      array = Dir.entries(dir_name)
      array.delete('.')
      array.delete('..')
      array
    end

    get '/' do
      @pages = Dir.entries(settings.templates_dir).delete('.')
      erb :index, layout: false
    end

    get '/:template/?' do
      template = params[:template]
      if File.file? settings.templates_dir + '/' + template + '.' + settings.template_ext
        puts "Template exists"
        erb :"#{settings.templates_dir}/#{template}"
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