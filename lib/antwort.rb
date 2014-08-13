require 'sinatra/base'

class Antwort < Sinatra::Base
  Tilt.register Tilt::ERBTemplate, 'html.erb'

  configure do
    set :root, File.expand_path('../../', __FILE__)
    set :views, settings.root + '/source/emails'
  end

  # puts "root: #{settings.root}"
  # puts "views: #{settings.views}"

  def self.get_files_list(dir_name)
    array = Dir.entries(dir_name)
    array.delete('.')
    array.delete('..')
    array
  end

  def self.is_dir?(base_dir, file)
    File.directory?(settings.views + base_dir + file)
  end

  def self.mount_files_as_routes(filenames_array, base_dir='/')
    filenames_array.each do |file|
      base_name = file.split('.').first
      route = base_dir + base_name

      if is_dir? base_dir, file
        puts "do recursive on #{file}"
      else
        puts "route: #{route}, base_dir: #{base_dir}"
        get route do
          erb base_name.to_sym
        end
      end

    end
  end


  mount_files_as_routes get_files_list(settings.views)

  run! if app_file == $0
end