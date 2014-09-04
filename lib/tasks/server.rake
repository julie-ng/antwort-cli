desc 'Starts http://localhost:9292 server for developing emails'
task :server do
  Antwort::Server.run!
end
