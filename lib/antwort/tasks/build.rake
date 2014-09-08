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
    build_dir = File.expand_path('./build')
    next unless File.directory?(build_dir)

    Dir.foreach(build_dir) do |f|
      next if f.to_s[0] == '.'

      puts "Removing #{f}..."
      FileUtils.rm_rf(File.expand_path("./build/#{f}"))
    end
  end
end