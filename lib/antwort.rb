require 'sinatra/base'
require 'dotenv'
Dotenv.load

Dir.glob('./antwort/*.rb').each { |file| require file }

# class Antwort < Sinatra::Base
# end

module Antwort
end