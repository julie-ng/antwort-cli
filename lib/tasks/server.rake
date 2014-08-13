desc 'Starts http://localhost:4567 server for developing emails'
task :server do
  sh "ruby lib/antwort.rb"
end
