require 'sinatra/base'

class Antwort < Sinatra::Base
  Tilt.register Tilt::ERBTemplate, 'html.erb'

  configure do
    set :root, File.expand_path('../../', __FILE__)
    set :views, settings.root + '/source/emails'
  end

  # puts "root: #{settings.root}"
  # puts "views: #{settings.views}"

  base_dir = '/'
  Dir.entries(settings.views).each do |file|
    unless file == '.' || file == '..'

      route = base_dir + file.split('.').first
      puts "route: #{route}, base_dir: #{base_dir}"

      get route do
        erb file.gsub('.html.erb', '').to_sym
      end
    end
  end


  run! if app_file == $0
end