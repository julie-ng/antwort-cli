require 'sinatra/base'
require './assets_extension'
require './server'

app = Antwort::Server.new
request = Rack::MockRequest.new(app)

puts request
puts request.inspect


response = request.get('/newsletter')
puts response.body

