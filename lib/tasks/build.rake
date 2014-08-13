# require './../antwort/build.rb'
# include EmailBuilder

desc 'Builds Markup from template'
task :build do
  build_template ENV['template']
end