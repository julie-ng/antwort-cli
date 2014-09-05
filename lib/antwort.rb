# Namespace
module Antwort
end

require_relative 'antwort/builder'
require_relative 'antwort/cli'
require_relative 'antwort/cli/upload'
require_relative 'antwort/server/assets'
require_relative 'antwort/server/helpers'
require_relative 'antwort/server'
require_relative 'antwort/version'

require 'dotenv'
Dotenv.load
