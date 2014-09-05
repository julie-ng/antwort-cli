desc 'Starts http://localhost:9292 server for developing emails'
task :server do
  require 'antwort'
  Antwort::Server.run!
end
