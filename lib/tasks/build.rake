require File.expand_path('../../', __FILE__) + '/antwort/build'
include Antwort::Builder

desc 'Builds Markup from template'
task :build do
  build_template ENV['template']
end