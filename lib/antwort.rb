require 'thor'
require 'dotenv'
Dotenv.load unless ENV['RACK_ENV'] == 'test'

# Namespace
module Antwort
end

require 'antwort/helpers/helper'
require 'antwort/helpers/file_helper'
require 'antwort/core'
require 'antwort/cli'
require 'antwort/server'
require 'antwort/version'
