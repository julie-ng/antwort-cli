require 'fileutils'

namespace :build do
  desc 'Builds Markup from template (required: id=template_name})'
  task :template do
    require 'antwort'
    template = ENV['id'] ? ENV['id'] : 'newsletter'
    Antwort::Builder.new(template: template).build
  end

  desc 'Empties the build directory'
  task :clean do
    folders = Dir.entries(File.expand_path('./build'))
    folders.delete_if { |f| f.to_s[0] == '.' }
    folders.each do |f|
      puts "Removing #{f}..."
      FileUtils.rm_rf(File.expand_path("./build/#{f}"))
    end
  end
end
