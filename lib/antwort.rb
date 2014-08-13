require 'dotenv'
Dotenv.load

Dir.glob('./antwort/*.rb').each { |file| require file }

module Antwort
end