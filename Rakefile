ENV['gem_push'] = 'false'
require 'bundler/gem_tasks'

desc 'Opens a console with antwort preloaded'
task :console do
  require 'pry'
  require 'antwort'
  include Antwort
  Pry.start
end
