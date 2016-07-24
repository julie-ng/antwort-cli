require 'thor'
require 'dotenv'
Dotenv.load

# Namespace
module Antwort
end

require 'antwort/helpers/helper'
require 'antwort/cli'
require 'antwort/builder'
require 'antwort/server'
require 'antwort/version'
