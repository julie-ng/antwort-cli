desc 'Starts http://localhost:4567 server for developing emails'
task :server do
  puts "Starting development server..."
  sh "ruby lib/antwort/server.rb"
end
