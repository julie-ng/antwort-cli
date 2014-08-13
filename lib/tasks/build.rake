# require './../antwort/build.rb'
# include EmailBuilder

puts File.dirname(__FILE__)

desc 'Builds Markup from template'
task :build do
  build_template ENV['template']
end