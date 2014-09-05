ENV['gem_push'] = 'false'
require 'bundler/gem_tasks'

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec)
task default: :spec

desc 'Opens a console with antwort preloaded'
task :console do
  require 'pry'
  require 'antwort'
  include Antwort
  Pry.start
end
