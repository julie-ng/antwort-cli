require 'thor'
require 'dotenv'
Dotenv.load

# Namespace
module Antwort
end

require_relative 'antwort/cli/helpers'
require_relative 'antwort/cli'
require_relative 'antwort/cli/send'
require_relative 'antwort/cli/upload'
require 'antwort/builder'
require 'antwort/server'
require_relative 'antwort/version'
